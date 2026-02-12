#!/usr/bin/env python3
"""
Start Irama1Asia Backend with Supabase PostgreSQL
This script initializes the database and starts the FastAPI server
"""

import asyncio
import subprocess
import sys
from pathlib import Path

# Add the project root to Python path
sys.path.append(str(Path(__file__).parent))

import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def main():
    """Main startup function"""
    logger.info("🚀 Starting Irama1Asia Backend with Supabase PostgreSQL")
    logger.info("=" * 60)
    
    try:
        # Step 1: Test connection
        logger.info("📡 Step 1: Testing Supabase connection...")
        from test_supabase_connection import test_connection
        
        if not await test_connection():
            logger.error("❌ Cannot connect to Supabase. Please check your configuration.")
            return False
        
        # Step 2: Initialize database
        logger.info("\n🗄️  Step 2: Initializing database...")
        from init_supabase_db import main as init_db
        
        if not await init_db():
            logger.error("❌ Database initialization failed.")
            return False
        
        # Step 3: Start FastAPI server
        logger.info("\n🌐 Step 3: Starting FastAPI server...")
        logger.info("🔗 API will be available at: http://148.135.138.145:8000")
        logger.info("📚 API Documentation: http://148.135.138.145:8000/docs")
        logger.info("🔧 Admin Panel: http://148.135.138.145:8000/admin")
        logger.info("\n⏳ Starting server in 3 seconds...")
        
        await asyncio.sleep(3)
        
        # Start the server
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            "main:app", 
            "--host", "0.0.0.0", 
            "--port", "8000",
            "--reload"
        ])
        
        return True
        
    except KeyboardInterrupt:
        logger.info("\n👋 Server stopped by user")
        return True
    except Exception as e:
        logger.error(f"❌ Startup failed: {e}")
        return False

if __name__ == "__main__":
    asyncio.run(main())