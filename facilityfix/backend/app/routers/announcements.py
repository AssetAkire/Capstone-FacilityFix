from fastapi import APIRouter, HTTPException, Depends, Query, Path
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
import logging

from ..models.database_models import Announcement
from ..services.announcement_service import announcement_service
from ..auth.dependencies import get_current_user, require_role

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/announcements", tags=["announcements"])

# Request/Response Models
class CreateAnnouncementRequest(BaseModel):
    building_id: str = Field(..., description="Building ID where announcement applies")
    title: str = Field(..., min_length=1, max_length=200, description="Announcement title")
    content: str = Field(..., min_length=1, description="Full announcement content")
    type: str = Field(default="general", description="Type: maintenance, reminder, event, policy, general")
    audience: str = Field(default="all", description="Target audience: tenants, staff, all")
    location_affected: Optional[str] = Field(None, description="Specific location affected")
    send_notifications: bool = Field(default=True, description="Send push/websocket notifications")
    send_email: bool = Field(default=False, description="Send email notifications")

class UpdateAnnouncementRequest(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1)
    type: Optional[str] = Field(None)
    audience: Optional[str] = Field(None)
    location_affected: Optional[str] = Field(None)
    is_active: Optional[bool] = Field(None)
    notify_changes: bool = Field(default=False, description="Send notifications about update")

class AnnouncementResponse(BaseModel):
    id: str
    formatted_id: Optional[str] = None  # Add formatted_id to response
    created_by: str
    building_id: str
    title: str
    content: str
    type: str
    audience: str
    location_affected: Optional[str]
    is_active: bool
    date_added: datetime
    created_at: datetime
    updated_at: datetime

class AnnouncementListResponse(BaseModel):
    announcements: List[AnnouncementResponse]
    total_count: int
    building_id: str
    audience_filter: str

class AnnouncementStatsResponse(BaseModel):
    total_announcements: int
    active_announcements: int
    inactive_announcements: int
    type_breakdown: dict
    audience_breakdown: dict
    building_id: str
    generated_at: str

# API Endpoints

@router.post("/", response_model=dict)
async def create_announcement(
    request: CreateAnnouncementRequest,
    current_user: dict = Depends(get_current_user)
):
    """Create new announcement (Admin only)"""
    # Verify user is admin
    if current_user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail="Only administrators can create announcements")
    
    try:
        success, announcement_id, error = await announcement_service.create_announcement(
            created_by=current_user['uid'],
            building_id=request.building_id,
            title=request.title,
            content=request.content,
            announcement_type=request.type,
            audience=request.audience,
            location_affected=request.location_affected,
            send_notifications=request.send_notifications,
            send_email=request.send_email
        )
        
        if success:
            logger.info(f"Announcement created: {announcement_id} by {current_user['uid']}")
            return {
                "success": True,
                "announcement_id": announcement_id,
                "message": "Announcement created and broadcast successfully"
            }
        else:
            raise HTTPException(status_code=500, detail=error)
            
    except Exception as e:
        logger.error(f"Error creating announcement: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to create announcement: {str(e)}")

