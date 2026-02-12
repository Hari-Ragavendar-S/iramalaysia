from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from datetime import datetime
from pathlib import Path
import uuid
import aiofiles

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.config import settings
from app.models.user import User
from app.models.pod import PodBooking, PaymentStatus
from app.models.location import BuskingLocation

router = APIRouter()

ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.pdf'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

async def save_upload_file(upload_file: UploadFile, destination: Path) -> None:
    """Save uploaded file to destination"""
    async with aiofiles.open(destination, 'wb') as f:
        content = await upload_file.read()
        await f.write(content)

@router.post("/upload")
async def upload_payment_proof(
    booking_id: str = Form(...),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload payment proof for booking"""
    
    # Validate file extension
    file_extension = Path(file.filename).suffix.lower()
    if file_extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
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
    
    # Get booking and verify ownership
    result = await db.execute(
        select(PodBooking).options(
            selectinload(PodBooking.location),
            selectinload(PodBooking.pod)
        ).where(
            PodBooking.id == booking_id,
            PodBooking.user_id == current_user.id
        )
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found or access denied"
        )
    
    # Generate unique filename
    file_id = str(uuid.uuid4())
    stored_filename = f"payment_proof_{booking.booking_reference}_{file_id}{file_extension}"
    
    # Create upload directory
    upload_dir = Path(settings.UPLOAD_DIR) / "payment_proofs"
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Save file
    file_path = upload_dir / stored_filename
    await save_upload_file(file, file_path)
    
    # Update booking with payment proof URL
    payment_proof_url = f"/uploads/payment_proofs/{stored_filename}"
    booking.payment_proof_url = payment_proof_url
    booking.payment_uploaded_at = datetime.utcnow()
    booking.payment_status = PaymentStatus.PENDING
    
    await db.commit()
    
    # Return response matching Flutter expectations
    return {
        "message": "Payment proof uploaded successfully",
        "booking_id": str(booking.id),
        "booking_reference": booking.booking_reference,
        "payment_proof_url": payment_proof_url,
        "status": "pending",
        "uploaded_at": booking.payment_uploaded_at.isoformat()
    }
    
    # Save file
    file_path = upload_dir / stored_filename
    await save_upload_file(file, file_path)
    
    # Update booking with payment proof
    booking.payment_proof_url = f"/uploads/payment_proofs/{stored_filename}"
    booking.payment_status = PaymentStatus.PENDING
    booking.payment_uploaded_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(booking)
    
    return {
        "message": "Payment proof uploaded successfully",
        "booking_id": str(booking.id),
        "booking_reference": booking.booking_reference,
        "payment_proof_url": booking.payment_proof_url,
        "payment_status": booking.payment_status,
        "uploaded_at": booking.payment_uploaded_at
    }

@router.get("/booking/{booking_id}/status")
async def get_payment_status(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get payment status for booking"""
    
    result = await db.execute(
        select(PodBooking).where(
            PodBooking.id == booking_id,
            PodBooking.user_id == current_user.id
        )
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found or access denied"
        )
    
    return {
        "booking_id": str(booking.id),
        "booking_reference": booking.booking_reference,
        "payment_status": booking.payment_status,
        "payment_proof_url": booking.payment_proof_url,
        "payment_uploaded_at": booking.payment_uploaded_at,
        "payment_verified_at": booking.payment_verified_at
    }