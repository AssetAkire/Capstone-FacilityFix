from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum

# Building Model
class Building(BaseModel):
    id: Optional[str] = None
    building_name: str
    address: str
    total_floors: int
    total_units: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Unit Model
class Unit(BaseModel):
    id: Optional[str] = None
    building_id: str
    unit_number: str
    floor_number: int
    occupancy_status: str = Field(default="vacant") # occupied, vacant, maintenance
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Equipment Model
class Equipment(BaseModel):
    id: Optional[str] = None
    building_id: str
    equipment_name: str
    equipment_type: str  # HVAC, elevator, fire_safety, etc.
    model_number: Optional[str] = None
    serial_number: Optional[str] = None
    location: str
    department: Optional[str] = None
    status: str = Field(default="active")  # active, under_repair, inactive
    is_critical: bool = Field(default=False)
    date_added: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Inventory Model
class Inventory(BaseModel):
    id: Optional[str] = None
    building_id: str
    item_name: str
    department: str
    classification: str  # consumable, equipment, tool
    current_stock: int
    reorder_level: int
    unit_of_measure: str  # pcs, liters, kg, etc.
    date_added: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Repair Request Model
class RepairRequest(BaseModel):
    id: Optional[str] = None
    reported_by: str  # user_id
    unit_id: Optional[str] = None
    assigned_to: Optional[str] = None  # user_id
    title: str
    description: str
    location: str
    classification: str  # electrical, plumbing, hvac, etc.
    priority: str = Field(default="medium")  # low, medium, high, critical
    status: str = Field(default="open")  # open, in_progress, resolved, closed
    attachments: Optional[List[str]] = []  # file URLs
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Maintenance Task Model
class MaintenanceTask(BaseModel):
    id: Optional[str] = None
    equipment_id: Optional[str] = None
    assigned_to: str  # user_id
    location: str
    task_description: str
    status: str = Field(default="scheduled")  # scheduled, in_progress, completed, on_hold
    scheduled_date: datetime
    completed_date: Optional[datetime] = None
    recurrence_type: str = Field(default="none")  # none, weekly, monthly, quarterly, yearly
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Announcement Model
class Announcement(BaseModel):
    id: Optional[str] = None
    created_by: str  # user_id
    building_id: str
    title: str
    content: str
    type: str = Field(default="general")  # maintenance, reminder, event, general
    audience: str = Field(default="all")  # tenants, staff, all
    location_affected: Optional[str] = None
    is_active: bool = Field(default=True)
    date_added: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Work Order Permit Model
class WorkOrderPermit(BaseModel):
    id: Optional[str] = None
    user_id: str
    unit_id: str
    date_requested: datetime
    full_name: str
    account_type: str  # owner, tenant, contractor
    specific_instructions: str
    status: str = Field(default="pending")  # pending, approved, denied
    approved_by: Optional[str] = None
    approval_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# User Profile Model (extends Firebase Auth)
class UserProfile(BaseModel):
    id: Optional[str] = None  # Firebase UID
    building_id: Optional[str] = None
    unit_id: Optional[str] = None
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    department: Optional[str] = None
    role: str  # admin, staff, tenant
    status: str = Field(default="active")  # active, suspended, inactive
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Work Order Model
class WorkOrder(BaseModel):
    id: Optional[str] = None
    request_id: str  # Links to repair_request
    created_by: str  # admin user_id
    assigned_to: Optional[str] = None  # staff/contractor user_id
    work_type: str = Field(default="job_service")  # job_service (in-house) or work_permit (3rd party)
    status: str = Field(default="unassigned")  # unassigned, assigned, in_progress, completed, closed
    scheduled_date: Optional[datetime] = None
    completed_date: Optional[datetime] = None
    estimated_hours: Optional[float] = None
    actual_hours: Optional[float] = None
    materials_used: Optional[List[str]] = []
    cost: Optional[float] = None
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Status History Model (for tracking work order status changes)
class StatusHistory(BaseModel):
    id: Optional[str] = None
    work_order_id: str
    previous_status: Optional[str] = None
    new_status: str
    updated_by: str  # user_id who made the change
    remarks: Optional[str] = None
    timestamp: Optional[datetime] = None

# Feedback Model (for tenant feedback on completed work)
class Feedback(BaseModel):
    id: Optional[str] = None
    work_order_id: str
    request_id: str  # Links back to original repair request
    submitted_by: str  # tenant user_id
    rating: int = Field(ge=1, le=5)  # 1-5 star rating
    comments: Optional[str] = None
    service_quality: Optional[int] = Field(default=None, ge=1, le=5)
    timeliness: Optional[int] = Field(default=None, ge=1, le=5)
    communication: Optional[int] = Field(default=None, ge=1, le=5)
    would_recommend: Optional[bool] = None
    submitted_at: Optional[datetime] = None