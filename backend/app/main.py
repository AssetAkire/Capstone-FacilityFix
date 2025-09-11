import os
import csv
import re

from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langdetect import detect

import torch
import torch.nn.functional as F
from transformers import AutoTokenizer, RobertaConfig, RobertaModel, RobertaPreTrainedModel
import torch.nn as nn
from transformers.modeling_outputs import SequenceClassifierOutput

from .core.config import USE_GROQ, GROQ_MODEL, GROQ_API_KEY
from .services.groq_translate import translate_one


# ---------------- App & CORS ----------------
app = FastAPI(title="FacilityFix Inference API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # tighten for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------- Health & quick translator ----------------
@app.get("/health")
def health():
    return {
        "use_groq": USE_GROQ,
        "groq_model": GROQ_MODEL,
        "groq_key_present": bool(GROQ_API_KEY),
        "groq_key_endswith": (GROQ_API_KEY[-4:] if GROQ_API_KEY else None),
    }


class _TIn(BaseModel):
    text: str


@app.post("/_translate_only")
def _translate_only(body: _TIn):
    out = translate_one(body.text)
    return {"in": body.text, "out": out}


# ---------------- Labels: load EXACT training order from CSV ----------------
MODEL_PATH = "models/facilityfix-ai"

def _read_label_list(path: str):
    items = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.reader(f):
            if not row:
                continue
            val = row[0].strip()
            # skip header/stray index lines like "0"
            if not val or val.lower() == "0":
                continue
            items.append(val)
    return items

CATEGORIES = _read_label_list(os.path.join(MODEL_PATH, "categories.csv"))
URGENCIES  = _read_label_list(os.path.join(MODEL_PATH, "urgencies.csv"))

CATEGORIES_LOWER = [c.lower() for c in CATEGORIES]
URGENCIES_LOWER  = [u.lower() for u in URGENCIES]

NUM_CAT = len(CATEGORIES)   # 6
NUM_URG = len(URGENCIES)    # 3
NUM_LABELS = NUM_CAT + NUM_URG

print("[Labels] Categories:", CATEGORIES)
print("[Labels] Urgencies:", URGENCIES)


# ---------------- Tokenizer & Multi-head Model ----------------
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)

hf_config = RobertaConfig.from_pretrained(
    "roberta-base",
    num_labels=NUM_LABELS,
    problem_type="single_label_classification",
)

def _mean_pool(last_hidden_state: torch.Tensor, attention_mask: torch.Tensor) -> torch.Tensor:
    """Mean-pool token embeddings using the attention mask."""
    # last_hidden_state: [B, T, H], attention_mask: [B, T]
    mask = attention_mask.unsqueeze(-1).type_as(last_hidden_state)  # [B, T, 1]
    summed = (last_hidden_state * mask).sum(dim=1)                  # [B, H]
    counts = mask.sum(dim=1).clamp(min=1e-9)                        # [B, 1]
    return summed / counts

class MultiHeadRoberta(RobertaPreTrainedModel):
    """
    Matches your checkpoint keys:
      - cat_head.weight/bias  [6, 768], [6]
      - urg_head.weight/bias  [3, 768], [3]
    """
    def __init__(self, config, num_cat: int, num_urg: int):
        super().__init__(config)
        self.num_cat = num_cat
        self.num_urg = num_urg
        self.roberta = RobertaModel(config, add_pooling_layer=True)
        self.dropout = nn.Dropout(config.hidden_dropout_prob)
        self.cat_head = nn.Linear(config.hidden_size, num_cat)
        self.urg_head = nn.Linear(config.hidden_size, num_urg)
        self.post_init()

    def forward(self, input_ids=None, attention_mask=None, token_type_ids=None, **kwargs):
        outputs = self.roberta(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )
        # ✅ Use MEAN pool instead of pooler_output/CLS
        rep = _mean_pool(outputs.last_hidden_state, attention_mask)  # [B, H]
        x = self.dropout(rep)
        cat_logits = self.cat_head(x)  # [B, num_cat]
        urg_logits = self.urg_head(x)  # [B, num_urg]
        logits = torch.cat([cat_logits, urg_logits], dim=-1)  # [B, num_cat+num_urg]
        return SequenceClassifierOutput(logits=logits)

# Instantiate and manually load weights (remap enc.* → roberta.*)
model = MultiHeadRoberta(hf_config, num_cat=NUM_CAT, num_urg=NUM_URG)
ckpt_path = os.path.join(MODEL_PATH, "pytorch_model.bin")
state = torch.load(ckpt_path, map_location="cpu")

