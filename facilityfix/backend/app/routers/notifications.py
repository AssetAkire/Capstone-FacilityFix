from fastapi import APIRouter, HTTPException, Depends
from typing import List
from pydantic import BaseModel
from app.models.database_models import Notification
from app.services.notification_service import NotificationService
from app.auth.dependencies import get_current_user, require_role

router = APIRouter(prefix="/notifications", tags=["notifications"])

class MarkAsReadRequest(BaseModel):
    notification_ids: List[str]

@router.get("/", response_model=List[Notification])
async def get_user_notifications(
    current_user: dict = Depends(get_current_user)
):
    """Get all notifications for current user"""
    try:
        service = NotificationService()
        notifications = await service.get_user_notifications(current_user["uid"])
        return notifications
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get notifications: {str(e)}")

@router.get("/unread", response_model=List[Notification])
async def get_unread_notifications(
    current_user: dict = Depends(get_current_user)
):
    """Get unread notifications for current user"""
    try:
        service = NotificationService()
        notifications = await service.get_unread_notifications(current_user["uid"])
        return notifications
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get unread notifications: {str(e)}")

@router.patch("/mark-read")
async def mark_notifications_as_read(
    request: MarkAsReadRequest,
    current_user: dict = Depends(get_current_user)
):
    """Mark notifications as read"""
    try:
        service = NotificationService()
        await service.mark_notifications_as_read(
            user_id=current_user["uid"],
            notification_ids=request.notification_ids
        )
        return {"message": "Notifications marked as read"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to mark notifications as read: {str(e)}")

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Delete a notification"""
    try:
        service = NotificationService()
        await service.delete_notification(notification_id, current_user["uid"])
        return {"message": "Notification deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete notification: {str(e)}")

