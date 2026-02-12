from fastapi import APIRouter
from app.api.v1.endpoints import auth, users, buskers, pods, events, admin, upload, locations, payment_proof

api_router = APIRouter()

# Authentication routes
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])

# User routes
api_router.include_router(users.router, prefix="/users", tags=["Users"])

# Busker routes
api_router.include_router(buskers.router, prefix="/buskers", tags=["Buskers"])

# Pod routes
api_router.include_router(pods.router, prefix="/pods", tags=["Pods"])

# Event routes
api_router.include_router(events.router, prefix="/events", tags=["Events"])

# Admin routes
api_router.include_router(admin.router, prefix="/admin", tags=["Admin"])

# Upload routes
api_router.include_router(upload.router, prefix="/upload", tags=["File Upload"])

# Location routes
api_router.include_router(locations.router, prefix="/locations", tags=["Locations"])

# Payment proof routes
api_router.include_router(payment_proof.router, prefix="/payment-proof", tags=["Payment Proof"])