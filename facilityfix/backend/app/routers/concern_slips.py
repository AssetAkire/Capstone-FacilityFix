from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
from app.models.database_models import ConcernSlip
from app.services.concern_slip_service import ConcernSlipService
from app.auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/concern-slips", tags=["concern-slips"])

# Request Models
class CreateConcernSlipRequest(BaseModel):
    title: str
    description: str
    location: str
    category: str  # electrical, plumbing, hvac, carpentry, maintenance, security, fire_safety, general
    priority: str = "medium"  # low, medium, high, critical
    unit_id: Optional[str] = None
    attachments: Optional[List[str]] = []

class EvaluateConcernSlipRequest(BaseModel):
    status: str  # approved, rejected
    urgency_assessment: Optional[str] = None
    resolution_type: Optional[str] = None  # job_service, work_permit
    admin_notes: Optional[str] = None

@router.post("/", response_model=ConcernSlip)
async def submit_concern_slip(
    request: CreateConcernSlipRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant"]))
):
    """
    Submit a new concern slip (Tenant only).
    Tenants report repair/maintenance issues here.
    The system notifies all admins automatically.
    """
    try:
        service = ConcernSlipService()
        concern_slip = await service.create_concern_slip(
            reported_by=current_user["uid"],
            concern_data=request.dict()
        )
        return concern_slip

    except ValueError as e:
        # Raised if a non-tenant tries to access this
        raise HTTPException(status_code=403, detail=str(e))

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error while submitting concern slip: {str(e)}"
        )

@router.patch("/{concern_slip_id}/evaluate", response_model=ConcernSlip)
async def evaluate_concern_slip(
    concern_slip_id: str,
    request: EvaluateConcernSlipRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Evaluate concern slip (Admin only):
    - Approve or reject
    - Set resolution type (job_service, work_permit, etc.)
    """
    try:
        service = ConcernSlipService()
        concern_slip = await service.evaluate_concern_slip(
            concern_slip_id=concern_slip_id,
            evaluated_by=current_user["uid"],
            evaluation_data=request.dict()
        )
        return concern_slip
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Failed to evaluate concern slip: {str(e)}"
        )

@router.get("/{concern_slip_id}", response_model=ConcernSlip)
async def get_concern_slip(
    concern_slip_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "tenant"]))
):
    """Get concern slip by ID"""
    try:
        service = ConcernSlipService()
        concern_slip = await service.get_concern_slip(concern_slip_id)
        if not concern_slip:
            raise HTTPException(status_code=404, detail="Concern slip not found")
        
        # Tenants can only view their own concern slips
        if current_user.get("role") == "tenant" and concern_slip.reported_by != current_user["uid"]:
            raise HTTPException(status_code=403, detail="Access denied")
        
        return concern_slip
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get concern slip: {str(e)}")

@router.get("/tenant/{tenant_id}", response_model=List[ConcernSlip])
async def get_concern_slips_by_tenant(
    tenant_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "tenant"]))
):
    """Get all concern slips for a tenant"""
    try:
        # Tenants can only view their own concern slips
        if current_user.get("role") == "tenant" and current_user["uid"] != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied")
        
        service = ConcernSlipService()
        concern_slips = await service.get_concern_slips_by_tenant(tenant_id)
        return concern_slips
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get concern slips: {str(e)}")

@router.get("/status/{status}", response_model=List[ConcernSlip])
async def get_concern_slips_by_status(
    status: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all concern slips with specific status (Admin only)"""
    try:
        service = ConcernSlipService()
        concern_slips = await service.get_concern_slips_by_status(status)
        return concern_slips
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get concern slips: {str(e)}")

@router.get("/pending/all", response_model=List[ConcernSlip])
async def get_pending_concern_slips(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """Get all pending concern slips awaiting evaluation (Admin only)"""
    try:
        service = ConcernSlipService()
        concern_slips = await service.get_pending_concern_slips()
        return concern_slips
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get pending concern slips: {str(e)}")

@router.get("/", response_model=List[ConcernSlip])
async def get_all_concern_slips(
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role('admin'))
):
    """
    Get all concern slips (Admin only).
    Returns a list of all concern slips submitted by tenants,
    sorted by most recent.
    """
    try:
        service = ConcernSlipService()
        concern_slips = await service.get_all_concern_slips()

        # Sort by creation date (latest first)
        concern_slips.sort(key=lambda slip: slip.created_at, reverse=True)

        return concern_slips

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get concern slips: {str(e)}"
        )
