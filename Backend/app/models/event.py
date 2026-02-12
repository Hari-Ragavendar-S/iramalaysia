from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, ForeignKey, JSON, Enum, DECIMAL, Date, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.core.database import Base

class Event(Base):
    __tablename__ = "events"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(Text, nullable=True)
    venue = Column(String(255), nullable=False)
    city = Column(String(255), nullable=False, index=True)
    address = Column(Text, nullable=True)
    event_date = Column(Date, nullable=False, index=True)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    ticket_price = Column(DECIMAL(10, 2), nullable=True)
    max_capacity = Column(Integer, nullable=True)
    current_bookings = Column(Integer, default=0)
    category = Column(String(100), nullable=True, index=True)
    is_published = Column(Boolean, default=False, index=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey("admin_users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    bookings = relationship("EventBooking", back_populates="event")
    created_by_admin = relationship("AdminUser", foreign_keys=[created_by])

class EventBooking(Base):
    __tablename__ = "event_bookings"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    booking_reference = Column(String(50), unique=True, nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id"), nullable=False, index=True)
    tickets_count = Column(Integer, default=1)
    total_amount = Column(DECIMAL(10, 2), nullable=False)
    status = Column(String(50), default='pending', index=True)
    payment_method = Column(String(50), nullable=True)
    payment_reference = Column(String(255), nullable=True)
    payment_screenshot_url = Column(Text, nullable=True)
    payment_verified_at = Column(DateTime(timezone=True), nullable=True)
    payment_verified_by = Column(UUID(as_uuid=True), ForeignKey("admin_users.id"), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User")
    event = relationship("Event", back_populates="bookings")
    verified_by_admin = relationship("AdminUser", foreign_keys=[payment_verified_by])