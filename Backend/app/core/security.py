from datetime import datetime, timedelta
from typing import Optional, Union, Any
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.config import settings
from app.core.database import get_db
from app.models.user import User, AdminUser
from app.schemas.auth import TokenData

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT Bearer
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)

def create_access_token(
    data: dict, 
    expires_delta: Optional[timedelta] = None
) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire, "iat": datetime.utcnow()})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: dict) -> str:
    """Create JWT refresh token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "iat": datetime.utcnow(), "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[TokenData]:
    """Verify and decode JWT token"""
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
        token_data = TokenData(
            user_id=user_id,
            email=payload.get("email"),
            user_type=payload.get("user_type"),
            role=payload.get("role")
        )
        return token_data
    except JWTError:
        return None

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    """Get current authenticated user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token_data = verify_token(credentials.credentials)
    if token_data is None:
        raise credentials_exception
    
    # Get user from database
    result = await db.execute(select(User).where(User.id == token_data.user_id))
    user = result.scalar_one_or_none()
    
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    return user

async def get_current_admin(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> AdminUser:
    """Get current authenticated admin user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate admin credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token_data = verify_token(credentials.credentials)
    if token_data is None or token_data.user_type != "admin":
        raise credentials_exception
    
    # Get admin from database
    result = await db.execute(select(AdminUser).where(AdminUser.id == token_data.user_id))
    admin = result.scalar_one_or_none()
    
    if admin is None:
        raise credentials_exception
    
    if not admin.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive admin user"
        )
    
    return admin

async def get_current_busker(
    current_user: User = Depends(get_current_user)
) -> User:
    """Get current authenticated busker"""
    if current_user.user_type != "busker":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized as busker"
        )
    return current_user

def check_admin_permission(required_permission: str):
    """Check if admin has required permission"""
    def permission_checker(current_admin: AdminUser = Depends(get_current_admin)):
        if current_admin.role == "super_admin":
            return current_admin  # Super admin has all permissions
        
        permissions = current_admin.permissions or []
        if required_permission not in permissions:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permission denied: {required_permission}"
            )
        return current_admin
    return permission_checker

async def create_default_admin():
    """Create default admin user if not exists"""
    from app.core.database import AsyncSessionLocal
    from app.models.user import AdminUser
    
    async with AsyncSessionLocal() as db:
        # Check if admin exists
        result = await db.execute(
            select(AdminUser).where(AdminUser.email == settings.DEFAULT_ADMIN_EMAIL)
        )
        existing_admin = result.scalar_one_or_none()
        
        if not existing_admin:
            # Create default admin
            admin = AdminUser(
                email=settings.DEFAULT_ADMIN_EMAIL,
                password_hash=get_password_hash(settings.DEFAULT_ADMIN_PASSWORD),
                full_name="Super Admin",
                role="super_admin",
                is_active=True,
                permissions=[
                    "users.read", "users.write", "users.delete",
                    "buskers.read", "buskers.write", "buskers.delete", "buskers.verify",
                    "bookings.read", "bookings.write", "bookings.delete", "bookings.verify",
                    "events.read", "events.write", "events.delete", "events.publish",
                    "pods.read", "pods.write", "pods.delete",
                    "admins.read", "admins.write", "admins.delete",
                    "analytics.read", "system.manage"
                ]
            )
            db.add(admin)
            await db.commit()
            print(f"✅ Default admin created: {settings.DEFAULT_ADMIN_EMAIL}")
        else:
            print(f"ℹ️  Default admin already exists: {settings.DEFAULT_ADMIN_EMAIL}")