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

class Inventory(BaseModel):
    id: Optional[str] = None
    building_id: str
    item_name: str
    item_code: Optional[str] = None  # SKU or barcode
    department: str
    classification: str  # consumable, equipment, tool, spare_part
    category: Optional[str] = None  # electrical, plumbing, hvac, general
    current_stock: int
    reorder_level: int
    max_stock_level: Optional[int] = None
    unit_of_measure: str  # pcs, liters, kg, etc.
    unit_cost: Optional[float] = None
    supplier_name: Optional[str] = None
    supplier_contact: Optional[str] = None
    storage_location: Optional[str] = None
    description: Optional[str] = None
    is_critical: bool = Field(default=False)
    is_active: bool = Field(default=True)
    last_restocked_date: Optional[datetime] = None
    expiry_date: Optional[datetime] = None
    date_added: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class InventoryTransaction(BaseModel):
    id: Optional[str] = None
    inventory_id: str
    transaction_type: str  # in, out, adjustment, transfer
    quantity: int  # positive for in/adjustment up, negative for out/adjustment down
    previous_stock: int
    new_stock: int
    reference_type: Optional[str] = None  # job_service, work_permit, maintenance_task, manual
    reference_id: Optional[str] = None  # ID of the related work order/task
    performed_by: str  # user_id who performed the transaction
    reason: Optional[str] = None
    notes: Optional[str] = None
    cost_per_unit: Optional[float] = None
    total_cost: Optional[float] = None
    created_at: Optional[datetime] = None

class InventoryRequest(BaseModel):
    id: Optional[str] = None
    inventory_id: str
    requested_by: str  # user_id
    approved_by: Optional[str] = None  # admin user_id
    quantity_requested: int
    quantity_approved: Optional[int] = None
    purpose: str  # job_service, maintenance, emergency, etc.
    reference_id: Optional[str] = None  # job_service_id or maintenance_task_id
    priority: str = Field(default="normal")  # low, normal, high, urgent
    status: str = Field(default="pending")  # pending, approved, denied, fulfilled, cancelled
    justification: Optional[str] = None
    admin_notes: Optional[str] = None
    requested_date: Optional[datetime] = None
    approved_date: Optional[datetime] = None
    fulfilled_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class LowStockAlert(BaseModel):
    id: Optional[str] = None
    inventory_id: str
    building_id: str
    item_name: str
    current_stock: int
    reorder_level: int
    alert_level: str  # low, critical, out_of_stock
    status: str = Field(default="active")  # active, acknowledged, resolved
    acknowledged_by: Optional[str] = None  # admin user_id
    acknowledged_at: Optional[datetime] = None
    resolved_at: Optional[datetime] = None
    created_at: Optional[datetime] = None

class InventoryUsageAnalytics(BaseModel):
    id: Optional[str] = None
    inventory_id: str
    building_id: str
    period_start: datetime
    period_end: datetime
    period_type: str  # daily, weekly, monthly, quarterly, yearly
    total_consumed: int
    total_restocked: int
    average_daily_usage: float
    peak_usage_date: Optional[datetime] = None
    peak_usage_amount: Optional[int] = None
    cost_consumed: Optional[float] = None
    cost_restocked: Optional[float] = None
    stockout_days: Optional[int] = None  # days when stock was zero
    created_at: Optional[datetime] = None

# Concern Slip Model
class ConcernSlip(BaseModel):
    id: Optional[str] = None
    formatted_id: Optional[str] = None  # e.g., "CS-2025-00001"
    reported_by: str  # user_id (tenant)
    unit_id: Optional[str] = None
    title: str
    description: str
    location: str
    category: str  # electrical, plumbing, hvac, carpentry, maintenance, security, fire_safety, general
    priority: str = Field(default="medium")  # low, medium, high, critical
    status: str = Field(default="pending")  # pending, evaluated, approved, rejected, assigned, assessed, returned_to_tenant
    urgency_assessment: Optional[str] = None  # Admin's evaluation notes
    resolution_type: Optional[str] = None  # job_service, work_permit, rejected
    attachments: Optional[List[str]] = []  # file URLs
    admin_notes: Optional[str] = None
    evaluated_by: Optional[str] = None  # admin user_id
    evaluated_at: Optional[datetime] = None
    assigned_to: Optional[str] = None  # staff user_id assigned for assessment
    assigned_at: Optional[datetime] = None
    staff_assessment: Optional[str] = None  # Staff's assessment text
    staff_recommendation: Optional[str] = None  # Staff's recommendation
    assessment_attachments: Optional[List[str]] = []  # Assessment file URLs
    assessed_by: Optional[str] = None  # staff user_id who did assessment
    assessed_at: Optional[datetime] = None
    returned_to_tenant_at: Optional[datetime] = None
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
    schedule_id: Optional[str] = None  # Links to MaintenanceSchedule
    template_id: Optional[str] = None  # Links to MaintenanceTemplate
    equipment_id: Optional[str] = None
    building_id: str
    assigned_to: Optional[str] = None  # user_id
    
    # Task details
    task_title: str
    task_description: str
    location: str
    category: str = Field(default="preventive")  # preventive, corrective, emergency
    priority: str = Field(default="medium")  # low, medium, high, critical
    
    # Scheduling information
    task_type: str = Field(default="scheduled")  # scheduled, recurring, on_demand
    scheduled_date: datetime
    scheduled_time_slot: Optional[str] = None  # "09:00-12:00"
    estimated_duration: Optional[int] = None  # in minutes
    
    # Execution tracking
    status: str = Field(default="scheduled")  # scheduled, assigned, in_progress, completed, cancelled, overdue
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    actual_duration: Optional[int] = None  # in minutes
    
    # Recurrence handling
    recurrence_type: str = Field(default="none")  # none, weekly, monthly, quarterly, yearly, custom
    parent_task_id: Optional[str] = None  # for recurring tasks
    next_occurrence: Optional[datetime] = None
    
    # Resource tracking
    parts_used: Optional[List[dict]] = []  # [{"inventory_id": "...", "quantity": 2}]
    tools_used: Optional[List[str]] = []
    
    # Documentation
    completion_notes: Optional[str] = None
    checklist_completed: Optional[List[dict]] = []  # completed checklist items
    photos: Optional[List[str]] = []  # photo URLs
    signature: Optional[str] = None  # signature data or URL
    
    # Quality and feedback
    quality_rating: Optional[int] = Field(default=None, ge=1, le=5)
    feedback_notes: Optional[str] = None
    
    # Metadata
    created_by: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Maintenance Schedule Model
