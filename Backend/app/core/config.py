from pydantic_settings import BaseSettings
from typing import List, Optional
import os
from pathlib import Path

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Irama1Asia API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # Database - Supabase PostgreSQL
    DATABASE_URL: str = "postgresql://postgres:#Harish_953_@db.ovqpcuapmxmcyvwoeuxb.supabase.co:5432/postgres"
    REDIS_URL: str = "redis://localhost:6379"
    
    # JWT
    JWT_SECRET_KEY: str = "your-super-secret-jwt-key-change-this-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Email
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    MAIL_FROM: str = "noreply@irama1asia.com"
    MAIL_FROM_NAME: str = "Irama1Asia"
    
    # SMS (Twilio)
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_PHONE_NUMBER: str = ""
    
    # File Upload
    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE: int = 10485760  # 10MB
    ALLOWED_IMAGE_TYPES: List[str] = ["jpg", "jpeg", "png", "webp"]
    ALLOWED_DOCUMENT_TYPES: List[str] = ["pdf"]
    
    # AWS S3 (Optional)
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_BUCKET_NAME: Optional[str] = None
    AWS_REGION: str = "ap-southeast-1"
    
    # Admin
    DEFAULT_ADMIN_EMAIL: str = "info@techneysoft.net"
    DEFAULT_ADMIN_PASSWORD: str = "Techneysoft@8940"
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "https://irama1asia.com"
    ]
    
    # Rate Limiting
    RATE_LIMIT_LOGIN: str = "5/15minutes"
    RATE_LIMIT_OTP: str = "3/5minutes"
    RATE_LIMIT_UPLOAD: str = "10/hour"
    RATE_LIMIT_API: str = "1000/hour"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# Create settings instance
settings = Settings()

# Ensure upload directory exists
Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)