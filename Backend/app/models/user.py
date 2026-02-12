from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, ForeignKey, JSON, Enum, DECIMAL
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.core.database import Base

class UserType(str, enum.Enum):
    USER = "user"
    BUSKER = "busker"

class AdminRole(str, enum.Enum):
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"

class VerificationStatus(str, enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class IDProofType(str, enum.Enum):
    IC = "ic"
    PASSPORT = "passport"
    DRIVING_LICENSE = "driving_license"

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20), unique=True, nullable=True, index=True)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    profile_image_url = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    user_type = Column(Enum(UserType), default=UserType.USER, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    busker_profile = relationship("Busker", back_populates="user", uselist=False)
    bookings = relationship("PodBooking", back_populates="user")

class AdminUser(Base):
    __tablename__ = "admin_users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(Enum(AdminRole), default=AdminRole.ADMIN, index=True)
    permissions = Column(JSON, nullable=True)
    is_active = Column(Boolean, default=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey("admin_users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    created_by_admin = relationship("AdminUser", remote_side=[id])

class Busker(Base):
    __tablename__ = "buskers"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    stage_name = Column(String(255), nullable=True)
    bio = Column(Text, nullable=True)
    genres = Column(JSON, nullable=True)  # ['acoustic', 'pop', 'rock']
    experience_years = Column(Integer, nullable=True)
    id_proof_url = Column(Text, nullable=True)
    id_proof_type = Column(Enum(IDProofType), nullable=True)
    verification_status = Column(Enum(VerificationStatus), default=VerificationStatus.PENDING, index=True)
    verification_notes = Column(Text, nullable=True)
    total_shows = Column(Integer, default=0)
    average_rating = Column(DECIMAL(3, 2), default=0.00)
    cities_performed = Column(JSON, nullable=True)  # ['Kuala Lumpur', 'Penang']
    is_available = Column(Boolean, default=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="busker_profile")

class OTPVerification(Base):
    __tablename__ = "otp_verifications"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=True, index=True)
    phone = Column(String(20), nullable=True, index=True)
    otp_code = Column(String(6), nullable=False, index=True)
    otp_type = Column(Enum("email_verification", "phone_verification", "password_reset", name="otp_type_enum"), nullable=False)
    is_used = Column(Boolean, default=False)
    expires_at = Column(DateTime(timezone=True), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class FileUpload(Base):
    __tablename__ = "file_uploads"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    original_filename = Column(String(255), nullable=False)
    stored_filename = Column(String(255), nullable=False, index=True)
    file_path = Column(Text, nullable=False)
    file_size = Column(Integer, nullable=True)
    mime_type = Column(String(100), nullable=True)
    uploaded_by = Column(UUID(as_uuid=True), nullable=True, index=True)
    upload_type = Column(Enum("profile_image", "id_proof", "payment_screenshot", "event_image", "pod_image", name="upload_type_enum"), nullable=True, index=True)
    is_processed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())