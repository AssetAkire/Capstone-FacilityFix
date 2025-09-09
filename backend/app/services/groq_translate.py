from groq import Groq
from ..core.config import GROQ_API_KEY, GROQ_MODEL

_client = Groq(api_key=GROQ_API_KEY)

_SYSTEM = (
    "You are a precise Tagalog-to-English translator for building maintenance tickets. "
    "Return only the English translation."
)

def translate_one(text: str) -> str:
    try:
        resp = _client.chat.completions.create(
            model=GROQ_MODEL,
            messages=[
                {"role": "system", "content": _SYSTEM},
                {"role": "user", "content": f"Translate to English:\nTagalog: {text}\nEnglish:"}
            ],
            temperature=0.1,
            max_tokens=200
        )
        return (resp.choices[0].message.content or "").strip()
    except Exception as e:
        print(f"[Groq] translation error: {e}")
        raise

