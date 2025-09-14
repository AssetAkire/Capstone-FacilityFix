from dotenv import load_dotenv
import os

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_MODEL   = os.getenv("GROQ_MODEL", "llama3-70b-8192")
USE_GROQ     = os.getenv("USE_GROQ", "true").lower() == "true"

if not GROQ_API_KEY:
    raise RuntimeError("Missing GROQ_API_KEY in .env")
