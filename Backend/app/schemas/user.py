from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone: Optional[str] = None

class UserCreate(UserBase):
    password: str
    user_type: str = "user"

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    profile_image_url: Optional[str] = None

class UserResponse(UserBase):
    id: str
    user_type: str
    is_active: bool
    is_verified: bool
    profile_image_url: Optional[str]
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime]
    
    class Config:
        from_attributes = True

class UserListResponse(BaseModel):
    users: List[UserResponse]
    total: int
    page: int
    per_page: int
    pages: int

class BuskerRegister(BaseModel):
    stage_name: Optional[str] = None
    bio: Optional[str] = None
    genres: Optional[List[str]] = None
    experience_years: Optional[int] = None
    cities_performed: Optional[List[str]] = None

class BuskerUpdate(BaseModel):
    stage_name: Optional[str] = None
    bio: Optional[str] = None
    genres: Optional[List[str]] = None
    experience_years: Optional[int] = None
    cities_performed: Optional[List[str]] = None
    is_available: Optional[bool] = None

class BuskerProfile(BaseModel):
    id: str
    user_id: str
    stage_name: Optional[str]
    bio: Optional[str]
    genres: Optional[List[str]]
    experience_years: Optional[int]
    id_proof_url: Optional[str]
    id_proof_type: Optional[str]
    verification_status: str
    verification_notes: Optional[str]
    total_shows: int
    average_rating: float
    cities_performed: Optional[List[str]]
    is_available: bool
    created_at: datetime
    updated_at: datetime
    
    # User data
    user: UserResponse
    
    class Config:
        from_attributes = True

class BuskerVerification(BaseModel):
    status: str  # "approved" or "rejected"
    notes: Optional[str] = None

class AdminUserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    role: str = "admin"
    permissions: Optional[List[str]] = None

class AdminUserUpdate(BaseModel):
    full_name: Optional[str] = None
    role: Optional[str] = None
    permissions: Optional[List[str]] = None
    is_active: Optional[bool] = None

class AdminUserResponse(BaseModel):
    id: str
    email: str
    full_name: str
    role: str
    permissions: Optional[List[str]]
    is_active: bool
    created_by: Optional[str]
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime]
    
    class Config:
        from_attributes = True