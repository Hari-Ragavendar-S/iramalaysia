from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer
import uvicorn
import os
from pathlib import Path

from app.core.config import settings
from app.core.database import engine, Base
from app.api.v1.api import api_router
from app.core.security import create_default_admin

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="FastAPI backend for Irama1Asia - Busker Pod Booking & Admin Management System",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
app.include_router(api_router, prefix="/api/v1")

# Static files for uploads
uploads_dir = Path(settings.UPLOAD_DIR)
uploads_dir.mkdir(exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")

@app.on_event("startup")
async def startup_event():
    """Initialize database and create default admin user"""
    try:
        print("🔄 Connecting to Supabase PostgreSQL...")
        
        # Test database connection
        async with engine.begin() as conn:
            from sqlalchemy import text
            result = await conn.execute(text("SELECT version()"))
            version = result.scalar()
            print(f"✅ Connected to PostgreSQL: {version}")
        
        # Create database tables
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("✅ Database tables initialized")
        
        # Create default admin user
        await create_default_admin()
        print("✅ Default admin user ready")
        
        print(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} started successfully!")
        print(f"📚 API Documentation: http://148.135.138.145:8000/api/v1/docs")
        print(f"🔐 Default Admin: {settings.DEFAULT_ADMIN_EMAIL}")
        print(f"🗄️  Database: Supabase PostgreSQL")
        
    except Exception as e:
        print(f"❌ Startup failed: {e}")
        print("🔧 Please check your Supabase connection settings")
        raise

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": f"Welcome to {settings.APP_NAME} API",
        "version": settings.APP_VERSION,
        "docs": "/api/v1/docs",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info"
    )