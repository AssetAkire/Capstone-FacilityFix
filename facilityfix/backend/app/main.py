# app/main.py
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
import logging
import importlib
import traceback

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("facilityfix")

# App
app = FastAPI(
    title="FacilityFix API",
    description="Smart Maintenance and Repair Analytics Management System",
    version="1.0.0",
)

# CORS (keep permissive for dev; tighten for prod)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],         
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Router loader
def safe_include_router(router_module_path: str, router_name: str = "router") -> bool:
    """Safely import and include a router with error handling."""
    try:
        module = importlib.import_module(router_module_path)
        router = getattr(module, router_name)
        app.include_router(router)
        logger.info("✅ Included %s", router_module_path)
        return True
    except Exception as e:
        logger.error("❌ Failed to include %s: %s", router_module_path, str(e))
        traceback.print_exc()
        return False

logger.info("Loading routers...")
routers_to_load = [
    ("app.routers.auth", "Authentication"),
    ("app.routers.database", "Database"),
    ("app.routers.users", "Users"),
    ("app.routers.profiles", "Profiles"),
    ("app.routers.work_orders", "Work Orders"),
    ("app.routers.repair_requests", "Repair Requests"),
]

successful_routers: list[str] = []
failed_routers: list[str] = []

for module_path, description in routers_to_load:
    if safe_include_router(module_path):
        successful_routers.append(description)
    else:
        failed_routers.append(description)

logger.info("Routers loaded OK: %s", successful_routers)
if failed_routers:
    logger.warning("Routers failed: %s", failed_routers)

# Root + Health + HEAD handlers (prevents '405 Method Not Allowed' on HEAD)
@app.head("/")
async def head_root() -> Response:
    # Browsers/devtools often probe with HEAD; return 200 to avoid noisy 405 logs.
    return Response(status_code=200)

@app.get("/")
async def root():
    return {
        "message": "Welcome to the FacilityFix API",
        "loaded_routers": successful_routers,
        "failed_routers": failed_routers,
    }

@app.head("/health")
async def head_health() -> Response:
    return Response(status_code=200)

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "loaded_routers": len(successful_routers),
        "failed_routers": len(failed_routers),
    }

# (Optional) quiet preflight for /
@app.options("/")
async def options_root() -> Response:
    return Response(status_code=204)

# Local run helper (optional)--
if __name__ == "__main__":
    import uvicorn
    # For real-device testing on the same LAN: host='0.0.0.0'
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
