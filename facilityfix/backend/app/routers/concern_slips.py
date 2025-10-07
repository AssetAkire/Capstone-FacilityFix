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

class AssignStaffRequest(BaseModel):
    assigned_to: str  # staff user_id

class SubmitAssessmentRequest(BaseModel):
    assessment: str
    recommendation: str
    attachments: Optional[List[str]] = []

class AIReprocessRequest(BaseModel):
    force_translate: bool = False

@router.post("/", response_model=ConcernSlip)
async def submit_concern_slip(
    request: CreateConcernSlipRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant"]))
):
    """
    Submit a new concern slip (Tenant only).
    Tenants report repair/maintenance issues here.
    The system automatically processes the description with AI for translation and categorization.
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

@router.patch("/{concern_slip_id}/assign-staff", response_model=ConcernSlip)
async def assign_staff_to_concern_slip(
    concern_slip_id: str,
    request: AssignStaffRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Assign a staff member to assess a concern slip (Admin only).
    This is step 2 of the workflow after tenant submits.
    """
    try:
        service = ConcernSlipService()
        concern_slip = await service.assign_staff_for_assessment(
            concern_slip_id=concern_slip_id,
            assigned_to=request.assigned_to,
            assigned_by=current_user["uid"]
        )
        return concern_slip
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to assign staff: {str(e)}"
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

@router.get("/{concern_slip_id}/ai-history")
async def get_ai_processing_history(
    concern_slip_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Get AI processing history for a concern slip (Admin only).
    Shows translation attempts, categorization results, and confidence scores.
    """
    try:
        service = ConcernSlipService()
        
        # Verify concern slip exists
        concern_slip = await service.get_concern_slip(concern_slip_id)
        if not concern_slip:
            raise HTTPException(status_code=404, detail="Concern slip not found")
        
        # Get AI processing history
        ai_history = await service.get_ai_processing_history(concern_slip_id)
        if not ai_history:
            raise HTTPException(status_code=404, detail="No AI processing history found")
        
        return ai_history
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get AI processing history: {str(e)}")

@router.post("/{concern_slip_id}/reprocess-ai")
async def reprocess_concern_with_ai(
    concern_slip_id: str,
    request: AIReprocessRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Reprocess a concern slip with AI (Admin only).
    Useful for re-analyzing descriptions with updated models or forcing translation.
    """
    try:
        service = ConcernSlipService()
        
        # Verify concern slip exists
        concern_slip = await service.get_concern_slip(concern_slip_id)
        if not concern_slip:
            raise HTTPException(status_code=404, detail="Concern slip not found")
        
        # Reprocess with AI
        success = await service.reprocess_with_ai(concern_slip_id, request.force_translate)
        
        if success:
            # Return updated concern slip
            updated_concern = await service.get_concern_slip(concern_slip_id)
            return {
                "message": "AI reprocessing completed successfully",
                "concern_slip": updated_concern,
                "reprocessed_at": datetime.utcnow().isoformat()
            }
        else:
            raise HTTPException(status_code=500, detail="AI reprocessing failed")
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to reprocess with AI: {str(e)}")

@router.patch("/{concern_slip_id}/submit-assessment", response_model=ConcernSlip)
async def submit_staff_assessment(
    concern_slip_id: str,
    request: SubmitAssessmentRequest,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["staff"]))
):
    """
    Submit assessment and recommendation for a concern slip (Staff only).
    This is step 3 of the workflow after staff inspects the issue.
    """
    try:
        service = ConcernSlipService()
        concern_slip = await service.submit_staff_assessment(
            concern_slip_id=concern_slip_id,
            assessed_by=current_user["uid"],
            assessment=request.assessment,
            recommendation=request.recommendation,
            attachments=request.attachments
        )
        return concern_slip
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to submit assessment: {str(e)}"
        )

@router.patch("/{concern_slip_id}/return-to-tenant", response_model=ConcernSlip)
async def return_concern_slip_to_tenant(
    concern_slip_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"]))
):
    """
    Return assessed concern slip to tenant (Admin only).
    This is step 4 of the workflow after admin reviews staff assessment.
    Tenant can then proceed with Job Service or Work Order Permit.
    """
    try:
        service = ConcernSlipService()
        concern_slip = await service.return_to_tenant(
            concern_slip_id=concern_slip_id,
            returned_by=current_user["uid"]
        )
        return concern_slip
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to return concern slip to tenant: {str(e)}"
        )

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

@router.get("/staff/{staff_id}", response_model=List[ConcernSlip])
async def get_concern_slips_by_staff(
    staff_id: str,
    current_user: dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"]))
):
    """Get all concern slips assigned to a staff member"""
    try:
        # Staff can only view their own assignments
        if current_user.get("role") == "staff" and current_user["uid"] != staff_id:
            raise HTTPException(status_code=403, detail="Access denied")
        
        service = ConcernSlipService()
        concern_slips = await service.get_concern_slips_by_staff(staff_id)
        return concern_slips
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get concern slips: {str(e)}")

@router.get("/", response_model=List[ConcernSlip])
async def get_all_concern_slips(
    current_user: dict = Depends(get_current_user)
):
    """
    Get concern slips based on user role:
    - Tenants: Get only their own concern slips
    - Staff: Get only concern slips assigned to them
    - Admins: Get all concern slips
    """
    try:
        service = ConcernSlipService()
        user_role = current_user.get("role")
        user_id = current_user.get("uid")
        
        if user_role == "tenant":
            # Tenants get only their own concern slips
            concern_slips = await service.get_concern_slips_by_tenant(user_id)
        elif user_role == "staff":
            # Staff get only concern slips assigned to them
            concern_slips = await service.get_concern_slips_by_staff(user_id)
        elif user_role == "admin":
            # Admins get all concern slips
            concern_slips = await service.get_all_concern_slips()
            # Sort by creation date (latest first)
            concern_slips.sort(key=lambda slip: slip.created_at, reverse=True)
        else:
            raise HTTPException(
                status_code=403, 
                detail=f"Insufficient permissions. Required role: admin, tenant, or staff, current role: {user_role}"
            )

        return concern_slips

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get concern slips: {str(e)}"
        )
