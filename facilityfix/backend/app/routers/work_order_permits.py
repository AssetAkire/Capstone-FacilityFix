from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
from app.models.database_models import WorkOrderPermit
from app.services.work_order_permit_service import WorkOrderPermitService
from app.auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/work-order-permits", tags=["work-order-permits"])

# Request Models
class CreateWorkOrderPermitRequest(BaseModel):
    concern_slip_id: str
    unit_id: str
    contractor_name: str
    contractor_contact: str
    contractor_company: Optional[str] = None
    work_description: str
    proposed_start_date: datetime
    estimated_duration: str
    specific_instructions: str
    entry_requirements: Optional[str] = None

class ApprovePermitRequest(BaseModel):
    conditions: Optional[str] = None

class DenyPermitRequest(BaseModel):
    reason: str

class UpdatePermitStatusRequest(BaseModel):
    status: str
    notes: Optional[str] = None

@router.post("/", response_model=WorkOrderPermit)
async def create_work_order_permit(
    request: CreateWorkOrderPermitRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant"]))
):
    """Create a new work order permit request (Tenant only)"""
    try:
        service = WorkOrderPermitService()
        permit = await service.create_work_order_permit(
            concern_slip_id=request.concern_slip_id,
            requested_by=current_user["uid"],
            permit_data=request.dict()
        )
        return permit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create work order permit: {str(e)}")

@router.patch("/{permit_id}/approve", response_model=WorkOrderPermit)
async def approve_permit(
    permit_id: str,
    request: ApprovePermitRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Approve work order permit (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permit = await service.approve_permit(
            permit_id=permit_id,
            approved_by=current_user["uid"],
            conditions=request.conditions
        )
        return permit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to approve permit: {str(e)}")

@router.patch("/{permit_id}/deny", response_model=WorkOrderPermit)
async def deny_permit(
    permit_id: str,
    request: DenyPermitRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Deny work order permit (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permit = await service.deny_permit(
            permit_id=permit_id,
            denied_by=current_user["uid"],
            reason=request.reason
        )
        return permit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to deny permit: {str(e)}")

@router.patch("/{permit_id}/status", response_model=WorkOrderPermit)
async def update_permit_status(
    permit_id: str,
    request: UpdatePermitStatusRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Update work order permit status (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permit = await service.update_permit_status(
            permit_id=permit_id,
            status=request.status,
            updated_by=current_user["uid"],
            notes=request.notes
        )
        return permit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update permit status: {str(e)}")

@router.patch("/{permit_id}/start-work", response_model=WorkOrderPermit)
async def start_work(
    permit_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "tenant"]))
):
    """Mark work as started (updates actual start date)"""
    try:
        service = WorkOrderPermitService()
        permit = await service.start_work(
            permit_id=permit_id,
            started_by=current_user["uid"]
        )
        return permit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to start work: {str(e)}")

@router.get("/{permit_id}", response_model=WorkOrderPermit)
async def get_work_order_permit(
    permit_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "tenant"]))
):
    """Get work order permit by ID"""
    try:
        service = WorkOrderPermitService()
        permit = await service.get_work_order_permit(permit_id)
        if not permit:
            raise HTTPException(status_code=404, detail="Work order permit not found")
        
        # Tenants can only view their own permits
        if current_user.get("role") == "tenant" and permit.requested_by != current_user["uid"]:
            raise HTTPException(status_code=403, detail="Access denied")
        
        return permit
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get work order permit: {str(e)}")

@router.get("/tenant/{tenant_id}", response_model=List[WorkOrderPermit])
async def get_permits_by_tenant(
    tenant_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "tenant"]))
):
    """Get all work order permits for a tenant"""
    try:
        # Tenants can only view their own permits
        if current_user.get("role") == "tenant" and current_user["uid"] != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied")
        
        service = WorkOrderPermitService()
        permits = await service.get_permits_by_tenant(tenant_id)
        return permits
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get permits: {str(e)}")

@router.get("/status/{status}", response_model=List[WorkOrderPermit])
async def get_permits_by_status(
    status: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all work order permits with specific status (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permits = await service.get_permits_by_status(status)
        return permits
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get permits: {str(e)}")

@router.get("/pending/all", response_model=List[WorkOrderPermit])
async def get_pending_permits(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all pending work order permits (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permits = await service.get_pending_permits()
        return permits
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get pending permits: {str(e)}")

@router.get("/", response_model=List[WorkOrderPermit])
async def get_all_permits(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all work order permits (Admin only)"""
    try:
        service = WorkOrderPermitService()
        permits = await service.get_all_permits()
        return permits
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get permits: {str(e)}")
