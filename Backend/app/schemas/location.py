from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class BuskingLocationBase(BaseModel):
    location_name: str
    location_type: str
    state: str
    city: str
    full_address: str
    indoor_outdoor: str
    busking_area_description: str
    crowd_type: str
    suitable_for_busking: str
    remarks: Optional[str] = None

class BuskingLocationCreate(BuskingLocationBase):
    pass

class BuskingLocationUpdate(BaseModel):
    location_name: Optional[str] = None
    location_type: Optional[str] = None
    state: Optional[str] = None
    city: Optional[str] = None
    full_address: Optional[str] = None
    indoor_outdoor: Optional[str] = None
    busking_area_description: Optional[str] = None
    crowd_type: Optional[str] = None
    suitable_for_busking: Optional[str] = None
    remarks: Optional[str] = None
    is_active: Optional[bool] = None

class BuskingLocationResponse(BuskingLocationBase):
    id: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class LocationsByState(BaseModel):
    state: str
    cities: List[str]

class LocationsByCity(BaseModel):
    state: str
    city: str
    locations: List[BuskingLocationResponse]

class LocationsGrouped(BaseModel):
    data: Dict[str, Dict[str, List[BuskingLocationResponse]]]