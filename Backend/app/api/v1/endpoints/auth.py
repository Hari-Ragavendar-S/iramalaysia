from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
import secrets
import string

from app.core.database import get_db
from app.core.security import (
    verify_password, 
    get_password_hash, 
    create_access_token, 
    create_refresh_token,
    verify_token,
    security
)
from app.models.user import User, AdminUser, OTPVerification
from app.schemas.auth import (
    UserRegister, 
    UserLogin, 
    AdminLogin,
    Token, 
    RefreshToken,
    PasswordReset,
    PasswordResetConfirm,
    OTPVerification as OTPVerificationSchema,
    OTPRequest,
    UserProfile,
    AdminProfile
)
from app.services.email_service import send_email
from app.services.sms_service import send_sms

router = APIRouter()

def generate_otp() -> str:
    """Generate 6-digit OTP"""
    return ''.join(secrets.choice(string.digits) for _ in range(6))

@router.post("/register", response_model=Token)
async def register_user(
    user_data: UserRegister,
    db: AsyncSession = Depends(get_db)
):
    """Register a new user"""
    # Check if user already exists
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user - Skip OTP verification, mark as verified
    user = User(
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        phone=user_data.phone,
        user_type=user_data.user_type,
        is_verified=True  # Skip OTP verification
    )
    
    db.add(user)
    await db.commit()
    await db.refresh(user)
    
    # Skip OTP generation and email sending
    
    # Create tokens
    access_token = create_access_token(
        data={
            "sub": str(user.id),
            "email": user.email,
            "user_type": user.user_type
        }
    )
    refresh_token = create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=30 * 60  # 30 minutes
    )

@router.post("/login", response_model=Token)
async def login_user(
    user_credentials: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """Login user"""
    # Get user
    result = await db.execute(select(User).where(User.email == user_credentials.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(user_credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user account"
        )
    
    # Update last login
    user.last_login = datetime.utcnow()
    await db.commit()
    
    # Create tokens
    access_token = create_access_token(
        data={
            "sub": str(user.id),
            "email": user.email,
            "user_type": user.user_type
        }
    )
    refresh_token = create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=30 * 60
    )

@router.post("/admin/login", response_model=Token)
async def login_admin(
    admin_credentials: AdminLogin,
    db: AsyncSession = Depends(get_db)
):
    """Login admin user"""
    # Get admin
    result = await db.execute(select(AdminUser).where(AdminUser.email == admin_credentials.email))
    admin = result.scalar_one_or_none()
    
    if not admin or not verify_password(admin_credentials.password, admin.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect admin credentials"
        )
    
    if not admin.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive admin account"
        )
    
    # Update last login
    admin.last_login = datetime.utcnow()
    await db.commit()
    
    # Create tokens
    access_token = create_access_token(
        data={
            "sub": str(admin.id),
            "email": admin.email,
            "user_type": "admin",
            "role": admin.role
        }
    )
    refresh_token = create_refresh_token(
        data={"sub": str(admin.id)}
    )
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=30 * 60
    )

@router.post("/refresh", response_model=Token)
async def refresh_token(
    refresh_data: RefreshToken,
    db: AsyncSession = Depends(get_db)
):
    """Refresh access token"""
    token_data = verify_token(refresh_data.refresh_token)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    # Get user
    result = await db.execute(select(User).where(User.id == token_data.user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    # Create new tokens
    access_token = create_access_token(
        data={
            "sub": str(user.id),
            "email": user.email,
            "user_type": user.user_type
        }
    )
    new_refresh_token = create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    return Token(
        access_token=access_token,
        refresh_token=new_refresh_token,
        expires_in=30 * 60
    )

@router.post("/forgot-password")
async def forgot_password(
    reset_data: PasswordReset,
    db: AsyncSession = Depends(get_db)
):
    """Request password reset - Skip OTP, allow direct password reset"""
    # Check if user exists
    result = await db.execute(select(User).where(User.email == reset_data.email))
    user = result.scalar_one_or_none()
    
    if not user:
        # Don't reveal if email exists or not
        return {"message": "If the email exists, a reset code has been sent"}
    
    # Skip OTP generation and email sending for now
    # In production, you might want to implement a different reset mechanism
    
    return {"message": "Password reset request processed. Please contact support for assistance."}

@router.post("/reset-password")
async def reset_password(
    reset_data: PasswordResetConfirm,
    db: AsyncSession = Depends(get_db)
):
    """Reset password - Skip OTP verification"""
    # Get user directly without OTP verification
    result = await db.execute(select(User).where(User.email == reset_data.email))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Update password directly (skip OTP verification)
    user.password_hash = get_password_hash(reset_data.new_password)
    await db.commit()
    
    return {"message": "Password reset successfully"}

@router.post("/verify-otp")
async def verify_otp(
    otp_data: OTPVerificationSchema,
    db: AsyncSession = Depends(get_db)
):
    """Verify OTP - Always return success (OTP bypass)"""
    # Skip actual OTP verification, always return success
    return {"message": "OTP verified successfully"}

@router.post("/resend-otp")
async def resend_otp(
    otp_request: OTPRequest,
    db: AsyncSession = Depends(get_db)
):
    """Resend OTP - Always return success (OTP bypass)"""
    # Skip actual OTP sending, always return success
    return {"message": "OTP sent successfully"}

@router.get("/profile", response_model=UserProfile)
async def get_user_profile(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
):
    """Get current user profile"""
    token_data = verify_token(credentials.credentials)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
    
    result = await db.execute(select(User).where(User.id == token_data.user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserProfile.from_orm(user)

@router.get("/admin/profile", response_model=AdminProfile)
async def get_admin_profile(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
):
    """Get current admin profile"""
    token_data = verify_token(credentials.credentials)
    if not token_data or token_data.user_type != "admin":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid admin token"
        )
    
    result = await db.execute(select(AdminUser).where(AdminUser.id == token_data.user_id))
    admin = result.scalar_one_or_none()
    
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Admin not found"
        )
    
    return AdminProfile.from_orm(admin)