from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
from app.models.database_models import JobService
from app.services.job_service_service import JobServiceService
from app.auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/job-services", tags=["job-services"])

# Request Models
class CreateJobServiceRequest(BaseModel):
    concern_slip_id: str
    title: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    category: Optional[str] = None
    priority: Optional[str] = None
    assigned_to: Optional[str] = None
    scheduled_date: Optional[datetime] = None
    estimated_hours: Optional[float] = None

class AssignJobServiceRequest(BaseModel):
    assigned_to: str

class UpdateJobStatusRequest(BaseModel):
    status: str
    notes: Optional[str] = None

class AddNotesRequest(BaseModel):
    notes: str

@router.post("/", response_model=JobService)
async def create_job_service(
    request: CreateJobServiceRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Create a new job service from an approved concern slip (Admin only)"""
    try:
        service = JobServiceService()
        job_service = await service.create_job_service(
            concern_slip_id=request.concern_slip_id,
            created_by=current_user["uid"],
            job_data=request.dict(exclude_unset=True)
        )
        return job_service
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create job service: {str(e)}")

@router.patch("/{job_service_id}/assign", response_model=JobService)
async def assign_job_service(
    job_service_id: str,
    request: AssignJobServiceRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Assign job service to internal staff (Admin only)"""
    try:
        service = JobServiceService()
        job_service = await service.assign_job_service(
            job_service_id=job_service_id,
            assigned_to=request.assigned_to,
            assigned_by=current_user["uid"]
        )
        return job_service
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to assign job service: {str(e)}")

@router.patch("/{job_service_id}/status", response_model=JobService)
async def update_job_status(
    job_service_id: str,
    request: UpdateJobStatusRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"]))
):
    """Update job service status (Admin and assigned Staff only)"""
    try:
        service = JobServiceService()
        job_service = await service.update_job_status(
            job_service_id=job_service_id,
            status=request.status,
            updated_by=current_user["uid"],
            notes=request.notes
        )
        return job_service
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update job status: {str(e)}")

@router.post("/{job_service_id}/notes", response_model=JobService)
async def add_work_notes(
    job_service_id: str,
    request: AddNotesRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"]))
):
    """Add work notes to job service (Admin and assigned Staff only)"""
    try:
        service = JobServiceService()
        job_service = await service.add_work_notes(
            job_service_id=job_service_id,
            notes=request.notes,
            added_by=current_user["uid"]
        )
        return job_service
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add notes: {str(e)}")

@router.get("/{job_service_id}", response_model=JobService)
async def get_job_service(
    job_service_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff", "tenant"]))
):
    """Get job service by ID"""
    try:
        service = JobServiceService()
        job_service = await service.get_job_service(job_service_id)
        if not job_service:
            raise HTTPException(status_code=404, detail="Job service not found")
        return job_service
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get job service: {str(e)}")

@router.get("/staff/{staff_id}", response_model=List[JobService])
async def get_job_services_by_staff(
    staff_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"]))
):
    """Get all job services assigned to a staff member"""
    try:
        # Staff can only view their own assignments, admins can view any
        user_role = current_user.get("role")
        if user_role == "staff" and current_user["uid"] != staff_id:
            raise HTTPException(status_code=403, detail="Staff can only view their own assignments")
        
        service = JobServiceService()
        job_services = await service.get_job_services_by_staff(staff_id)
        return job_services
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get job services: {str(e)}")

@router.get("/status/{status}", response_model=List[JobService])
async def get_job_services_by_status(
    status: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all job services with specific status (Admin only)"""
    try:
        service = JobServiceService()
        job_services = await service.get_job_services_by_status(status)
        return job_services
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get job services: {str(e)}")

@router.get("/", response_model=List[JobService])
async def get_all_job_services(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all job services (Admin only)"""
    try:
        service = JobServiceService()
        job_services = await service.get_all_job_services()
        return job_services
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get job services: {str(e)}")