class MaintenanceSchedule(BaseModel):
    id: Optional[str] = None
    equipment_id: str
    building_id: str
    schedule_name: str
    description: str
    schedule_type: str = Field(default="time_based")  # time_based, usage_based, condition_based
    
    # Time-based scheduling
    recurrence_pattern: Optional[str] = None  # daily, weekly, monthly, quarterly, yearly, custom
    interval_value: Optional[int] = None  # e.g., every 2 weeks, every 3 months
    specific_days: Optional[List[str]] = []  # for weekly: ["monday", "friday"]
    specific_dates: Optional[List[int]] = []  # for monthly: [1, 15] (1st and 15th)
    
    # Usage-based scheduling
    usage_threshold: Optional[int] = None  # trigger after X hours/cycles/uses
    usage_unit: Optional[str] = None  # hours, cycles, uses, kilometers, etc.
    
    # Condition-based scheduling (future enhancement)
    condition_parameters: Optional[dict] = {}  # sensor thresholds, performance metrics
    
    # Task details
    estimated_duration: Optional[int] = None  # in minutes
    required_skills: Optional[List[str]] = []  # required technician skills
    required_parts: Optional[List[str]] = []  # inventory item IDs needed
    safety_requirements: Optional[List[str]] = []  # safety protocols
    
    # Scheduling preferences
    preferred_time_slots: Optional[List[str]] = []  # ["09:00-12:00", "14:00-17:00"]
    blackout_periods: Optional[List[dict]] = []  # periods when maintenance shouldn't occur
    
    # Status and metadata
    is_active: bool = Field(default=True)
    priority: str = Field(default="medium")  # low, medium, high, critical
    created_by: str
    last_generated: Optional[datetime] = None
    next_due_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Equipment Usage Log Model
class EquipmentUsageLog(BaseModel):
    id: Optional[str] = None
    equipment_id: str
    building_id: str
    usage_type: str  # runtime_hours, cycles, uses, distance, etc.
    usage_value: float  # actual usage amount
    usage_unit: str  # hours, cycles, uses, km, etc.
    recorded_by: Optional[str] = None  # user_id or "system" for automatic logging
    recording_method: str = Field(default="manual")  # manual, sensor, calculated
    notes: Optional[str] = None
    recorded_at: datetime
    created_at: Optional[datetime] = None

# Maintenance Template Model
class MaintenanceTemplate(BaseModel):
    id: Optional[str] = None
    template_name: str
    equipment_type: str  # HVAC, elevator, fire_safety, etc.
    category: str  # preventive, corrective, emergency
    description: str
    
    # Task checklist
    checklist_items: List[dict]  # [{"item": "Check oil level", "required": true, "type": "checkbox"}]
    
    # Resource requirements
    estimated_duration: int  # in minutes
    required_skills: List[str]
    required_tools: Optional[List[str]] = []
    required_parts: Optional[List[str]] = []  # inventory item IDs
    safety_requirements: List[str]
    
    # Documentation requirements
    photo_required: bool = Field(default=False)
    signature_required: bool = Field(default=True)
    report_template: Optional[str] = None
    
    # Metadata
    created_by: str
    is_active: bool = Field(default=True)
    version: str = Field(default="1.0")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

# Maintenance Report Model
class MaintenanceReport(BaseModel):
    id: Optional[str] = None
    building_id: str
    report_type: str  # daily, weekly, monthly, quarterly, yearly, custom
    period_start: datetime
    period_end: datetime
    
    # Summary statistics
    total_tasks_scheduled: int
    total_tasks_completed: int
    total_tasks_overdue: int
    completion_rate: float  # percentage
    average_completion_time: Optional[float] = None  # in hours
    
    # Equipment breakdown
    equipment_maintenance_summary: List[dict]  # per equipment type statistics
    
    # Cost analysis
    total_labor_hours: Optional[float] = None
    total_parts_cost: Optional[float] = None
    estimated_total_cost: Optional[float] = None
    
    # Compliance tracking
    compliance_rate: float  # percentage of tasks completed on time
    overdue_tasks: List[dict]  # details of overdue tasks
    
    # Trends and insights
    maintenance_trends: Optional[dict] = {}  # trend analysis data
    recommendations: Optional[List[str]] = []  # system-generated recommendations
    
    # Metadata
    generated_by: str  # user_id or "system"
    generated_at: datetime
    created_at: Optional[datetime] = None

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

# Counter model for ID generation
class Counter(BaseModel):
    id: Optional[str] = None
    year: int
    counter: int
    last_updated: Optional[datetime] = None
