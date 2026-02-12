from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, ForeignKey, JSON, Enum, DECIMAL, Date, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.core.database import Base

class BookingStatus(str, enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class PaymentStatus(str, enum.Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"

class Pod(Base):
    __tablename__ = "pods"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    mall = Column(String(255), nullable=False, index=True)
    city = Column(String(255), nullable=False, index=True)
    address = Column(Text, nullable=False)
    images = Column(JSON, nullable=True)  # ['url1', 'url2', 'url3']
    amenities = Column(JSON, nullable=True)  # ['microphone', 'speakers', 'lighting']
    price_per_hour = Column(DECIMAL(10, 2), nullable=False, index=True)
    capacity = Column(Integer, nullable=True)
    is_active = Column(Boolean, default=True, index=True)
    rating = Column(DECIMAL(3, 2), default=0.00)
    review_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    bookings = relationship("PodBooking", back_populates="pod")

class PodBooking(Base):
    __tablename__ = "pod_bookings"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    booking_reference = Column(String(50), unique=True, nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    pod_id = Column(UUID(as_uuid=True), ForeignKey("pods.id"), nullable=False, index=True)
    location_id = Column(UUID(as_uuid=True), ForeignKey("busking_locations.id"), nullable=True, index=True)
    
    # Location details (denormalized for performance)
    mall_id = Column(String(100), nullable=True)
    mall_name = Column(String(255), nullable=True)
    state = Column(String(100), nullable=True)
    city = Column(String(100), nullable=True)
    full_address = Column(Text, nullable=True)
    busking_area_description = Column(Text, nullable=True)
    
    booking_date = Column(Date, nullable=False, index=True)
    time_slots = Column(JSON, nullable=False)  # [{'start': '10:00', 'end': '11:00', 'price': 100}]
    total_amount = Column(DECIMAL(10, 2), nullable=False)
    status = Column(Enum(BookingStatus), default=BookingStatus.PENDING, index=True)
    
    # Payment details
    payment_method = Column(String(50), nullable=True)
    payment_reference = Column(String(255), nullable=True)
    payment_screenshot_url = Column(Text, nullable=True)
    payment_proof_url = Column(Text, nullable=True)
    payment_status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING, index=True)
    payment_uploaded_at = Column(DateTime(timezone=True), nullable=True)
    payment_verified_at = Column(DateTime(timezone=True), nullable=True)
    payment_verified_by = Column(UUID(as_uuid=True), ForeignKey("admin_users.id"), nullable=True)
    
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="bookings")
    pod = relationship("Pod", back_populates="bookings")
    location = relationship("BuskingLocation", back_populates="bookings")
    verified_by_admin = relationship("AdminUser")