from typing import List, Optional
from datetime import datetime
from app.models.database_models import JobService, UserProfile, ConcernSlip, Notification
from app.database.database_service import DatabaseService
from app.services.user_id_service import UserIdService
import uuid

class JobServiceService:
    def __init__(self):
        self.db = DatabaseService()
        self.user_service = UserIdService()

    async def create_job_service(self, concern_slip_id: str, created_by: str, job_data: dict) -> JobService:
        """Create a new job service from an approved concern slip"""
        
        # Verify concern slip exists and is approved
        success, concern_slip_data, error = await self.db.get_document("concern_slips", concern_slip_id)
        if not success or not concern_slip_data:
            raise ValueError("Concern slip not found")
        
        if concern_slip_data.get("status") != "approved":
            raise ValueError("Concern slip must be approved before creating job service")
        
        # Verify creator is admin
        creator_profile = await self.user_service.get_user_profile(created_by)
        if not creator_profile or creator_profile.role != "admin":
            raise ValueError("Only admins can create job services")

        job_service_id = f"job_{str(uuid.uuid4())[:8]}"

        job_service_data = {
            "id": job_service_id,
            "concern_slip_id": concern_slip_id,
            "created_by": created_by,
            "title": job_data.get("title") or concern_slip_data.get("title"),
            "description": job_data.get("description") or concern_slip_data.get("description"),
            "location": job_data.get("location") or concern_slip_data.get("location"),
            "category": job_data.get("category") or concern_slip_data.get("category"),
            "priority": job_data.get("priority") or concern_slip_data.get("priority"),
            "status": "assigned",
            "assigned_to": job_data.get("assigned_to"),
            "scheduled_date": job_data.get("scheduled_date"),
            "estimated_hours": job_data.get("estimated_hours"),
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }

        # Create job service
        success, doc_id, error = await self.db.create_document("job_services", job_service_data, job_service_id)
        if not success:
            raise ValueError(f"Failed to create job service: {error}")
        
        # Update concern slip status
        success, error = await self.db.update_document("concern_slips", concern_slip_id, {
            "resolution_type": "job_service",
            "updated_at": datetime.utcnow()
        })

        # Send notification to assigned staff
        if job_service_data.get("assigned_to"):
            await self._send_assignment_notification(
                job_service_data["assigned_to"], 
                job_service_data["id"],
                job_service_data["title"]
            )

        # Send notification to tenant
        await self._send_tenant_notification(
            concern_slip_data.get("reported_by"),
            job_service_data["id"],
            "Your concern has been assigned to our internal staff"
        )

        return JobService(**job_service_data)

    async def assign_job_service(self, job_service_id: str, assigned_to: str, assigned_by: str) -> JobService:
        """Assign job service to internal staff member"""
        
        # Verify assigner is admin
        assigner_profile = await self.user_service.get_user_profile(assigned_by)
        if not assigner_profile or assigner_profile.role != "admin":
            raise ValueError("Only admins can assign job services")

        if not assigned_to.startswith("S-"):
            raise ValueError("Job services can only be assigned to staff members")

        # Verify assignee is staff
        assignee_profile = await self.user_service.get_user_profile(assigned_to)
        if not assignee_profile or assignee_profile.role != "staff":
            raise ValueError("Job services can only be assigned to staff members")

        # Update job service
        update_data = {
            "assigned_to": assigned_to,
            "status": "assigned",
            "updated_at": datetime.utcnow()
        }

        success, error = await self.db.update_document("job_services", job_service_id, update_data)
        if not success:
            raise ValueError(f"Failed to assign job service: {error}")
        
        # Send notification to assigned staff
        success, job_service_data, error = await self.db.get_document("job_services", job_service_id)
        if success and job_service_data:
            await self._send_assignment_notification(
                assigned_to, 
                job_service_id,
                job_service_data.get("title", "Job Service Assignment")
            )

        success, updated_job_data, error = await self.db.get_document("job_services", job_service_id)
        if not success or not updated_job_data:
            raise ValueError("Failed to retrieve updated job service")
            
        return JobService(**updated_job_data)

    async def update_job_status(self, job_service_id: str, status: str, updated_by: str, notes: Optional[str] = None) -> JobService:
        """Update job service status"""
        
        valid_statuses = ["assigned", "in_progress", "completed", "closed"]
        if status not in valid_statuses:
            raise ValueError(f"Invalid status. Must be one of: {valid_statuses}")

        update_data = {
            "status": status,
            "updated_at": datetime.utcnow()
        }

        # Add timestamp for specific status changes
        if status == "in_progress":
            update_data["started_at"] = datetime.utcnow()
        elif status == "completed":
            update_data["completed_at"] = datetime.utcnow()

        # Add notes if provided
        if notes:
            if status == "completed":
                update_data["completion_notes"] = notes
            else:
                update_data["staff_notes"] = notes

        success, error = await self.db.update_document("job_services", job_service_id, update_data)
        if not success:
            raise ValueError(f"Failed to update job status: {error}")

        # Send notifications based on status
        success, job_service_data, error = await self.db.get_document("job_services", job_service_id)
        if success and job_service_data:
            success, concern_slip_data, error = await self.db.get_document("concern_slips", job_service_data.get("concern_slip_id"))
            
            if status == "completed" and success and concern_slip_data:
                # Notify tenant of completion
                await self._send_tenant_notification(
                    concern_slip_data.get("reported_by"),
                    job_service_id,
                    f"Your repair request has been completed: {job_service_data.get('title')}"
                )

        success, updated_job_data, error = await self.db.get_document("job_services", job_service_id)
        if not success or not updated_job_data:
            raise ValueError("Failed to retrieve updated job service")
            
        return JobService(**updated_job_data)

    async def add_work_notes(self, job_service_id: str, notes: str, added_by: str) -> JobService:
        """Add work notes to job service"""
        
        success, job_service_data, error = await self.db.get_document("job_services", job_service_id)
        if not success or not job_service_data:
            raise ValueError("Job service not found")

        current_notes = job_service_data.get("staff_notes", "")
        timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M")
        user_profile = await self.user_service.get_user_profile(added_by)
        user_name = f"{user_profile.first_name} {user_profile.last_name}" if user_profile else "Unknown"
        
        new_note = f"\n[{timestamp}] {user_name}: {notes}"
        updated_notes = current_notes + new_note

        success, error = await self.db.update_document("job_services", job_service_id, {
            "staff_notes": updated_notes,
            "updated_at": datetime.utcnow()
        })
        
        if not success:
            raise ValueError(f"Failed to add work notes: {error}")

        success, updated_job_data, error = await self.db.get_document("job_services", job_service_id)
        if not success or not updated_job_data:
            raise ValueError("Failed to retrieve updated job service")
            
        return JobService(**updated_job_data)

    async def get_job_service(self, job_service_id: str) -> Optional[JobService]:
        """Get job service by ID"""
        success, job_data, error = await self.db.get_document("job_services", job_service_id)
        if not success or not job_data:
            return None
        return JobService(**job_data)

    async def get_job_services_by_staff(self, staff_id: str) -> List[JobService]:
        """Get all job services assigned to a staff member"""
        success, jobs_data, error = await self.db.query_documents("job_services", [("assigned_to", staff_id)])
        if not success or not jobs_data:
            return []
        return [JobService(**job) for job in jobs_data]

    async def get_job_services_by_status(self, status: str) -> List[JobService]:
        """Get all job services with specific status"""
        success, jobs_data, error = await self.db.query_documents("job_services", [("status", status)])
        if not success or not jobs_data:
            return []
        return [JobService(**job) for job in jobs_data]

    async def get_all_job_services(self) -> List[JobService]:
        """Get all job services (admin only)"""
        try:
            jobs_data = await self.db.get_all_documents("job_services")
            if not jobs_data:
                return []
            return [JobService(**job) for job in jobs_data]
        except Exception as e:
            raise ValueError(f"Failed to get job services: {str(e)}")

    async def _send_assignment_notification(self, recipient_id: str, job_service_id: str, title: str):
        """Send notification when job is assigned"""
        notification_data = {
            "id": str(uuid.uuid4()),
            "recipient_id": recipient_id,
            "title": "New Job Assignment",
            "message": f"You have been assigned a new job: {title}",
            "notification_type": "job_assigned",
            "related_id": job_service_id,
            "is_read": False,
            "created_at": datetime.utcnow()
        }
        await self.db.create_document("notifications", notification_data["id"], notification_data)

    async def _send_tenant_notification(self, recipient_id: str, job_service_id: str, message: str):
        """Send notification to tenant about job service updates"""
        notification_data = {
            "id": str(uuid.uuid4()),
            "recipient_id": recipient_id,
            "title": "Job Service Update",
            "message": message,
            "notification_type": "job_update",
            "related_id": job_service_id,
            "is_read": False,
            "created_at": datetime.utcnow()
        }
        await self.db.create_document("notifications", notification_data["id"], notification_data)
