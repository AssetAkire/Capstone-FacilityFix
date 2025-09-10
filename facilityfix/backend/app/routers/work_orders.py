from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
from datetime import datetime
from pydantic import BaseModel

from app.auth.dependencies import get_current_user, require_role
from app.database.database_service import DatabaseService
from app.services.work_order_service import WorkOrderService
from app.database.firestore_client import get_firestore_client

router = APIRouter(prefix="/api/work-orders", tags=["work-orders"])

# Request/Response Models
class CreateWorkOrderRequest(BaseModel):
    request_id: str
    work_type: str = "job_service" # job_service or work_permit
    estimated_hours: Optional[float] = None
    none: Optional[str] = None

class AssignWorkOrderRequest(BaseModel):
    assigned_to: str
    scheduled_date: Optional[datetime] = None

class UpdateStatusRequest(BaseModel):
    status: str
    remarks: Optional[str] = None
    materials_used: Optional[List[str]] = None
    actual_hours: Optional[float] = None
    cost: Optional[float] = None

class AddNotesRequest(BaseModel):
    notes: str

class SubmitFeedbackRequest(BaseModel):
    work_order_id: str
    request_id: str
    rating: int
    comments: Optional[str] = None
    service_quality: Optional[int] = None
    timeliness: Optional[int] = None
    communication: Optional[int] = None
    would_recommend: Optional[bool] = None

# Dependency to get work order service
async def get_work_order_service() -> WorkOrderService:
    firestore_client = get_firestore_client()
    db_service = DatabaseService(firestore_client)
    return WorkOrderService(db_service)

@router.post("/", response_model=Dict[str, Any])
async def create_work_order(
    request: CreateWorkOrderRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Create a new work order from a repair request (Admin only)"""
    try:
        work_order_data = {
            "request_id": request.request_id,
            "created_by": current_user["uid"],
            "work_type": request.work_type,
            "estimated_hours": request.estimated_hours,
            "notes": request.notes
        }
        
        result = await work_order_service.create_work_order(work_order_data)
        return {"message": "Work order created successfully", "work_order": result}
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create work order: {str(e)}"
        )
    
@router.patch("/{work_order_id}/assign", response_model=Dict[str, Any])
async def assign_work_order(
    work_order_id: str,
    request: AssignWorkOrderRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Assign work order to staff/contractor (Admin only)"""
    try:
        result = await work_order_service.assign_work_order(
            work_order_id=work_order_id,
            assigned_to=request.assigned_to,
            scheduled_date=request.scheduled_date,
            updated_by=current_user["uid"]
        )
        return {"message": "Work order assigned successfully", "work_order": result}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to assign work order: {str(e)}"
        )

@router.patch("/{work_order_id}/status", response_model=Dict[str, Any])
async def update_work_order_status(
    work_order_id: str,
    request: UpdateStatusRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Update work order status (Admin/Staff only)"""
    try:
        additional_data = {}
        if request.materials_used:
            additional_data['materials_used'] = request.materials_used
        if request.actual_hours:
            additional_data['actual_hours'] = request.actual_hours
        if request.cost:
            additional_data['cost'] = request.cost
        
        result = await work_order_service.update_work_order_status(
            work_order_id=work_order_id,
            new_status=request.status,
            updated_by=current_user["uid"],
            remarks=request.remarks,
            additional_data=additional_data if additional_data else None
        )
        return {"message": "Work order status updated successfully", "work_order": result}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update work order status: {str(e)}"
        )
    
@router.patch("/{work_order_id}/close", response_model=Dict[str, Any])
async def close_work_order(
    work_order_id: str,
    final_notes: Optional[str] = None,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Close work order and mark repair request as resolved (Admin only)"""
    try:
        result = await work_order_service.close_work_order(
            work_order_id=work_order_id,
            closed_by=current_user["uid"],
            final_notes=final_notes
        )
        return {"message": "Work order closed successfully", "work_order": result}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to close work order: {str(e)}"
        )

@router.post("/{work_order_id}/notes", response_model=Dict[str, Any])
async def add_work_order_notes(
    work_order_id: str,
    request: AddNotesRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Add notes to work order (Admin/Staff only)"""
    try:
        result = await work_order_service.add_work_order_notes(
            work_order_id=work_order_id,
            notes=request.notes,
            added_by=current_user["uid"]
        )
        return {"message": "Notes added successfully", "work_order": result}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to add notes: {str(e)}"
        )
    
@router.post("/feedback", response_model=Dict[str, Any])
async def submit_feedback(
    request: SubmitFeedbackRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Submit feedback for completed work order (Tenant only)"""
    try:
        feedback_data = {
            "work_order_id": request.work_order_id,
            "request_id": request.request_id,
            "submitted_by": current_user["uid"],
            "rating": request.rating,
            "comments": request.comments,
            "service_quality": request.service_quality,
            "timeliness": request.timeliness,
            "communication": request.communication,
            "would_recommend": request.would_recommend
        }
        
        result = await work_order_service.submit_feedback(feedback_data)
        return {"message": "Feedback submitted successfully", "feedback": result}
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to submit feedback: {str(e)}"
        )

@router.get("/status/{status}", response_model=List[Dict[str, Any]])
async def get_work_orders_by_status(
    status: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Get work orders by status (Admin/Staff only)"""
    try:
        work_orders = await work_order_service.get_work_orders_by_status(status)
        return work_orders
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve work orders: {str(e)}"
        )

@router.get("/assigned/{user_id}", response_model=List[Dict[str, Any]])
async def get_assigned_work_orders(
    user_id: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Get work orders assigned to specific user (Admin/Staff only)"""
    try:
        # Staff can only see their own assignments
        if current_user.get("role") == "staff" and user_id != current_user["uid"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Staff can only view their own assignments"
            )
        
        work_orders = await work_order_service.get_work_orders_by_assignee(user_id)
        return work_orders
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve assigned work orders: {str(e)}"
        )

@router.get("/{work_order_id}/history", response_model=List[Dict[str, Any]])
async def get_work_order_history(
    work_order_id: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    work_order_service: WorkOrderService = Depends(get_work_order_service)
):
    """Get status history for work order (Admin/Staff only)"""
    try:
        history = await work_order_service.get_work_order_history(work_order_id)
        return history
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve work order history: {str(e)}"
        )