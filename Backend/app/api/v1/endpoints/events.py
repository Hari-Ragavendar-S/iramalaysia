from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from typing import Optional, List
from datetime import date

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.event import Event, EventBooking
from app.schemas.event import EventResponse, EventListResponse

router = APIRouter()

@router.get("/", response_model=EventListResponse)
async def get_events(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    city: Optional[str] = None,
    category: Optional[str] = None,
    from_date: Optional[date] = None,
    db: AsyncSession = Depends(get_db)
):
    """Get list of published events"""
    query = select(Event).where(Event.is_published == True)
    
    # Apply filters
    if city:
        query = query.where(Event.city.ilike(f"%{city}%"))
    if category:
        query = query.where(Event.category == category)
    if from_date:
        query = query.where(Event.event_date >= from_date)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(Event.event_date.asc()).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    events = result.scalars().all()
    
    return EventListResponse(
        events=[EventResponse.from_orm(event) for event in events],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/search", response_model=EventListResponse)
async def search_events(
    q: str = Query(..., min_length=1),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """Search events by title, venue, or city"""
    query = select(Event).where(
        and_(
            Event.is_published == True,
            or_(
                Event.title.ilike(f"%{q}%"),
                Event.venue.ilike(f"%{q}%"),
                Event.city.ilike(f"%{q}%"),
                Event.description.ilike(f"%{q}%")
            )
        )
    )
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination
    offset = (page - 1) * per_page
    query = query.order_by(Event.event_date.asc()).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    events = result.scalars().all()
    
    return EventListResponse(
        events=[EventResponse.from_orm(event) for event in events],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get event details"""
    result = await db.execute(
        select(Event).where(
            and_(Event.id == event_id, Event.is_published == True)
        )
    )
    event = result.scalar_one_or_none()
    
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    
    return EventResponse.from_orm(event)

@router.post("/{event_id}/book")
async def book_event(
    event_id: str,
    tickets_count: int = 1,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Book event tickets"""
    # Check if event exists and is published
    result = await db.execute(
        select(Event).where(
            and_(Event.id == event_id, Event.is_published == True)
        )
    )
    event = result.scalar_one_or_none()
    
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    
    # Check capacity
    if event.max_capacity and (event.current_bookings + tickets_count) > event.max_capacity:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not enough tickets available"
        )
    
    # Calculate total amount
    total_amount = (event.ticket_price or 0) * tickets_count
    
    # Create booking
    booking = EventBooking(
        booking_reference='EVT' + ''.join(__import__('secrets').choice(__import__('string').ascii_uppercase + __import__('string').digits) for _ in range(6)),
        user_id=current_user.id,
        event_id=event_id,
        tickets_count=tickets_count,
        total_amount=total_amount,
        status='pending'
    )
    
    db.add(booking)
    
    # Update event booking count
    event.current_bookings += tickets_count
    
    await db.commit()
    await db.refresh(booking)
    
    return {
        "message": "Event booked successfully",
        "booking_reference": booking.booking_reference,
        "tickets_count": tickets_count,
        "total_amount": float(total_amount)
    }

@router.get("/bookings/my-bookings")
async def get_my_event_bookings(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's event bookings"""
    query = select(EventBooking).where(EventBooking.user_id == current_user.id)
    
    # Get total count
    count_query = select(func.count()).where(EventBooking.user_id == current_user.id)
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(EventBooking.created_at.desc()).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    bookings = result.scalars().all()
    
    return {
        "bookings": [
            {
                "id": str(booking.id),
                "booking_reference": booking.booking_reference,
                "event_id": str(booking.event_id),
                "tickets_count": booking.tickets_count,
                "total_amount": float(booking.total_amount),
                "status": booking.status,
                "created_at": booking.created_at.isoformat()
            }
            for booking in bookings
        ],
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }