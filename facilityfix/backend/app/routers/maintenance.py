from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from datetime import datetime
from app.auth.dependencies import get_current_user
from app.services.job_service_service import JobServiceService
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/maintenance", tags=["maintenance"])

@router.get("/")
async def get_all_maintenance_tasks(current_user: dict = Depends(get_current_user)):
    """Get all maintenance tasks (Job Services)"""
    try:
        logger.info(f"[DEBUG] Fetching maintenance tasks for user: {current_user.get('email')} with role: {current_user.get('role')}")
        
        job_service = JobServiceService()
        
        # Get all job services from Firebase
        job_services = await job_service.get_all_job_services()
        
        logger.info(f"[DEBUG] Found {len(job_services)} job services in database")
        
        # Convert to maintenance task format
        result = []
        for js in job_services:
            task_dict = {
                "id": js.id,
                "formatted_id": getattr(js, 'formatted_id', js.id),
                "task_title": js.title or "Maintenance Task",
                "title": js.title or "Maintenance Task",
                "description": js.description or "",
                "location": js.location or "",
                "category": js.category or "maintenance",
                "priority": js.priority or "medium",
                "status": js.status,
                "assigned_to": js.assigned_to,
                "assigned_staff": js.assigned_to,
                "scheduled_date": js.scheduled_date.isoformat() if getattr(js, 'scheduled_date', None) else None,
                "created_at": js.created_at.isoformat() if js.created_at else None,
                "updated_at": js.updated_at.isoformat() if js.updated_at else None,
                "estimated_hours": getattr(js, 'estimated_hours', None),
                "request_type": "Job Service"
            }
            result.append(task_dict)
        
        # Sort by scheduled date or creation date
        result.sort(key=lambda x: x.get("scheduled_date") or x.get("created_at", ""), reverse=True)
        
        logger.info(f"[DEBUG] Returning {len(result)} maintenance tasks")
        return result
        
    except Exception as e:
        logger.error(f"Error getting maintenance tasks: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get maintenance tasks: {str(e)}")

@router.get("/{task_id}")
async def get_maintenance_task_by_id(
    task_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Get a specific maintenance task by ID"""
    try:
        job_service = JobServiceService()
        job_service_obj = await job_service.get_job_service(task_id)
        
        if not job_service_obj:
            raise HTTPException(status_code=404, detail="Maintenance task not found")
        
        return {
            "id": job_service_obj.id,
            "formatted_id": getattr(job_service_obj, 'formatted_id', job_service_obj.id),
            "task_title": job_service_obj.title or "Maintenance Task",
            "title": job_service_obj.title or "Maintenance Task",
            "description": job_service_obj.description or "",
            "location": job_service_obj.location or "",
            "category": job_service_obj.category or "maintenance",
            "priority": job_service_obj.priority or "medium",
            "status": job_service_obj.status,
            "assigned_to": job_service_obj.assigned_to,
            "assigned_staff": job_service_obj.assigned_to,
            "scheduled_date": job_service_obj.scheduled_date.isoformat() if getattr(job_service_obj, 'scheduled_date', None) else None,
            "created_at": job_service_obj.created_at.isoformat() if job_service_obj.created_at else None,
            "updated_at": job_service_obj.updated_at.isoformat() if job_service_obj.updated_at else None,
            "estimated_hours": getattr(job_service_obj, 'estimated_hours', None),
            "request_type": "Job Service"
        }
        
    except Exception as e:
        logger.error(f"Error getting maintenance task {task_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get maintenance task: {str(e)}")

@router.post("/")
async def create_maintenance_task(
    task_data: dict,
    current_user: dict = Depends(get_current_user)
):
    """Create a new maintenance task"""
    try:
        job_service = JobServiceService()
        
        # Create job service
        job_service_obj = await job_service.create_job_service(
            created_by=current_user.get('uid'),
            job_data=task_data
        )
        
        return {
            "success": True,
            "message": "Maintenance task created successfully",
            "id": job_service_obj.id,
            "formatted_id": getattr(job_service_obj, 'formatted_id', job_service_obj.id)
        }
        
    except Exception as e:
        logger.error(f"Error creating maintenance task: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to create maintenance task: {str(e)}")