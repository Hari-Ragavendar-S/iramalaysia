from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc
from sqlalchemy.orm import selectinload
from typing import Optional, List, Dict, Any
from datetime import datetime, date, timedelta
from decimal import Decimal

from app.core.database import get_db
from app.core.security import get_current_admin, check_admin_permission, get_password_hash
from app.models.user import User, AdminUser, Busker
from app.models.pod import Pod, PodBooking, BookingStatus, PaymentStatus
from app.models.event import Event, EventBooking
from app.schemas.user import (
    UserResponse,
    UserListResponse,
    BuskerProfile,
    BuskerVerification,
    AdminUserCreate,
    AdminUserUpdate,
    AdminUserResponse
)
from app.schemas.pod import (
    PodCreate,
    PodUpdate,
    PodResponse,
    PodListResponse,
    PodBookingResponse,
    BookingListResponse,
    BookingVerification
)
from app.schemas.event import (
    EventCreate,
    EventUpdate,
    EventResponse,
    EventListResponse
)

router = APIRouter()

# Dashboard & Analytics
@router.get("/dashboard/stats")
async def get_dashboard_stats(
    current_admin: AdminUser = Depends(check_admin_permission("analytics.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get dashboard statistics"""
    # Total users
    total_users_result = await db.execute(select(func.count(User.id)))
    total_users = total_users_result.scalar()
    
    # Active users (logged in within last 30 days)
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)
    active_users_result = await db.execute(
        select(func.count(User.id)).where(User.last_login >= thirty_days_ago)
    )
    active_users = active_users_result.scalar()
    
    # Total buskers
    total_buskers_result = await db.execute(select(func.count(Busker.id)))
    total_buskers = total_buskers_result.scalar()
    
    # Active buskers
    active_buskers_result = await db.execute(
        select(func.count(Busker.id)).where(
            and_(Busker.is_available == True, Busker.verification_status == "approved")
        )
    )
    active_buskers = active_buskers_result.scalar()
    
    # Total bookings
    total_bookings_result = await db.execute(select(func.count(PodBooking.id)))
    total_bookings = total_bookings_result.scalar()
    
    # Total revenue
    total_revenue_result = await db.execute(
        select(func.sum(PodBooking.total_amount)).where(
            PodBooking.status == BookingStatus.CONFIRMED
        )
    )
    total_revenue = total_revenue_result.scalar() or Decimal('0.00')
    
    # Total events
    total_events_result = await db.execute(select(func.count(Event.id)))
    total_events = total_events_result.scalar()
    
    # Published events
    published_events_result = await db.execute(
        select(func.count(Event.id)).where(Event.is_published == True)
    )
    published_events = published_events_result.scalar()
    
    return {
        "total_users": total_users,
        "active_users": active_users,
        "total_buskers": total_buskers,
        "active_buskers": active_buskers,
        "total_bookings": total_bookings,
        "total_revenue": float(total_revenue),
        "total_events": total_events,
        "published_events": published_events
    }

# Booking Management
@router.get("/bookings", response_model=BookingListResponse)
async def get_all_bookings(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    payment_status: Optional[str] = None,
    current_admin: AdminUser = Depends(check_admin_permission("bookings.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get all bookings with pagination and filters"""
    query = select(PodBooking).options(
        selectinload(PodBooking.user),
        selectinload(PodBooking.pod)
    )
    
    if status:
        query = query.where(PodBooking.status == status)
    if payment_status:
        query = query.where(PodBooking.payment_status == payment_status)
    
    # Get total count
    count_query = select(func.count(PodBooking.id))
    if status:
        count_query = count_query.where(PodBooking.status == status)
    if payment_status:
        count_query = count_query.where(PodBooking.payment_status == payment_status)
    
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination
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

@router.put("/bookings/{booking_id}/verify")
async def verify_booking_payment(
    booking_id: str,
    verification: BookingVerification,
    current_admin: AdminUser = Depends(check_admin_permission("bookings.verify")),
    db: AsyncSession = Depends(get_db)
):
    """Verify booking payment proof"""
    result = await db.execute(
        select(PodBooking).options(
            selectinload(PodBooking.user),
            selectinload(PodBooking.pod)
        ).where(PodBooking.id == booking_id)
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Update payment status
    if verification.status == "verified":
        booking.payment_status = PaymentStatus.VERIFIED
        booking.status = BookingStatus.CONFIRMED
        booking.payment_verified_at = datetime.utcnow()
        booking.payment_verified_by = current_admin.id
        status_message = "Payment verified and booking confirmed"
    elif verification.status == "rejected":
        booking.payment_status = PaymentStatus.REJECTED
        booking.status = BookingStatus.CANCELLED
        status_message = "Payment rejected and booking cancelled"
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification status"
        )
    
    await db.commit()
    
    # Send email notification to user
    try:
        await send_email(
            to_email=booking.user.email,
            subject=f"Booking {verification.status.title()} - Irama1Asia",
            template="booking_status_update",
            context={
                "name": booking.user.full_name,
                "booking_reference": booking.booking_reference,
                "status": verification.status,
                "pod_name": booking.pod.name if booking.pod else "Pod",
                "notes": verification.notes or ""
            }
        )
    except Exception as e:
        print(f"Failed to send status update email: {e}")
    
    return {
        "message": status_message,
        "booking_id": str(booking.id),
        "booking_reference": booking.booking_reference,
        "status": booking.status,
        "payment_status": booking.payment_status
    }
        "published_events": published_events
    }

# User Management
@router.get("/users", response_model=UserListResponse)
async def get_all_users(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    user_type: Optional[str] = None,
    is_active: Optional[bool] = None,
    current_admin: AdminUser = Depends(check_admin_permission("users.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get all users with pagination and filters"""
    query = select(User)
    
    # Apply filters
    if search:
        query = query.where(
            or_(
                User.full_name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%")
            )
        )
    
    if user_type:
        query = query.where(User.user_type == user_type)
    
    if is_active is not None:
        query = query.where(User.is_active == is_active)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(desc(User.created_at)).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    users = result.scalars().all()
    
    return UserListResponse(
        users=[UserResponse.from_orm(user) for user in users],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("users.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get specific user"""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserResponse.from_orm(user)

@router.put("/users/{user_id}/suspend")
async def suspend_user(
    user_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("users.write")),
    db: AsyncSession = Depends(get_db)
):
    """Suspend user account"""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    user.is_active = False
    await db.commit()
    
    return {"message": "User suspended successfully"}

@router.put("/users/{user_id}/activate")
async def activate_user(
    user_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("users.write")),
    db: AsyncSession = Depends(get_db)
):
    """Activate user account"""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    user.is_active = True
    await db.commit()
    
    return {"message": "User activated successfully"}

# Busker Management
@router.get("/buskers")
async def get_all_buskers(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    verification_status: Optional[str] = None,
    is_available: Optional[bool] = None,
    current_admin: AdminUser = Depends(check_admin_permission("buskers.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get all buskers with pagination and filters"""
    query = select(Busker).options(selectinload(Busker.user))
    
    # Apply filters
    if verification_status:
        query = query.where(Busker.verification_status == verification_status)
    
    if is_available is not None:
        query = query.where(Busker.is_available == is_available)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(desc(Busker.created_at)).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    buskers = result.scalars().all()
    
    return {
        "buskers": [BuskerProfile.from_orm(busker) for busker in buskers],
        "total": total,
        "page": page,
        "per_page": per_page,
        "pages": (total + per_page - 1) // per_page
    }

@router.get("/buskers/pending")
async def get_pending_buskers(
    current_admin: AdminUser = Depends(check_admin_permission("buskers.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get buskers pending verification"""
    result = await db.execute(
        select(Busker).options(selectinload(Busker.user)).where(
            Busker.verification_status == "pending"
        ).order_by(Busker.created_at)
    )
    buskers = result.scalars().all()
    
    return [BuskerProfile.from_orm(busker) for busker in buskers]

@router.put("/buskers/{busker_id}/verify")
async def verify_busker(
    busker_id: str,
    verification_data: BuskerVerification,
    current_admin: AdminUser = Depends(check_admin_permission("buskers.verify")),
    db: AsyncSession = Depends(get_db)
):
    """Verify or reject busker"""
    result = await db.execute(select(Busker).where(Busker.id == busker_id))
    busker = result.scalar_one_or_none()
    
    if not busker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Busker not found"
        )
    
    busker.verification_status = verification_data.verification_status
    busker.verification_notes = verification_data.verification_notes
    
    await db.commit()
    
    return {"message": f"Busker {verification_data.verification_status} successfully"}

# Booking Management
@router.get("/bookings", response_model=BookingListResponse)
async def get_all_bookings(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    current_admin: AdminUser = Depends(check_admin_permission("bookings.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get all bookings with pagination and filters"""
    query = select(PodBooking).options(
        selectinload(PodBooking.pod),
        selectinload(PodBooking.user)
    )
    
    # Apply filters
    if status:
        query = query.where(PodBooking.status == status)
    
    if date_from:
        query = query.where(PodBooking.booking_date >= date_from)
    
    if date_to:
        query = query.where(PodBooking.booking_date <= date_to)
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Apply pagination and ordering
    offset = (page - 1) * per_page
    query = query.order_by(desc(PodBooking.created_at)).offset(offset).limit(per_page)
    
    result = await db.execute(query)
    bookings = result.scalars().all()
    
    return BookingListResponse(
        bookings=[PodBookingResponse.from_orm(booking) for booking in bookings],
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@router.put("/bookings/{booking_id}/verify")
async def verify_booking_payment(
    booking_id: str,
    verification_data: BookingVerification,
    current_admin: AdminUser = Depends(check_admin_permission("bookings.verify")),
    db: AsyncSession = Depends(get_db)
):
    """Verify booking payment"""
    result = await db.execute(
        select(PodBooking).options(
            selectinload(PodBooking.user),
            selectinload(PodBooking.pod)
        ).where(PodBooking.id == booking_id)
    )
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    from app.models.pod import PaymentStatus
    
    if verification_data.status == "confirmed":
        booking.status = BookingStatus.CONFIRMED
        booking.payment_status = PaymentStatus.VERIFIED
        booking.payment_verified_at = datetime.utcnow()
        booking.payment_verified_by = current_admin.id
    elif verification_data.status == "rejected":
        booking.status = BookingStatus.CANCELLED
        booking.payment_status = PaymentStatus.REJECTED
        booking.payment_verified_at = datetime.utcnow()
        booking.payment_verified_by = current_admin.id
    
    if verification_data.verification_notes:
        booking.notes = verification_data.verification_notes
    
    await db.commit()
    
    # Send notification email to user
    if booking.user:
        status_text = "approved" if verification_data.status == "confirmed" else "rejected"
        await send_email(
            to_email=booking.user.email,
            subject=f"Booking Payment {status_text.title()} - Irama1Asia",
            template="booking_status_update",
            context={
                "name": booking.user.full_name,
                "booking_reference": booking.booking_reference,
                "status": status_text,
                "mall_name": booking.mall_name or booking.pod.mall,
                "city": booking.city or booking.pod.city,
                "booking_date": booking.booking_date.strftime("%B %d, %Y"),
                "notes": verification_data.verification_notes or ""
            }
        )
    
    return {"message": f"Booking payment {verification_data.status} successfully"}

# Pod Management
@router.post("/pods", response_model=PodResponse)
async def create_pod(
    pod_data: PodCreate,
    current_admin: AdminUser = Depends(check_admin_permission("pods.write")),
    db: AsyncSession = Depends(get_db)
):
    """Create new pod"""
    pod = Pod(**pod_data.dict())
    db.add(pod)
    await db.commit()
    await db.refresh(pod)
    
    return PodResponse.from_orm(pod)

@router.put("/pods/{pod_id}", response_model=PodResponse)
async def update_pod(
    pod_id: str,
    pod_data: PodUpdate,
    current_admin: AdminUser = Depends(check_admin_permission("pods.write")),
    db: AsyncSession = Depends(get_db)
):
    """Update pod"""
    result = await db.execute(select(Pod).where(Pod.id == pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    # Update fields
    for field, value in pod_data.dict(exclude_unset=True).items():
        setattr(pod, field, value)
    
    await db.commit()
    await db.refresh(pod)
    
    return PodResponse.from_orm(pod)

@router.delete("/pods/{pod_id}")
async def delete_pod(
    pod_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("pods.delete")),
    db: AsyncSession = Depends(get_db)
):
    """Delete pod"""
    result = await db.execute(select(Pod).where(Pod.id == pod_id))
    pod = result.scalar_one_or_none()
    
    if not pod:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pod not found"
        )
    
    # Soft delete by marking as inactive
    pod.is_active = False
    await db.commit()
    
    return {"message": "Pod deleted successfully"}

# Event Management
@router.post("/events", response_model=EventResponse)
async def create_event(
    event_data: EventCreate,
    current_admin: AdminUser = Depends(check_admin_permission("events.write")),
    db: AsyncSession = Depends(get_db)
):
    """Create new event"""
    event = Event(
        **event_data.dict(),
        created_by=current_admin.id
    )
    db.add(event)
    await db.commit()
    await db.refresh(event)
    
    return EventResponse.from_orm(event)

@router.put("/events/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: str,
    event_data: EventUpdate,
    current_admin: AdminUser = Depends(check_admin_permission("events.write")),
    db: AsyncSession = Depends(get_db)
):
    """Update event"""
    result = await db.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    
    # Update fields
    for field, value in event_data.dict(exclude_unset=True).items():
        setattr(event, field, value)
    
    await db.commit()
    await db.refresh(event)
    
    return EventResponse.from_orm(event)

@router.post("/events/{event_id}/publish")
async def publish_event(
    event_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("events.publish")),
    db: AsyncSession = Depends(get_db)
):
    """Publish event"""
    result = await db.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    
    if not event:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found"
        )
    
    event.is_published = True
    await db.commit()
    
    return {"message": "Event published successfully"}

# Admin User Management
@router.get("/admins", response_model=List[AdminUserResponse])
async def get_all_admins(
    current_admin: AdminUser = Depends(check_admin_permission("admins.read")),
    db: AsyncSession = Depends(get_db)
):
    """Get all admin users"""
    result = await db.execute(select(AdminUser).order_by(AdminUser.created_at))
    admins = result.scalars().all()
    
    return [AdminUserResponse.from_orm(admin) for admin in admins]

@router.post("/admins", response_model=AdminUserResponse)
async def create_admin(
    admin_data: AdminUserCreate,
    current_admin: AdminUser = Depends(check_admin_permission("admins.write")),
    db: AsyncSession = Depends(get_db)
):
    """Create new admin user"""
    # Check if email already exists
    result = await db.execute(select(AdminUser).where(AdminUser.email == admin_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    admin = AdminUser(
        email=admin_data.email,
        password_hash=get_password_hash(admin_data.password),
        full_name=admin_data.full_name,
        role=admin_data.role,
        permissions=admin_data.permissions,
        created_by=current_admin.id
    )
    
    db.add(admin)
    await db.commit()
    await db.refresh(admin)
    
    return AdminUserResponse.from_orm(admin)

@router.put("/admins/{admin_id}", response_model=AdminUserResponse)
async def update_admin(
    admin_id: str,
    admin_data: AdminUserUpdate,
    current_admin: AdminUser = Depends(check_admin_permission("admins.write")),
    db: AsyncSession = Depends(get_db)
):
    """Update admin user"""
    result = await db.execute(select(AdminUser).where(AdminUser.id == admin_id))
    admin = result.scalar_one_or_none()
    
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Admin not found"
        )
    
    # Update fields
    for field, value in admin_data.dict(exclude_unset=True).items():
        setattr(admin, field, value)
    
    await db.commit()
    await db.refresh(admin)
    
    return AdminUserResponse.from_orm(admin)

@router.delete("/admins/{admin_id}")
async def delete_admin(
    admin_id: str,
    current_admin: AdminUser = Depends(check_admin_permission("admins.delete")),
    db: AsyncSession = Depends(get_db)
):
    """Delete admin user"""
    if str(current_admin.id) == admin_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own admin account"
        )
    
    result = await db.execute(select(AdminUser).where(AdminUser.id == admin_id))
    admin = result.scalar_one_or_none()
    
    if not admin:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Admin not found"
        )
    
    await db.delete(admin)
    await db.commit()
    
    return {"message": "Admin deleted successfully"}