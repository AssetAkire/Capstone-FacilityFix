from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List
from enum import Enum
from datetime import datetime
import re

class UserRole(str, Enum):
    ADMIN = "admin"
    STAFF = "staff"
    TENANT = "tenant"

class UserStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    SUSPENDED = "suspended"

class StaffClassification(str, Enum):
    MAINTENANCE = "maintenance"
    CARPENTRY = "carpentry"
    PLUMBING = "plumbing"
    ELECTRICAL = "electrical"
    MASONRY = "masonry"

class BuildingCode(str, Enum):
    A = "A"
    B = "B"
    C = "C"

class AdminCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)

class StaffCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)
    staff_id: Optional[str] = None 
    classification: StaffClassification
    phone_number: Optional[str] = None

class TenantCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)
    building_unit: str = Field(..., description="Format: A-00010 (buildings A, B, C only)")
    phone_number: Optional[str] = None

    @validator('building_unit', pre=True)
    def validate_building_unit(cls, v: str) -> str:
        # Normalize: trim + UPPERCASE
        if not isinstance(v, str):
            raise ValueError('Building unit must be a string')
        s = v.strip().upper()

        # Accept 1–5 digits after the hyphen, then zero-pad to 5
        # e.g. A-10 -> A-00010; requires hyphen and building A/B/C
        m = re.match(r'^([ABC])-(\d{1,5})$', s)
        if not m:
            raise ValueError("Building unit must be in format A-00010 (A/B/C only, 1–5 digits).")

        building = m.group(1)
        unit_num = m.group(2).zfill(5)  # zero-pad to 5 digits
        return f"{building}-{unit_num}"

class UserLogin(BaseModel):
    identifier: str = Field(..., description="Email or User ID (e.g., T-0001)")
    password: str

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    role: UserRole
    building_id: Optional[str] = None
    unit_id: Optional[str] = None
    department: Optional[str] = None
    # New fields for role-specific data
    staff_id: Optional[str] = None
    classification: Optional[StaffClassification] = None
    building_unit: Optional[str] = None
    
class UserResponse(BaseModel):
    uid: str
    user_id: str  # Custom user ID like T-0001, S-0001, A-0001
    email: str
    first_name: str
    last_name: str
    role: UserRole
    phone_number: Optional[str] = None
    building_id: Optional[str] = None
    unit_id: Optional[str] = None
    department: Optional[str] = None
    # Role-specific fields
    staff_id: Optional[str] = None
    classification: Optional[StaffClassification] = None
    building_unit: Optional[str] = None
    status: Optional[UserStatus] = UserStatus.ACTIVE
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    department: Optional[str] = None
    building_id: Optional[str] = None
    unit_id: Optional[str] = None
    classification: Optional[StaffClassification] = None
    building_unit: Optional[str] = None

    @validator('building_unit')
    def validate_building_unit(cls, v):
        if v is not None:
            pattern = r'^[ABC]-\d{2}$'
            if not re.match(pattern, v):
                raise ValueError('Building unit must be in format A-01, B-15, or C-23')
            return v.upper()
        return v

class UserStatusUpdate(BaseModel):
    status: UserStatus

class PasswordChange(BaseModel):
    new_password: str = Field(..., min_length=6, description="New password (minimum 6 characters)")

class UserSearchFilters(BaseModel):
    role: Optional[UserRole] = None
    building_id: Optional[str] = None
    status: Optional[UserStatus] = None
    department: Optional[str] = None
    search_term: Optional[str] = Field(None, description="Search in name, email, or department")

class UserListResponse(BaseModel):
    users: List[UserResponse]
    total_count: int
    page: int
    page_size: int
    total_pages: int

class BulkUserOperation(BaseModel):
    user_ids: List[str]
    operation: str # "activate", "deactivate", "delete"

class UserStatistics(BaseModel):
    total_users: int
    by_role: dict
    by_status: dict
    by_building: dict
    recent_registrations: int # in the last 30 days

class UserProfileComplete(BaseModel):
    """Complete user profile with Firebase and Firestore data"""
    uid: str
    user_id: str  # Added custom user ID field
    email: str
    email_verified: bool
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    role: UserRole
    status: UserStatus
    building_id: Optional[str] = None
    unit_id: Optional[str] = None
    department: Optional[str] = None
    staff_id: Optional[str] = None
    classification: Optional[StaffClassification] = None
    building_unit: Optional[str] = None
    last_sign_in: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    firebase_metadata: Optional[dict] = None