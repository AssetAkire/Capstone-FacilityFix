from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth
from .routers import database
from .routers import users
from .routers import profiles
from .auth.firebase_auth import firebase_auth

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

# Include routers
app.include_router(auth.router)
app.include_router(database.router)
app.include_router(users.router)
app.include_router(profiles.router)

@app.get("/")
async def root():
    return {"message": "Welcome to the FacilityFix API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}