from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

from .core.firebase_init import initialize_firebase, get_firebase_status

# Initialize Firebase first
print("🔥 Initializing Firebase for FastAPI app...")
firebase_status = get_firebase_status()
print(f"Firebase status: {firebase_status}")

if not firebase_status['available']:
    success = initialize_firebase()
    if success:
        print("✅ Firebase initialized successfully")
    else:
        print("⚠️ Firebase initialization failed - app will run without Firebase features")

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FacilityFix API",
    description="Smart Maintenance and Repair Analytics Management System",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust as needed for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def safe_include_router(router_module_path: str, router_name: str = "router"):
    """Safely include a router with error handling"""
    try:
        module = __import__(router_module_path, fromlist=[router_name])
        router = getattr(module, router_name)
        app.include_router(router)
        logger.info(f"✅ Successfully included {router_module_path}")
        return True
    except Exception as e:
        logger.error(f"❌ Failed to include {router_module_path}: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

# Include routers with error handling
logger.info("Loading routers...")

# Try to include each router individually
routers_to_load = [
    ("app.routers.auth", "Authentication"),
    ("app.routers.database", "Database"),
    ("app.routers.users", "Users"),
    ("app.routers.profiles", "Profiles"),
    ("app.routers.concern_slips", "Concern Slips"),
    ("app.routers.job_services", "Job Services"),
    ("app.routers.work_order_permits", "Work Order Permits"),
    ("app.routers.inventory", "Inventory Management"),
    ("app.routers.maintenance_calendar", "Maintenance Calendar"),
    ("app.routers.notifications", "Notifications"),
    ("app.routers.websocket", "WebSocket"),
    ("app.routers.announcements", "Announcements"),
]

successful_routers = []
failed_routers = []

for router_path, router_description in routers_to_load:
    if safe_include_router(router_path):
        successful_routers.append(router_description)
    else:
        failed_routers.append(router_description)

logger.info(f"Successfully loaded routers: {successful_routers}")
if failed_routers:
    logger.warning(f"Failed to load routers: {failed_routers}")

@app.get("/")
async def root():
    firebase_status = get_firebase_status()
    return {
        "message": "Welcome to the FacilityFix API",
        "firebase_status": firebase_status,
        "loaded_routers": successful_routers,
        "failed_routers": failed_routers
    }

@app.get("/health")
async def health_check():
    firebase_status = get_firebase_status()
    return {
        "status": "healthy",
        "firebase_available": firebase_status['available'],
        "loaded_routers": len(successful_routers),
        "failed_routers": len(failed_routers)
    }