@router.get("/", response_model=AnnouncementListResponse)
async def get_announcements(
    building_id: str = Query(..., description="Building ID to filter by"),
    audience: str = Query("all", description="Audience filter: tenants, staff, all"),
    active_only: bool = Query(True, description="Return only active announcements"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of announcements"),
    current_user: dict = Depends(get_current_user)
):
    """Get announcements for building and user role"""
    try:
        # Determine user's effective audience for filtering
        user_role = current_user.get('role', 'tenant')
        
        # If user is not admin, filter to their role or 'all' audience
        if user_role != 'admin':
            if audience not in [user_role, 'all']:
                audience = user_role
        
        announcements = await announcement_service.get_announcements(
            building_id=building_id,
            audience=audience,
            active_only=active_only,
            limit=limit
        )
        
        return AnnouncementListResponse(
            announcements=[AnnouncementResponse(**ann) for ann in announcements],
            total_count=len(announcements),
            building_id=building_id,
            audience_filter=audience
        )
        
    except Exception as e:
        logger.error(f"Error getting announcements: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get announcements: {str(e)}")

@router.get("/{announcement_id}", response_model=AnnouncementResponse)
async def get_announcement(
    announcement_id: str = Path(..., description="Announcement ID"),
    current_user: dict = Depends(get_current_user)
):
    """Get specific announcement by ID"""
    try:
        announcement = await announcement_service.get_announcement_by_id(announcement_id)
        
        if not announcement:
            raise HTTPException(status_code=404, detail="Announcement not found")
        
        # Check if user has access to this announcement
        user_role = current_user.get('role', 'tenant')
        announcement_audience = announcement.get('audience', 'all')
        
        # Allow access if:
        # 1. User is admin (can see all)
        # 2. Announcement is for 'all'
        # 3. Announcement audience matches user role
        if (user_role != 'admin' and 
            announcement_audience != 'all' and 
            announcement_audience != user_role):
            raise HTTPException(status_code=403, detail="Access denied to this announcement")
        
        return AnnouncementResponse(**announcement)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting announcement {announcement_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get announcement: {str(e)}")

@router.put("/{announcement_id}", response_model=dict)
async def update_announcement(
    announcement_id: str = Path(..., description="Announcement ID"),
    request: UpdateAnnouncementRequest = None,
    current_user: dict = Depends(get_current_user)
):
    """Update announcement (Admin only)"""
    # Verify user is admin
    if current_user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail="Only administrators can update announcements")
    
    try:
        # Convert request to updates dict, excluding None values
        updates = {}
        for field, value in request.dict().items():
            if field != 'notify_changes' and value is not None:
                updates[field] = value
        
        if not updates:
            raise HTTPException(status_code=400, detail="No updates provided")
        
        success, error = await announcement_service.update_announcement(
            announcement_id=announcement_id,
            updated_by=current_user['uid'],
            updates=updates,
            notify_changes=request.notify_changes
        )
        
        if success:
            logger.info(f"Announcement {announcement_id} updated by {current_user['uid']}")
            return {
                "success": True,
                "message": "Announcement updated successfully",
                "notify_changes": request.notify_changes
            }
        else:
            if "not found" in error.lower():
                raise HTTPException(status_code=404, detail=error)
            else:
                raise HTTPException(status_code=500, detail=error)
                
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating announcement {announcement_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to update announcement: {str(e)}")

@router.delete("/{announcement_id}", response_model=dict)
async def deactivate_announcement(
    announcement_id: str = Path(..., description="Announcement ID"),
    notify_deactivation: bool = Query(False, description="Send notifications about deactivation"),
    current_user: dict = Depends(get_current_user)
):
    """Deactivate announcement (soft delete) - Admin only"""
    # Verify user is admin
    if current_user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail="Only administrators can deactivate announcements")
    
    try:
        success, error = await announcement_service.deactivate_announcement(
            announcement_id=announcement_id,
            deactivated_by=current_user['uid'],
            notify_deactivation=notify_deactivation
        )
        
        if success:
            logger.info(f"Announcement {announcement_id} deactivated by {current_user['uid']}")
            return {
                "success": True,
                "message": "Announcement deactivated successfully",
                "notify_deactivation": notify_deactivation
            }
        else:
            if "not found" in error.lower():
                raise HTTPException(status_code=404, detail=error)
            else:
                raise HTTPException(status_code=500, detail=error)
                
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deactivating announcement {announcement_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to deactivate announcement: {str(e)}")

@router.get("/building/{building_id}/stats", response_model=AnnouncementStatsResponse)
async def get_announcement_statistics(
    building_id: str = Path(..., description="Building ID"),
    current_user: dict = Depends(get_current_user)
):
    """Get announcement statistics for building (Admin only)"""
    # Verify user is admin
    if current_user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail="Only administrators can access announcement statistics")
    
    try:
        stats = await announcement_service.get_announcement_statistics(building_id)
        
        if "error" in stats:
            raise HTTPException(status_code=500, detail=stats["error"])
        
        return AnnouncementStatsResponse(**stats)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting announcement statistics for building {building_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get statistics: {str(e)}")

@router.post("/{announcement_id}/rebroadcast", response_model=dict)
async def rebroadcast_announcement(
    announcement_id: str = Path(..., description="Announcement ID"),
    send_email: bool = Query(False, description="Include email in rebroadcast"),
    current_user: dict = Depends(get_current_user)
):
    """Rebroadcast existing announcement (Admin only)"""
    # Verify user is admin
    if current_user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail="Only administrators can rebroadcast announcements")
    
    try:
        # Get existing announcement
        announcement = await announcement_service.get_announcement_by_id(announcement_id)
        
        if not announcement:
            raise HTTPException(status_code=404, detail="Announcement not found")
        
        if not announcement.get('is_active', True):
            raise HTTPException(status_code=400, detail="Cannot rebroadcast inactive announcement")
        
        # Rebroadcast the announcement
        await announcement_service._broadcast_announcement(
            announcement,
            send_notifications=True,
            send_email=send_email
        )
        
        logger.info(f"Announcement {announcement_id} rebroadcast by {current_user['uid']}")
        
        return {
            "success": True,
            "message": "Announcement rebroadcast successfully",
            "announcement_id": announcement_id,
            "included_email": send_email
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error rebroadcasting announcement {announcement_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to rebroadcast announcement: {str(e)}")

@router.get("/types/available", response_model=dict)
async def get_available_announcement_types(
    current_user: dict = Depends(get_current_user)
):
    """Get available announcement types and audiences"""
    return {
        "announcement_types": [
            {"value": "general", "label": "General Announcement"},
            {"value": "maintenance", "label": "Maintenance Notice"},
            {"value": "reminder", "label": "Reminder"},
            {"value": "event", "label": "Event Notification"},
            {"value": "policy", "label": "Policy Update"},
            {"value": "emergency", "label": "Emergency Alert"}
        ],
        "audiences": [
            {"value": "all", "label": "All Users"},
            {"value": "tenants", "label": "Tenants Only"},
            {"value": "staff", "label": "Staff Only"},
            {"value": "admins", "label": "Administrators Only"}
        ],
        "user_role": current_user.get('role', 'tenant')
    }
