from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, date, time
from decimal import Decimal

class EventBase(BaseModel):
    title: str
    description: Optional[str] = None
    venue: str
    city: str
    address: Optional[str] = None
    event_date: date
    start_time: time
    end_time: time
    ticket_price: Optional[Decimal] = None
    max_capacity: Optional[int] = None
    category: Optional[str] = None

class EventCreate(EventBase):
    image_url: Optional[str] = None

class EventUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    venue: Optional[str] = None
    city: Optional[str] = None
    address: Optional[str] = None
    event_date: Optional[date] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    ticket_price: Optional[Decimal] = None
    max_capacity: Optional[int] = None
    category: Optional[str] = None
    is_published: Optional[bool] = None

class EventResponse(EventBase):
    id: str
    image_url: Optional[str]
    current_bookings: int
    is_published: bool
    created_by: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class EventListResponse(BaseModel):
    events: List[EventResponse]
    total: int
    page: int
    per_page: int
    pages: int