def _remap_enc_to_roberta_keys(sd: dict) -> dict:
    """Remap Kaggle-saved 'enc.*' keys to HF's expected 'roberta.*' keys."""
    remapped = {}
    for k, v in sd.items():
        nk = k
        if k.startswith("enc."):
            nk = "roberta." + k[len("enc."):]  # enc.* → roberta.*
        # heads already match your class: cat_head.*, urg_head.*
        remapped[nk] = v
    return remapped

state = _remap_enc_to_roberta_keys(state)
missing, unexpected = model.load_state_dict(state, strict=False)
print("[Checkpoint] missing keys:", missing)
print("[Checkpoint] unexpected keys:", unexpected)

model.eval()  # turn off dropout


# ---------------- Helpers ----------------
TAGALOG_STOPWORDS = {
    "ang","ng","sa","si","ni","nasa","wala","meron","yung","dahil",
    "para","kapag","kahit","itong","baka","kasi","may","tumutulo","kisame","cr"
}

def _detect_lang_taglish(text: str) -> str:
    try:
        lang = detect(text)
    except Exception:
        lang = "en"
    if lang == "tl":
        return "tl"
    tokens = re.findall(r"[A-Za-z]+", text.lower())
    tl_hits = sum(1 for t in tokens if t in TAGALOG_STOPWORDS)
    return "tl" if tl_hits >= 2 else "en"


# ---------------- Request/Response models ----------------
class PredictIn(BaseModel):
    description: str


class PredictOut(BaseModel):
    original_text: str
    processed_text: str
    detected_language: str
    translated: bool
    category: str
    urgency: str


# ---------------- Prediction endpoint ----------------
@app.post("/predict", response_model=PredictOut)
def predict(inp: PredictIn, force_translate: bool = Query(False)):
    original = inp.description.strip()
    lang = _detect_lang_taglish(original)

    processed = original
    translated = False

    if USE_GROQ and (force_translate or lang == "tl"):
        try:
            processed = translate_one(original) or original
            translated = True
        except Exception as e:
            print(f"[Predict] Falling back to original (Groq failed): {e}")
            processed = original
            translated = False

    inputs = tokenizer(
        processed,
        return_tensors="pt",
        truncation=True,
        padding="max_length",
        max_length=256
    )
    with torch.no_grad():
        outputs = model(**inputs)

    logits = outputs.logits
    cat_logits = logits[:, :NUM_CAT]
    urg_logits = logits[:, NUM_CAT:]

    cat_id = int(cat_logits.argmax(dim=-1).item())
    urg_id = int(urg_logits.argmax(dim=-1).item())

    category = CATEGORIES[cat_id]
    category_l = CATEGORIES_LOWER[cat_id]
    urgency  = URGENCIES[urg_id]

    # Business rule (keep if required by prof): pest control is always HIGH
    #if category_l == "pest control":
        #urgency = "high"

    return PredictOut(
        original_text=original,
        processed_text=processed,
        detected_language=lang,
        translated=translated,
        category=category,
        urgency=urgency,
    )


# ---------------- Debug endpoint ----------------
class _DbgIn(BaseModel):
    text: str

@app.post("/_debug_logits")
def _debug_logits(body: _DbgIn, force_translate: bool = Query(False)):
    # detect + optional translate (same logic as /predict)
    text = body.text.strip()
    lang = _detect_lang_taglish(text)
    processed = text
    if USE_GROQ and (force_translate or lang == "tl"):
        try:
            processed = translate_one(text) or text
        except Exception as e:
            print(f"[_debug_logits] translate failed, using original: {e}")
            processed = text

    inputs = tokenizer(
        processed,
        return_tensors="pt",
        truncation=True,
        padding="max_length",
        max_length=256,
    )
    with torch.no_grad():
        outputs = model(**inputs)

    logits = outputs.logits
    cat_logits = logits[:, :NUM_CAT]
    urg_logits = logits[:, NUM_CAT:]

    cat_probs = F.softmax(cat_logits, dim=-1).squeeze(0).tolist()
    urg_probs = F.softmax(urg_logits, dim=-1).squeeze(0).tolist()

    cat_scores = sorted(
        [{"label": CATEGORIES[i], "score": float(cat_probs[i])} for i in range(NUM_CAT)],
        key=lambda x: x["score"], reverse=True
    )[:3]
    urg_scores = sorted(
        [{"label": URGENCIES[i], "score": float(urg_probs[i])} for i in range(NUM_URG)],
        key=lambda x: x["score"], reverse=True
    )

    return {
        "input_text": text,
        "processed_text": processed,
        "detected_language": lang,
        "categories_top3": cat_scores,
        "urgencies": urg_scores,
        "cat_argmax": cat_scores[0]["label"],
        "urg_argmax": urg_scores[0]["label"],
        "used_order": {"categories": CATEGORIES, "urgencies": URGENCIES},
    }
