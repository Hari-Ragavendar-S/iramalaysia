from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, distinct
from typing import List, Dict, Any

from app.core.database import get_db
from app.models.location import BuskingLocation
from app.schemas.location import (
    BuskingLocationResponse,
    LocationsByState,
    LocationsByCity,
    LocationsGrouped
)

router = APIRouter()

@router.get("/states", response_model=List[str])
async def get_states(
    db: AsyncSession = Depends(get_db)
):
    """Get all available states"""
    result = await db.execute(
        select(distinct(BuskingLocation.state))
        .where(BuskingLocation.is_active == True)
        .order_by(BuskingLocation.state)
    )
    states = result.scalars().all()
    return list(states)

@router.get("/cities/{state}", response_model=List[str])
async def get_cities_by_state(
    state: str,
    db: AsyncSession = Depends(get_db)
):
    """Get cities by state"""
    result = await db.execute(
        select(distinct(BuskingLocation.city))
        .where(
            BuskingLocation.state == state,
            BuskingLocation.is_active == True
        )
        .order_by(BuskingLocation.city)
    )
    cities = result.scalars().all()
    return list(cities)

@router.get("/locations/{state}/{city}", response_model=List[BuskingLocationResponse])
async def get_locations_by_city(
    state: str,
    city: str,
    db: AsyncSession = Depends(get_db)
):
    """Get locations by state and city"""
    result = await db.execute(
        select(BuskingLocation)
        .where(
            BuskingLocation.state == state,
            BuskingLocation.city == city,
            BuskingLocation.is_active == True
        )
        .order_by(BuskingLocation.location_name)
    )
    locations = result.scalars().all()
    return [BuskingLocationResponse.from_orm(location) for location in locations]

@router.get("/grouped", response_model=Dict[str, Any])
async def get_locations_grouped(
    db: AsyncSession = Depends(get_db)
):
    """Get all locations grouped by state and city"""
    result = await db.execute(
        select(BuskingLocation)
        .where(BuskingLocation.is_active == True)
        .order_by(BuskingLocation.state, BuskingLocation.city, BuskingLocation.location_name)
    )
    locations = result.scalars().all()
    
    # Group by state and city
    grouped = {}
    for location in locations:
        if location.state not in grouped:
            grouped[location.state] = {}
        if location.city not in grouped[location.state]:
            grouped[location.state][location.city] = []
        grouped[location.state][location.city].append(BuskingLocationResponse.from_orm(location))
    
    return grouped

@router.get("/{location_id}", response_model=BuskingLocationResponse)
async def get_location(
    location_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Get specific location details"""
    result = await db.execute(
        select(BuskingLocation).where(BuskingLocation.id == location_id)
    )
    location = result.scalar_one_or_none()
    
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Location not found"
        )
    
    return BuskingLocationResponse.from_orm(location)