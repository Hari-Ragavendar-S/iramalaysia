#!/usr/bin/env python3
"""
Initialize Supabase PostgreSQL Database for Irama1Asia
This script creates all necessary tables and initial data
"""

import asyncio
import sys
from pathlib import Path

# Add the project root to Python path
sys.path.append(str(Path(__file__).parent))

from app.core.database import engine, Base
from app.models.user import User
from app.models.location import Location
from app.models.pod import Pod
from app.models.event import Event
from app.core.config import settings
from app.core.security import get_password_hash
from sqlalchemy import text
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def create_tables():
    """Create all database tables"""
    try:
        logger.info("🔄 Creating database tables...")
        
        # Create all tables
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        
        logger.info("✅ Database tables created successfully!")
        return True
    except Exception as e:
        logger.error(f"❌ Error creating tables: {e}")
        return False

async def create_admin_user():
    """Create default admin user"""
    try:
        from app.core.database import get_db
        
        logger.info("🔄 Creating default admin user...")
        
        async with engine.begin() as conn:
            # Check if admin already exists
            result = await conn.execute(
                text("SELECT id FROM users WHERE email = :email"),
                {"email": settings.DEFAULT_ADMIN_EMAIL}
            )
            
            if result.fetchone():
                logger.info("ℹ️  Admin user already exists")
                return True
            
            # Create admin user
            hashed_password = get_password_hash(settings.DEFAULT_ADMIN_PASSWORD)
            
            await conn.execute(
                text("""
                    INSERT INTO users (email, hashed_password, full_name, is_active, is_admin, is_verified)
                    VALUES (:email, :password, :name, true, true, true)
                """),
                {
                    "email": settings.DEFAULT_ADMIN_EMAIL,
                    "password": hashed_password,
                    "name": "System Administrator"
                }
            )
            
            await conn.commit()
        
        logger.info(f"✅ Admin user created: {settings.DEFAULT_ADMIN_EMAIL}")
        return True
    except Exception as e:
        logger.error(f"❌ Error creating admin user: {e}")
        return False

