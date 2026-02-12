from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.security import get_current_user, get_current_busker
from app.models.user import User, Busker
from app.schemas.user import BuskerRegister, BuskerUpdate, BuskerProfile

router = APIRouter()

@router.post("/register", response_model=BuskerProfile)
async def register_busker(
    busker_data: BuskerRegister,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Register user as busker"""
    # Check if user is already a busker
    result = await db.execute(select(Busker).where(Busker.user_id == current_user.id))
    existing_busker = result.scalar_one_or_none()
    
    if existing_busker:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is already registered as busker"
        )
    
    # Update user type
    current_user.user_type = "busker"
    
    # Create busker profile
    busker = Busker(
        user_id=current_user.id,
        **busker_data.dict()
    )
    
    db.add(busker)
    await db.commit()
    await db.refresh(busker)
    
    # Load user relationship
    result = await db.execute(
        select(Busker).options(selectinload(Busker.user))
        .where(Busker.id == busker.id)
    )
    busker_with_user = result.scalar_one()
    
    return BuskerProfile.from_orm(busker_with_user)

@router.get("/profile", response_model=BuskerProfile)
async def get_busker_profile(
    current_user: User = Depends(get_current_busker),
    db: AsyncSession = Depends(get_db)
):
    """Get busker profile"""
    result = await db.execute(
        select(Busker).options(selectinload(Busker.user))
        .where(Busker.user_id == current_user.id)
    )
    busker = result.scalar_one_or_none()
    
    if not busker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Busker profile not found"
        )
    
    return BuskerProfile.from_orm(busker)

@router.put("/profile", response_model=BuskerProfile)
async def update_busker_profile(
    busker_data: BuskerUpdate,
    current_user: User = Depends(get_current_busker),
    db: AsyncSession = Depends(get_db)
):
    """Update busker profile"""
    result = await db.execute(select(Busker).where(Busker.user_id == current_user.id))
    busker = result.scalar_one_or_none()
    
    if not busker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Busker profile not found"
        )
    
    # Update fields
    for field, value in busker_data.dict(exclude_unset=True).items():
        setattr(busker, field, value)
    
    await db.commit()
    await db.refresh(busker)
    
    # Load user relationship
    result = await db.execute(
        select(Busker).options(selectinload(Busker.user))
        .where(Busker.id == busker.id)
    )
    busker_with_user = result.scalar_one()
    
    return BuskerProfile.from_orm(busker_with_user)

@router.get("/verification-status")
async def get_verification_status(
    current_user: User = Depends(get_current_busker),
    db: AsyncSession = Depends(get_db)
):
    """Get busker verification status"""
    result = await db.execute(select(Busker).where(Busker.user_id == current_user.id))
    busker = result.scalar_one_or_none()
    
    if not busker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Busker profile not found"
        )
    
    return {
        "verification_status": busker.verification_status,
        "verification_notes": busker.verification_notes
    }

@router.post("/upload-id-proof")
async def upload_id_proof(
    id_proof_url: str,
    id_proof_type: str,
    current_user: User = Depends(get_current_busker),
    db: AsyncSession = Depends(get_db)
):
    """Upload ID proof for verification"""
    result = await db.execute(select(Busker).where(Busker.user_id == current_user.id))
    busker = result.scalar_one_or_none()
    
    if not busker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Busker profile not found"
        )
    
    busker.id_proof_url = id_proof_url
    busker.id_proof_type = id_proof_type
    busker.verification_status = "pending"
    
    await db.commit()
    
    return {"message": "ID proof uploaded successfully"}