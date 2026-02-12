from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload
from typing import Optional, List
from datetime import date, datetime
import uuid
import secrets
import string

from app.core.database import get_db
from app.core.security import get_current_user, get_current_admin
from app.models.user import User
from app.models.pod import Pod, PodBooking, BookingStatus
from app.schemas.pod import (
    PodCreate,
    PodUpdate,
    PodResponse,
    PodListResponse,
    PodSearchFilters,
    PodBookingCreate,
    PodBookingUpdate,
    PodBookingResponse,
    PodAvailability,
    BookingVerification,
    BookingListResponse
)
from app.services.email_service import send_email
from app.services.sms_service import send_booking_sms

router = APIRouter()

def generate_booking_reference() -> str:
    """Generate unique booking reference"""
    return 'BOOK' + ''.join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(6))

@router.get("/", response_model=PodListResponse)
async def get_pods(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    city: Optional[str] = None,
    mall: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    db: AsyncSession = Depends(get_db)
):
    """Get list of available pods"""
    query = select(Pod).where(Pod.is_active == True)
    
    # Apply filters
    if city:
        query = query.where(Pod.city.ilike(f"%{city}%"))
    if mall:
        query = query.where(Pod.mall.ilike(f"%{mall}%"))
    if min_price:
        query = query.where(Pod.price_per_hour >= min_price)
    if max_price:
        query = query.where(Pod.price_per_hour <= max_price)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination
    offset = (page - 1) * per_page
    query = query.offset(offset).limit(per_page)
    
    result = await db.execute(query)
    pods = result.scalars().all()
    
    return PodListResponse(
        pods=[PodResponse.from_orm(pod) for pod in pods],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/search", response_model=PodListResponse)
async def search_pods(
    q: str = Query(..., min_length=1),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """Search pods by name, city, or mall"""
    query = select(Pod).where(
        and_(
            Pod.is_active == True,
            or_(
                Pod.name.ilike(f"%{q}%"),
                Pod.city.ilike(f"%{q}%"),
                Pod.mall.ilike(f"%{q}%"),
                Pod.description.ilike(f"%{q}%")
            )
        )
    )
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination
    offset = (page - 1) * per_page
    query = query.offset(offset).limit(per_page)
    
    result = await db.execute(query)
    pods = result.scalars().all()
    
    return PodListResponse(
        pods=[PodResponse.from_orm(pod) for pod in pods],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/{pod_id}", response_model=PodResponse)
async def get_pod(
    pod_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get pod details"""
    result = await db.execute(select(Pod).where(Pod.id == pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    return PodResponse.from_orm(pod)

@router.get("/{pod_id}/availability")
async def get_pod_availability(
    pod_id: str,
    date: str = Query(..., description="Date in YYYY-MM-DD format"),
    db: AsyncSession = Depends(get_db)
):
    """Get pod availability for a specific date - Updated for Flutter compatibility"""
    from datetime import datetime
    
    # Parse date string
    try:
        check_date = datetime.strptime(date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid date format. Use YYYY-MM-DD"
        )
    
    # Check if pod exists
    result = await db.execute(select(Pod).where(Pod.id == pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    # Get existing bookings for the date
    result = await db.execute(
        select(PodBooking).where(
            and_(
                PodBooking.pod_id == pod_id,
                PodBooking.booking_date == check_date,
                PodBooking.status.in_(['confirmed', 'pending'])
            )
        )
    )
    bookings = result.scalars().all()
    
    # Extract booked time slots
    booked_slots = []
    for booking in bookings:
        booked_slots.extend(booking.time_slots)
    
    # Generate available slots (9 AM to 9 PM)
    all_slots = []
    for hour in range(9, 21):  # 9 AM to 9 PM
        all_slots.append({
            "start": f"{hour:02d}:00",
            "end": f"{hour+1:02d}:00",
            "price": float(pod.price_per_hour)
        })
    
    # Filter out booked slots
    available_slots = []
    for slot in all_slots:
        is_booked = any(
            booked_slot.get('start') == slot['start'] and booked_slot.get('end') == slot['end']
            for booked_slot in booked_slots
        )
        if not is_booked:
            available_slots.append(slot)
    
    return {
        "date": check_date.isoformat(),
        "available_slots": available_slots,
        "booked_slots": booked_slots
    }

@router.post("/bookings", response_model=PodBookingResponse)
async def create_booking(
    booking_data: PodBookingCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create a new pod booking - Updated to match Flutter expectations"""
    # Check if pod exists
    result = await db.execute(select(Pod).where(Pod.id == booking_data.pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    # Get location if location_id provided
    location = None
    if hasattr(booking_data, 'location_id') and booking_data.location_id:
        from app.models.location import BuskingLocation
        result = await db.execute(select(BuskingLocation).where(BuskingLocation.id == booking_data.location_id))
        location = result.scalar_one_or_none()
    
    # Check availability
    result = await db.execute(
        select(PodBooking).where(
            and_(
                PodBooking.pod_id == booking_data.pod_id,
                PodBooking.booking_date == booking_data.booking_date,
                PodBooking.status.in_(['confirmed', 'pending'])
            )
        )
    )
    existing_bookings = result.scalars().all()
    
    # Check for time slot conflicts
    for existing_booking in existing_bookings:
        for existing_slot in existing_booking.time_slots:
            for new_slot in booking_data.time_slots:
                if (existing_slot.get('start') == new_slot.start and 
                    existing_slot.get('end') == new_slot.end):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Time slot {new_slot.start}-{new_slot.end} is already booked"
                    )
    
    # Calculate total amount
    total_amount = sum(slot.price for slot in booking_data.time_slots)
    
    # Create booking with location data
    booking = PodBooking(
        booking_reference=generate_booking_reference(),
        user_id=current_user.id,
        pod_id=booking_data.pod_id,
        location_id=location.id if location else None,
        mall_id=str(location.id) if location else None,
        mall_name=location.location_name if location else pod.mall,
        state=location.state if location else None,
        city=location.city if location else pod.city,
        full_address=location.full_address if location else pod.address,
        busking_area_description=location.busking_area_description if location else None,
        booking_date=booking_data.booking_date,
        time_slots=[slot.dict() for slot in booking_data.time_slots],
        total_amount=total_amount,
        payment_method=booking_data.payment_method,
        notes=booking_data.notes
    )
    
    db.add(booking)
    await db.commit()
    await db.refresh(booking)
    
    # Load pod relationship
    result = await db.execute(
        select(PodBooking).options(selectinload(PodBooking.pod))
        .where(PodBooking.id == booking.id)
    )
    booking_with_pod = result.scalar_one()
    
    # Send confirmation email
    try:
        time_slots_str = ", ".join([f"{slot['start']}-{slot['end']}" for slot in booking.time_slots])
        location_name = location.location_name if location else pod.name
        mall_city = f"{booking.mall_name}, {booking.city}" if booking.mall_name and booking.city else f"{pod.mall}, {pod.city}"
        
        await send_email(
            to_email=current_user.email,
            subject="Booking Confirmation - Irama1Asia",
            template="booking_confirmation",
            context={
                "name": current_user.full_name,
                "booking_reference": booking.booking_reference,
                "pod_name": location_name,
                "mall": mall_city,
                "city": booking.city or pod.city,
                "booking_date": booking.booking_date.strftime("%B %d, %Y"),
                "time_slots": time_slots_str,
                "total_amount": f"{total_amount:.2f}"
            }
        )
        
        # Send SMS if phone number available
        if current_user.phone:
            await send_booking_sms(
                to_phone=current_user.phone,
                booking_reference=booking.booking_reference,
                pod_name=location_name,
                booking_date=booking.booking_date.strftime("%B %d, %Y")
            )
    except Exception as e:
        # Don't fail booking if email/SMS fails
        print(f"Failed to send confirmation: {e}")
    
    return PodBookingResponse.from_orm(booking_with_pod)

# Add simplified booking endpoint for Flutter compatibility
@router.post("/bookings/simple")
async def create_simple_booking(
    pod_id: str,
    start_time: str,  # ISO datetime string
    end_time: str,    # ISO datetime string
    total_amount: float,
    notes: str = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Create booking with simplified Flutter structure"""
    from datetime import datetime
    
    # Parse datetime strings
    try:
        start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid datetime format"
        )
    
    # Check if pod exists
    result = await db.execute(select(Pod).where(Pod.id == pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    # Create time slot from start/end times
    time_slot = {
        "start": start_dt.strftime("%H:%M"),
        "end": end_dt.strftime("%H:%M"),
        "price": total_amount
    }
    
    # Create booking
    booking = PodBooking(
        booking_reference=generate_booking_reference(),
        user_id=current_user.id,
        pod_id=pod_id,
        booking_date=start_dt.date(),
        time_slots=[time_slot],
        total_amount=total_amount,
        payment_method="upi",
        notes=notes
    )
    
    db.add(booking)
    await db.commit()
    await db.refresh(booking)
    
    # Load pod relationship
    result = await db.execute(
        select(PodBooking).options(selectinload(PodBooking.pod))
        .where(PodBooking.id == booking.id)
    )
    booking_with_pod = result.scalar_one()
    
    return PodBookingResponse.from_orm(booking_with_pod)

@router.get("/bookings", response_model=BookingListResponse)
async def get_user_bookings(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's bookings"""
    query = select(PodBooking).options(selectinload(PodBooking.pod)).where(
        PodBooking.user_id == current_user.id
    )
    
    if status:
        query = query.where(PodBooking.status == status)
    
    # Get total count
    count_query = select(func.count()).where(PodBooking.user_id == current_user.id)
    if status:
        count_query = count_query.where(PodBooking.status == status)
    
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(PodBooking.created_at.desc()).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    bookings = result.scalars().all()
    
    return BookingListResponse(
        bookings=[PodBookingResponse.from_orm(booking) for booking in bookings],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/bookings/{booking_id}", response_model=PodBookingResponse)
async def get_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get specific booking"""
    result = await db.execute(
        select(PodBooking).options(selectinload(PodBooking.pod)).where(
            and_(
                PodBooking.id == booking_id,
                PodBooking.user_id == current_user.id
            )
        )
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    return PodBookingResponse.from_orm(booking)

@router.put("/bookings/{booking_id}/cancel")
async def cancel_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Cancel a booking"""
    result = await db.execute(
        select(PodBooking).where(
            and_(
                PodBooking.id == booking_id,
                PodBooking.user_id == current_user.id
            )
        )
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    if booking.status == BookingStatus.CANCELLED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Booking is already cancelled"
        )
    
    if booking.status == BookingStatus.COMPLETED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot cancel completed booking"
        )
    
    # Check if booking is within cancellation window (24 hours before)
    booking_datetime = datetime.combine(booking.booking_date, datetime.min.time())
    if datetime.now() >= booking_datetime - timedelta(hours=24):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot cancel booking within 24 hours of scheduled time"
        )
    
    booking.status = BookingStatus.CANCELLED
    await db.commit()
    
    return {"message": "Booking cancelled successfully"}

@router.post("/bookings/{booking_id}/payment-proof")
async def upload_payment_proof(
    booking_id: str,
    payment_screenshot_url: str,
    payment_reference: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload payment proof for booking"""
    result = await db.execute(
        select(PodBooking).where(
            and_(
                PodBooking.id == booking_id,
                PodBooking.user_id == current_user.id
            )
        )
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    booking.payment_screenshot_url = payment_screenshot_url
    if payment_reference:
        booking.payment_reference = payment_reference
    
    await db.commit()
    
    return {"message": "Payment proof uploaded successfully"}