async def insert_sample_locations():
    """Insert sample Malaysian locations"""
    try:
        logger.info("🔄 Inserting sample locations...")
        
        locations_data = [
            # Kuala Lumpur
            ("Kuala Lumpur", "Kuala Lumpur", "KLCC", "Kuala Lumpur City Centre", "Jalan Ampang, 50088 Kuala Lumpur", "Premium shopping and business district"),
            ("Kuala Lumpur", "Kuala Lumpur", "Pavilion KL", "Pavilion Kuala Lumpur", "168, Jalan Bukit Bintang, 55100 Kuala Lumpur", "Upscale shopping mall in Bukit Bintang"),
            ("Kuala Lumpur", "Kuala Lumpur", "Mid Valley Megamall", "Mid Valley Megamall", "Lingkaran Syed Putra, 59200 Kuala Lumpur", "Large shopping complex with high foot traffic"),
            ("Kuala Lumpur", "Kuala Lumpur", "Suria KLCC", "Suria KLCC", "Kuala Lumpur City Centre, 50088 Kuala Lumpur", "Shopping mall at the base of Petronas Towers"),
            
            # Selangor - Petaling Jaya
            ("Selangor", "Petaling Jaya", "1 Utama", "1 Utama Shopping Centre", "1, Lebuh Bandar Utama, 47800 Petaling Jaya", "One of Malaysia's largest shopping malls"),
            ("Selangor", "Petaling Jaya", "The Curve", "The Curve", "6, Jalan PJU 7/3, 47800 Petaling Jaya", "Lifestyle shopping destination"),
            ("Selangor", "Petaling Jaya", "Sunway Pyramid", "Sunway Pyramid", "3, Jalan PJS 11/15, 47500 Petaling Jaya", "Iconic pyramid-shaped mall"),
            
            # Selangor - Shah Alam
            ("Selangor", "Shah Alam", "i-City Mall", "i-City Mall", "i-City, 40000 Shah Alam", "Modern shopping mall in i-City"),
            ("Selangor", "Shah Alam", "Plaza Shah Alam", "Plaza Shah Alam", "Persiaran Perbandaran, 40000 Shah Alam", "Central shopping location"),
            
            # Penang
            ("Penang", "George Town", "Gurney Plaza", "Gurney Plaza", "170, Persiaran Gurney, 10250 George Town", "Premier shopping destination in Penang"),
            ("Penang", "George Town", "Queensbay Mall", "Queensbay Mall", "100, Persiaran Bayan Indah, 11900 Bayan Lepas", "Large shopping mall in Bayan Lepas"),
            
            # Johor
            ("Johor", "Johor Bahru", "City Square", "City Square", "106-108, Jalan Wong Ah Fook, 80000 Johor Bahru", "Central shopping mall in JB"),
            ("Johor", "Johor Bahru", "KSL City Mall", "KSL City Mall", "33, Jalan Seladang, 80250 Johor Bahru", "Popular shopping destination"),
        ]
        
        async with engine.begin() as conn:
            # Check if locations already exist
            result = await conn.execute(text("SELECT COUNT(*) FROM locations"))
            count = result.scalar()
            
            if count > 0:
                logger.info("ℹ️  Sample locations already exist")
                return True
            
            # Insert locations
            for state, city, name, full_name, address, description in locations_data:
                await conn.execute(
                    text("""
                        INSERT INTO locations (state, city, name, full_name, address, description, is_active)
                        VALUES (:state, :city, :name, :full_name, :address, :description, true)
                    """),
                    {
                        "state": state,
                        "city": city,
                        "name": name,
                        "full_name": full_name,
                        "address": address,
                        "description": description
                    }
                )
            
            await conn.commit()
        
        logger.info(f"✅ Inserted {len(locations_data)} sample locations")
        return True
    except Exception as e:
        logger.error(f"❌ Error inserting sample locations: {e}")
        return False

async def test_connection():
    """Test database connection"""
    try:
        logger.info("🔄 Testing database connection...")
        
        async with engine.begin() as conn:
            result = await conn.execute(text("SELECT version()"))
            version = result.scalar()
            logger.info(f"✅ Connected to PostgreSQL: {version}")
        
        return True
    except Exception as e:
        logger.error(f"❌ Database connection failed: {e}")
        return False

async def main():
    """Main initialization function"""
    logger.info("🚀 Starting Supabase Database Initialization for Irama1Asia")
    logger.info(f"📍 Database: {settings.DATABASE_URL.split('@')[1] if '@' in settings.DATABASE_URL else 'Hidden'}")
    
    # Test connection
    if not await test_connection():
        logger.error("❌ Cannot connect to database. Please check your connection string.")
        return False
    
    # Create tables
    if not await create_tables():
        logger.error("❌ Failed to create tables")
        return False
    
    # Create admin user
    if not await create_admin_user():
        logger.error("❌ Failed to create admin user")
        return False
    
    # Insert sample data
    if not await insert_sample_locations():
        logger.error("❌ Failed to insert sample locations")
        return False
    
    logger.info("🎉 Database initialization completed successfully!")
    logger.info("📋 Summary:")
    logger.info("   ✅ Database tables created")
    logger.info(f"   ✅ Admin user: {settings.DEFAULT_ADMIN_EMAIL}")
    logger.info("   ✅ Sample locations inserted")
    logger.info("")
    logger.info("🔐 Admin Login Credentials:")
    logger.info(f"   📧 Email: {settings.DEFAULT_ADMIN_EMAIL}")
    logger.info(f"   🔑 Password: {settings.DEFAULT_ADMIN_PASSWORD}")
    logger.info("")
    logger.info("🚀 You can now start the FastAPI server:")
    logger.info("   python main.py")
    
    return True

if __name__ == "__main__":
    asyncio.run(main())