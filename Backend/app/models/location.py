from sqlalchemy import Column, String, Boolean, DateTime, Text, Integer, ForeignKey, JSON, Enum, DECIMAL
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
import enum
from app.core.database import Base

class LocationType(str, enum.Enum):
    SHOPPING_MALL = "Shopping Mall"
    OUTDOOR_SPACE = "Outdoor Space"
    COMMUNITY_CENTER = "Community Center"

class IndoorOutdoor(str, enum.Enum):
    INDOOR = "Indoor"
    OUTDOOR = "Outdoor"

class BuskingLocation(Base):
    __tablename__ = "busking_locations"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    location_name = Column(String(255), nullable=False)
    location_type = Column(String(100), nullable=False)  # Shopping Mall, etc.
    state = Column(String(100), nullable=False, index=True)
    city = Column(String(100), nullable=False, index=True)
    full_address = Column(Text, nullable=False)
    indoor_outdoor = Column(String(20), nullable=False)  # Indoor/Outdoor
    busking_area_description = Column(Text, nullable=False)
    crowd_type = Column(String(255), nullable=False)
    suitable_for_busking = Column(String(10), nullable=False)  # Yes/No
    remarks = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    bookings = relationship("PodBooking", back_populates="location")