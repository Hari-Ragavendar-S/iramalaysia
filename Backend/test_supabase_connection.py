#!/usr/bin/env python3
"""
Test Supabase PostgreSQL Connection
Quick script to verify database connectivity
"""

import asyncio
import sys
from pathlib import Path

# Add the project root to Python path
sys.path.append(str(Path(__file__).parent))

from app.core.database import engine
from app.core.config import settings
from sqlalchemy import text
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def test_connection():
    """Test basic database connection"""
    try:
        logger.info("🔄 Testing Supabase PostgreSQL connection...")
        logger.info(f"📍 Host: db.ovqpcuapmxmcyvwoeuxb.supabase.co")
        
        async with engine.begin() as conn:
            # Test basic connection
            result = await conn.execute(text("SELECT version()"))
            version = result.scalar()
            logger.info(f"✅ PostgreSQL Version: {version}")
            
            # Test current database
            result = await conn.execute(text("SELECT current_database()"))
            db_name = result.scalar()
            logger.info(f"✅ Connected to database: {db_name}")
            
            # Test current user
            result = await conn.execute(text("SELECT current_user"))
            user = result.scalar()
            logger.info(f"✅ Connected as user: {user}")
            
            # Test schema access
            result = await conn.execute(text("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'public'"))
            schema = result.scalar()
            if schema:
                logger.info(f"✅ Public schema accessible")
            else:
                logger.warning("⚠️  Public schema not found")
            
            # Test table creation permissions
            try:
                await conn.execute(text("""
                    CREATE TABLE IF NOT EXISTS connection_test (
                        id SERIAL PRIMARY KEY,
                        test_message TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                """))
                logger.info("✅ Table creation permissions: OK")
                
                # Insert test data
                await conn.execute(text("""
                    INSERT INTO connection_test (test_message) 
                    VALUES ('Irama1Asia Backend Connection Test')
                """))
                logger.info("✅ Insert permissions: OK")
                
                # Read test data
                result = await conn.execute(text("SELECT COUNT(*) FROM connection_test"))
                count = result.scalar()
                logger.info(f"✅ Read permissions: OK (found {count} test records)")
                
                # Clean up test table
                await conn.execute(text("DROP TABLE IF EXISTS connection_test"))
                logger.info("✅ Drop permissions: OK")
                
            except Exception as e:
                logger.error(f"❌ Database permissions error: {e}")
                return False
        
        logger.info("🎉 Supabase connection test completed successfully!")
        logger.info("✅ Your backend is ready to connect to Supabase PostgreSQL")
        return True
        
    except Exception as e:
        logger.error(f"❌ Connection test failed: {e}")
        logger.error("🔧 Please check:")
        logger.error("   1. Database URL is correct")
        logger.error("   2. Password is correct (#Harish_953_)")
        logger.error("   3. Supabase project is active")
        logger.error("   4. Network connectivity")
        return False

async def main():
    """Main test function"""
    logger.info("🚀 Irama1Asia - Supabase Connection Test")
    logger.info("=" * 50)
    
    success = await test_connection()
    
    if success:
        logger.info("\n🎯 Next Steps:")
        logger.info("1. Run: python init_supabase_db.py")
        logger.info("2. Start backend: python main.py")
        logger.info("3. Access API docs: http://148.135.138.145:8000/docs")
    else:
        logger.error("\n❌ Connection failed. Please fix the issues above.")
    
    return success

if __name__ == "__main__":
    asyncio.run(main())