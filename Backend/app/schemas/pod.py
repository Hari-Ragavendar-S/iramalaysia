from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from datetime import datetime, date, time
from decimal import Decimal

class PodBase(BaseModel):
    name: str
    description: Optional[str] = None
    mall: str
    city: str
    address: str
    price_per_hour: Decimal
    capacity: Optional[int] = None

class PodCreate(PodBase):
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None

class PodUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    mall: Optional[str] = None
    city: Optional[str] = None
    address: Optional[str] = None
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None
    price_per_hour: Optional[Decimal] = None
    capacity: Optional[int] = None
    is_active: Optional[bool] = None

class PodResponse(PodBase):
    id: str
    images: Optional[List[str]]
    amenities: Optional[List[str]]
    is_active: bool
    rating: Decimal
    review_count: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class PodSearchFilters(BaseModel):
    city: Optional[str] = None
    mall: Optional[str] = None
    min_price: Optional[Decimal] = None
    max_price: Optional[Decimal] = None
    amenities: Optional[List[str]] = None
    capacity: Optional[int] = None

class PodListResponse(BaseModel):
    pods: List[PodResponse]
    total: int
    page: int
    per_page: int
    pages: int

class TimeSlot(BaseModel):
    start: str  # "10:00"
    end: str    # "11:00"
    price: Decimal
    
    @validator('start', 'end')
    def validate_time_format(cls, v):
        try:
            time.fromisoformat(v)
        except ValueError:
            raise ValueError('Time must be in HH:MM format')
        return v

class PodBookingCreate(BaseModel):
    pod_id: str
    location_id: Optional[str] = None
    booking_date: date
    time_slots: List[TimeSlot]
    payment_method: str = "upi"
    notes: Optional[str] = None
    
    @validator('booking_date')
    def validate_future_date(cls, v):
        if v <= date.today():
            raise ValueError('Booking date must be in the future')
        return v

class PodBookingUpdate(BaseModel):
    status: Optional[str] = None
    payment_reference: Optional[str] = None
    payment_screenshot_url: Optional[str] = None
    notes: Optional[str] = None

class PodBookingResponse(BaseModel):
    id: str
    booking_reference: str
    user_id: str
    pod_id: str
    location_id: Optional[str]
    mall_id: Optional[str]
    mall_name: Optional[str]
    state: Optional[str]
    city: Optional[str]
    full_address: Optional[str]
    busking_area_description: Optional[str]
    booking_date: date
    time_slots: List[Dict[str, Any]]
    total_amount: Decimal
    status: str
    payment_method: Optional[str]
    payment_reference: Optional[str]
    payment_screenshot_url: Optional[str]
    payment_proof_url: Optional[str]
    payment_status: Optional[str]
    payment_uploaded_at: Optional[datetime]
    payment_verified_at: Optional[datetime]
    payment_verified_by: Optional[str]
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    # Related data
    pod: PodResponse
    
    class Config:
        from_attributes = True

class PodAvailability(BaseModel):
    date: date
    available_slots: List[Dict[str, Any]]
    booked_slots: List[Dict[str, Any]]

class BookingVerification(BaseModel):
    status: str  # "verified" or "rejected"
    notes: Optional[str] = None
    
    @validator('status')
    def validate_status(cls, v):
        if v not in ['verified', 'rejected']:
            raise ValueError('Status must be verified or rejected')
        return v

class BookingListResponse(BaseModel):
    bookings: List[PodBookingResponse]
    total: int
    page: int
    per_page: int
    pages: int