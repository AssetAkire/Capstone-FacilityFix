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

# Concern Slip Model
class ConcernSlip(BaseModel):
    id: Optional[str] = None
    reported_by: str  # user_id (tenant)
    unit_id: Optional[str] = None
    title: str
    description: str
    location: str
    category: str  # electrical, plumbing, hvac, carpentry, maintenance, security, fire_safety, general
    priority: str = Field(default="medium")  # low, medium, high, critical
    status: str = Field(default="pending")  # pending, evaluated, approved, rejected
    urgency_assessment: Optional[str] = None  # Admin's evaluation notes
    resolution_type: Optional[str] = None  # job_service, work_permit, rejected
    attachments: Optional[List[str]] = []  # file URLs
    admin_notes: Optional[str] = None
    evaluated_by: Optional[str] = None  # admin user_id
    evaluated_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# JobService Model (modified from WorkOrder)
class JobService(BaseModel):
    id: Optional[str] = None
    concern_slip_id: str  # Links to concern_slip
    created_by: str  # admin user_id
    assigned_to: Optional[str] = None  # internal staff user_id
    title: str
    description: str
    location: str
    category: str
    priority: str
    status: str = Field(default="assigned")  # assigned, in_progress, completed, closed
    scheduled_date: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    estimated_hours: Optional[float] = None
    actual_hours: Optional[float] = None
    materials_used: Optional[List[str]] = []
    staff_notes: Optional[str] = None
    completion_notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class WorkOrderPermit(BaseModel):
    id: Optional[str] = None
    concern_slip_id: str  # Links to concern_slip
    requested_by: str  # tenant user_id
    unit_id: str
    contractor_name: str
    contractor_contact: str
    contractor_company: Optional[str] = None
    work_description: str
    proposed_start_date: datetime
    estimated_duration: str  # e.g., "2 hours", "1 day"
    specific_instructions: str
    entry_requirements: Optional[str] = None  # Special access needs
    status: str = Field(default="pending")  # pending, approved, denied, completed
    approved_by: Optional[str] = None  # admin user_id
    approval_date: Optional[datetime] = None
    denial_reason: Optional[str] = None
    permit_conditions: Optional[str] = None  # Special conditions for approval
    actual_start_date: Optional[datetime] = None
    actual_completion_date: Optional[datetime] = None
    admin_notes: Optional[str] = None
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

# Notification Model for system-wide notifications
class Notification(BaseModel):
    id: Optional[str] = None
    recipient_id: str  # user_id
    sender_id: Optional[str] = None  # user_id or system
    title: str
    message: str
    notification_type: str  # concern_update, job_assigned, permit_approved, etc.
    related_id: Optional[str] = None  # concern_slip_id, job_service_id, or work_permit_id
    is_read: bool = Field(default=False)
    created_at: Optional[datetime] = None

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
    concern_slip_id: str  # Links back to original concern slip
    service_id: Optional[str] = None  # Links to job_service_id or work_permit_id
    service_type: str  # "job_service" or "work_permit"
    submitted_by: str  # tenant user_id
    rating: int = Field(ge=1, le=5)  # 1-5 star rating
    comments: Optional[str] = None
    service_quality: Optional[int] = Field(default=None, ge=1, le=5)
    timeliness: Optional[int] = Field(default=None, ge=1, le=5)
    communication: Optional[int] = Field(default=None, ge=1, le=5)
    would_recommend: Optional[bool] = None
    submitted_at: Optional[datetime] = None