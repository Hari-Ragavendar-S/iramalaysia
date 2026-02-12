from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from pathlib import Path
from datetime import datetime
import uuid
import aiofiles

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.config import settings
from app.models.user import User

router = APIRouter()

ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}
ALLOWED_DOCUMENT_EXTENSIONS = {'.pdf'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

async def save_upload_file(upload_file: UploadFile, destination: Path) -> None:
    """Save uploaded file to destination"""
    async with aiofiles.open(destination, 'wb') as f:
        content = await upload_file.read()
        await f.write(content)

@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload image file"""
    
    # Validate file extension
    file_extension = Path(file.filename).suffix.lower()
    if file_extension not in ALLOWED_IMAGE_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed types: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}"
        )
    
    # Validate file size
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large. Maximum size: {MAX_FILE_SIZE / 1024 / 1024:.1f}MB"
        )
    
    # Reset file pointer
    await file.seek(0)
    
    # Generate unique filename
    file_id = str(uuid.uuid4())
    stored_filename = f"image_{file_id}{file_extension}"
    
    # Create upload directory
    upload_dir = Path(settings.UPLOAD_DIR) / "images"
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Save file
    file_path = upload_dir / stored_filename
    await save_upload_file(file, file_path)
    
    # Return file URL
    file_url = f"/uploads/images/{stored_filename}"
    
    return {
        "message": "Image uploaded successfully",
        "file_url": file_url,
        "filename": stored_filename
    }

@router.post("/document")
async def upload_document(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload document file"""
    
    # Validate file extension
    file_extension = Path(file.filename).suffix.lower()
    if file_extension not in ALLOWED_DOCUMENT_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed types: {', '.join(ALLOWED_DOCUMENT_EXTENSIONS)}"
        )
    
    # Validate file size
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large. Maximum size: {MAX_FILE_SIZE / 1024 / 1024:.1f}MB"
        )
    
    # Reset file pointer
    await file.seek(0)
    
    # Generate unique filename
    file_id = str(uuid.uuid4())
    stored_filename = f"document_{file_id}{file_extension}"
    
    # Create upload directory
    upload_dir = Path(settings.UPLOAD_DIR) / "documents"
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Save file
    file_path = upload_dir / stored_filename
    await save_upload_file(file, file_path)
    
    # Return file URL
    file_url = f"/uploads/documents/{stored_filename}"
    
    return {
        "message": "Document uploaded successfully",
        "file_url": file_url,
        "filename": stored_filename
    }