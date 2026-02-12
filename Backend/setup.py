#!/usr/bin/env python3
"""
Setup script for Irama1Asia FastAPI Backend
"""

import asyncio
import sys
from pathlib import Path

# Add the app directory to Python path
sys.path.append(str(Path(__file__).parent))

from app.core.database import init_db
from app.core.security import create_default_admin
from app.core.config import settings

async def setup_database():
    """Initialize database and create default admin"""
    print("🔧 Setting up Irama1Asia Backend...")
    
    try:
        # Initialize database tables
        print("📊 Creating database tables...")
        await init_db()
        print("✅ Database tables created successfully!")
        
        # Create default admin user
        print("👤 Creating default admin user...")
        await create_default_admin()
        print("✅ Default admin user created successfully!")
        
        print(f"""
🎉 Setup completed successfully!

📚 API Documentation: http://localhost:8000/api/v1/docs
🔐 Default Admin Credentials:
   Email: {settings.DEFAULT_ADMIN_EMAIL}
   Password: {settings.DEFAULT_ADMIN_PASSWORD}

🚀 Start the server with:
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
        """)
        
    except Exception as e:
        print(f"❌ Setup failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(setup_database())