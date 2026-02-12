from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import datetime

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone: Optional[str] = None
    user_type: str = "user"
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class AdminLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int

class TokenData(BaseModel):
    user_id: Optional[str] = None
    email: Optional[str] = None
    user_type: Optional[str] = None
    role: Optional[str] = None

class RefreshToken(BaseModel):
    refresh_token: str

class PasswordReset(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    email: EmailStr
    otp_code: str
    new_password: str
    
    @validator('new_password')
    def validate_password(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long')
        return v

class OTPVerification(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    otp_code: str
    otp_type: str

class OTPRequest(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    otp_type: str

class UserProfile(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    user_type: str
    is_active: bool
    is_verified: bool
    profile_image_url: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class AdminProfile(BaseModel):
    id: str
    email: str
    full_name: str
    role: str
    permissions: Optional[List[str]]
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class UserProfile(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    profile_image_url: Optional[str]
    user_type: str
    is_verified: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class AdminProfile(BaseModel):
    id: str
    email: str
    full_name: str
    role: str
    permissions: Optional[list]
    is_active: bool
    created_at: datetime
    last_login: Optional[datetime]
    
    class Config:
        from_attributes = True