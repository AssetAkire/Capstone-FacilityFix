from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
from datetime import datetime, date, timezone
from pydantic import BaseModel, Field

from app.auth.dependencies import get_current_user, require_role
from app.database.database_service import database_service
from app.services.repair_request_service import RepairRequestService
from app.database.firestore_client import get_firestore_client

router = APIRouter(prefix="/repair-requests", tags=["repair-requests"])

# Request/Response Models
class CreateRepairRequestRequest(BaseModel):
    title: str
    description: str
    classification: str                  # electrical, plumbing, hvac, etc.
    priority: str = "medium"             # low, medium, high, critical
    location: Optional[str] = None       # e.g. "Bathroom", "Kitchen"
    unit_id: Optional[str] = None        # allow override; else use user's unit
    attachments: Optional[List[str]] = []  # upload URLs / storage paths

    # NEW – from the “Availability / Select Schedule” step in the UI
    preferred_date: Optional[date] = None
    preferred_time: Optional[str] = Field(
        default=None, pattern=r"^\d{2}:\d{2}$"
    )

class UpdateRepairRequestStatusRequest(BaseModel):
    status: str  # open, approved, rejected, in_progress, resolved, closed
    remarks: Optional[str] = None
    assigned_to: Optional[str] = None

# Dependency to get repair request service
async def get_repair_request_service() -> RepairRequestService:
#   firestore_client = get_firestore_client()
#   db_service = DatabaseService(firestore_client)
    return RepairRequestService(database_service)

@router.post("/", response_model=Dict[str, Any])
async def submit_repair_request(
    request: CreateRepairRequestRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant", "admin"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """
    Submit a new repair request (Tenant/Admin).
    Tenants are auto-enriched from their user profile:
    - user_id (e.g., T-0001), full name, building_id, and unit_id.
    """
    try:
        # 1) Resolve the Firestore user profile of the current Firebase uid
        #    Your user docs store Firebase UID in field "id" and human code in "user_id"
        ok, users, err = await repair_service.db_service.query_documents(
            "users",
            filters=[("id", "==", current_user["uid"])],
            limit=1,
        )
        if not ok:
            raise HTTPException(status_code=500, detail=f"User lookup failed: {err}")
        if not users:
            raise HTTPException(status_code=404, detail="User profile not found for current account")

        user_doc = users[0]
        user_code = user_doc.get("user_id")            # e.g., T-0001
        first_name = (user_doc.get("first_name") or "").strip()
        last_name  = (user_doc.get("last_name") or "").strip()
        building_id = user_doc.get("building_id")
        default_unit_id = user_doc.get("unit_id")

        # 2) Build the new repair request payload
        #    (match your UI: date requested, bldg & unit, full name, etc.)
        now_utc = datetime.now(timezone.utc)
        repair_data = {
            # who & traceability
            "reported_by": current_user["uid"],         # Firebase uid
            "reported_by_user_id": user_code,           # human code, e.g. T-0001
            "reported_by_name": f"{first_name} {last_name}".strip(),

            # where
            "building_id": building_id,
            "unit_id": request.unit_id or default_unit_id,
            "location": request.location,               # e.g., "Bathroom"

            # what
            "title": request.title,
            "description": request.description,
            "classification": request.classification,   # plumbing / electrical / ...
            "priority": request.priority,

            # schedule (from Availability UI)
            "preferred_date": request.preferred_date.isoformat() if request.preferred_date else None,
            "preferred_time": request.preferred_time,   # "HH:MM" 24h

            # attachments (Storage URLs or paths)
            "attachments": request.attachments or [],

            # system fields
            "status": "open",                           # initial state
            "date_requested": now_utc,                  # mirrors your UI
            "created_at": now_utc,
            "updated_at": now_utc,
            "request_type": "repair",
        }

        # 3) Persist via service (adds any model validation & returns the created doc)
        result = await repair_service.create_repair_request(repair_data)

        return {"message": "Repair request submitted successfully", "request": result}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to submit repair request: {str(e)}"
        )

@router.get("/", response_model=List[Dict[str, Any]])
async def get_all_repair_requests(
    status_filter: Optional[str] = None,
    priority_filter: Optional[str] = None,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Get all repair requests with optional filters (Admin only)"""
    try:
        filters = {}
        if status_filter:
            filters["status"] = status_filter
        if priority_filter:
            filters["priority"] = priority_filter
            
        requests = await repair_service.get_repair_requests(filters)
        return requests
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve repair requests: {str(e)}"
        )

@router.get("/{user_id}", response_model=List[Dict[str, Any]])
async def get_user_repair_requests(
    user_id: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant", "admin"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Get repair requests for specific user (Tenant can only see own, Admin can see any)"""
    try:
        # Tenants can only see their own requests
        if current_user.get("role") == "tenant" and user_id != current_user["uid"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Tenants can only view their own repair requests"
            )
        
        requests = await repair_service.get_repair_requests_by_user(user_id)
        return requests
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve user repair requests: {str(e)}"
        )

@router.patch("/{request_id}/status", response_model=Dict[str, Any])
async def update_repair_request_status(
    request_id: str,
    request: UpdateRepairRequestStatusRequest,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Update repair request status - approve/reject/assign (Admin only)"""
    try:
        result = await repair_service.update_repair_request_status(
            request_id=request_id,
            new_status=request.status,
            updated_by=current_user["uid"],
            remarks=request.remarks,
            assigned_to=request.assigned_to
        )
        return {"message": "Repair request status updated successfully", "request": result}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update repair request status: {str(e)}"
        )

@router.get("/{request_id}/details", response_model=Dict[str, Any])
async def get_repair_request_details(
    request_id: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["tenant", "admin", "staff"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Get detailed information about a specific repair request"""
    try:
        request_details = await repair_service.get_repair_request_by_id(request_id)
        
        # Tenants can only see their own requests
        if (current_user.get("role") == "tenant" and 
            request_details.get("reported_by") != current_user["uid"]):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to this repair request"
            )
        
        return request_details
    
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve repair request details: {str(e)}"
        )

@router.get("/status/{status}", response_model=List[Dict[str, Any]])
async def get_repair_requests_by_status(
    status: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin", "staff"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Get repair requests filtered by status (Admin/Staff only)"""
    try:
        requests = await repair_service.get_repair_requests_by_status(status)
        return requests
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve repair requests by status: {str(e)}"
        )

@router.delete("/{request_id}", response_model=Dict[str, Any])
async def delete_repair_request(
    request_id: str,
    current_user: Dict = Depends(get_current_user),
    _: None = Depends(require_role(["admin"])),
    repair_service: RepairRequestService = Depends(get_repair_request_service)
):
    """Delete a repair request (Admin only - use with caution)"""
    try:
        await repair_service.delete_repair_request(request_id, current_user["uid"])
        return {"message": "Repair request deleted successfully"}
    
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete repair request: {str(e)}"
        )
