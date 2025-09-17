from typing import List, Optional
from datetime import datetime
from app.models.database_models import WorkOrderPermit, UserProfile, ConcernSlip, Notification
from app.database.database_service import DatabaseService
from app.services.user_id_service import UserIdService
import uuid

class WorkOrderPermitService:
    def __init__(self):
        self.db = DatabaseService()
        self.user_service = UserIdService()

    async def create_work_order_permit(self, concern_slip_id: str, requested_by: str, permit_data: dict) -> WorkOrderPermit:
        """Create a new work order permit for external worker authorization"""
        
        # Verify concern slip exists and is approved
        concern_slip = await self.db.get_document("concern_slips", concern_slip_id)
        if not concern_slip:
            raise ValueError("Concern slip not found")
        
        if concern_slip.get("status") != "approved":
            raise ValueError("Concern slip must be approved before creating work order permit")
        
        # Verify requester is tenant and owns the unit
        requester_profile = await self.user_service.get_user_profile(requested_by)
        if not requester_profile or requester_profile.role != "tenant":
            raise ValueError("Only tenants can request work order permits")

        permit_data_complete = {
            "id": str(uuid.uuid4()),
            "concern_slip_id": concern_slip_id,
            "requested_by": requested_by,
            "unit_id": permit_data["unit_id"],
            "contractor_name": permit_data["contractor_name"],
            "contractor_contact": permit_data["contractor_contact"],
            "contractor_company": permit_data.get("contractor_company"),
            "work_description": permit_data["work_description"],
            "proposed_start_date": permit_data["proposed_start_date"],
            "estimated_duration": permit_data["estimated_duration"],
            "specific_instructions": permit_data["specific_instructions"],
            "entry_requirements": permit_data.get("entry_requirements"),
            "status": "pending",
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }

        # Create work order permit
        await self.db.create_document("work_order_permits", permit_data_complete["id"], permit_data_complete)
        
        # Update concern slip status
        await self.db.update_document("concern_slips", concern_slip_id, {
            "resolution_type": "work_permit",
            "updated_at": datetime.utcnow()
        })

        # Send notification to admin for approval
        await self._send_admin_notification(
            permit_data_complete["id"],
            f"New work order permit request from {requester_profile.first_name} {requester_profile.last_name}"
        )

        return WorkOrderPermit(**permit_data_complete)

    async def approve_permit(self, permit_id: str, approved_by: str, conditions: Optional[str] = None) -> WorkOrderPermit:
        """Approve work order permit (Admin only)"""
        
        # Verify approver is admin
        approver_profile = await self.user_service.get_user_profile(approved_by)
        if not approver_profile or approver_profile.role != "admin":
            raise ValueError("Only admins can approve work order permits")

        update_data = {
            "status": "approved",
            "approved_by": approved_by,
            "approval_date": datetime.utcnow(),
            "permit_conditions": conditions,
            "updated_at": datetime.utcnow()
        }

        await self.db.update_document("work_order_permits", permit_id, update_data)
        
        # Send notification to tenant
        permit = await self.db.get_document("work_order_permits", permit_id)
        await self._send_tenant_notification(
            permit.get("requested_by"),
            permit_id,
            "Your work order permit has been approved"
        )

        updated_permit = await self.db.get_document("work_order_permits", permit_id)
        return WorkOrderPermit(**updated_permit)

    async def deny_permit(self, permit_id: str, denied_by: str, reason: str) -> WorkOrderPermit:
        """Deny work order permit (Admin only)"""
        
        # Verify denier is admin
        denier_profile = await self.user_service.get_user_profile(denied_by)
        if not denier_profile or denier_profile.role != "admin":
            raise ValueError("Only admins can deny work order permits")

        update_data = {
            "status": "denied",
            "approved_by": denied_by,  # Track who made the decision
            "approval_date": datetime.utcnow(),
            "denial_reason": reason,
            "updated_at": datetime.utcnow()
        }

        await self.db.update_document("work_order_permits", permit_id, update_data)
        
        # Send notification to tenant
        permit = await self.db.get_document("work_order_permits", permit_id)
        await self._send_tenant_notification(
            permit.get("requested_by"),
            permit_id,
            f"Your work order permit has been denied. Reason: {reason}"
        )

        updated_permit = await self.db.get_document("work_order_permits", permit_id)
        return WorkOrderPermit(**updated_permit)

    async def update_permit_status(self, permit_id: str, status: str, updated_by: str, notes: Optional[str] = None) -> WorkOrderPermit:
        """Update work order permit status"""
        
        valid_statuses = ["pending", "approved", "denied", "completed"]
        if status not in valid_statuses:
            raise ValueError(f"Invalid status. Must be one of: {valid_statuses}")

        update_data = {
            "status": status,
            "updated_at": datetime.utcnow()
        }

        # Add timestamp for specific status changes
        if status == "completed":
            update_data["actual_completion_date"] = datetime.utcnow()

        # Add admin notes if provided
        if notes:
            update_data["admin_notes"] = notes

        await self.db.update_document("work_order_permits", permit_id, update_data)

        # Send notifications based on status
        permit = await self.db.get_document("work_order_permits", permit_id)
        
        if status == "completed":
            # Notify tenant of completion
            await self._send_tenant_notification(
                permit.get("requested_by"),
                permit_id,
                "Your external work has been marked as completed"
            )

        updated_permit = await self.db.get_document("work_order_permits", permit_id)
        return WorkOrderPermit(**updated_permit)

    async def start_work(self, permit_id: str, started_by: str) -> WorkOrderPermit:
        """Mark work as started (updates actual start date)"""
        
        permit = await self.db.get_document("work_order_permits", permit_id)
        if not permit:
            raise ValueError("Work order permit not found")
        
        if permit.get("status") != "approved":
            raise ValueError("Work can only be started on approved permits")

        update_data = {
            "actual_start_date": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }

        await self.db.update_document("work_order_permits", permit_id, update_data)

        # Send notification to admin
        await self._send_admin_notification(
            permit_id,
            f"External work has started for permit {permit_id}"
        )

        updated_permit = await self.db.get_document("work_order_permits", permit_id)
        return WorkOrderPermit(**updated_permit)

    async def get_work_order_permit(self, permit_id: str) -> Optional[WorkOrderPermit]:
        """Get work order permit by ID"""
        permit_data = await self.db.get_document("work_order_permits", permit_id)
        return WorkOrderPermit(**permit_data) if permit_data else None

    async def get_permits_by_tenant(self, tenant_id: str) -> List[WorkOrderPermit]:
        """Get all work order permits requested by a tenant"""
        permits = await self.db.query_documents("work_order_permits", {"requested_by": tenant_id})
        return [WorkOrderPermit(**permit) for permit in permits]

    async def get_permits_by_status(self, status: str) -> List[WorkOrderPermit]:
        """Get all work order permits with specific status"""
        permits = await self.db.query_documents("work_order_permits", {"status": status})
        return [WorkOrderPermit(**permit) for permit in permits]

    async def get_pending_permits(self) -> List[WorkOrderPermit]:
        """Get all pending work order permits (Admin view)"""
        permits = await self.db.query_documents("work_order_permits", {"status": "pending"})
        return [WorkOrderPermit(**permit) for permit in permits]

    async def get_all_permits(self) -> List[WorkOrderPermit]:
        """Get all work order permits (Admin only)"""
        permits = await self.db.get_all_documents("work_order_permits")
        return [WorkOrderPermit(**permit) for permit in permits]

    async def _send_admin_notification(self, permit_id: str, message: str):
        """Send notification to all admins"""
        # Get all admin users
        admin_users = await self.db.query_documents("user_profiles", {"role": "admin"})
        
        for admin in admin_users:
            notification_data = {
                "id": str(uuid.uuid4()),
                "recipient_id": admin.get("id"),
                "title": "Work Order Permit Request",
                "message": message,
                "notification_type": "permit_request",
                "related_id": permit_id,
                "is_read": False,
                "created_at": datetime.utcnow()
            }
            await self.db.create_document("notifications", notification_data["id"], notification_data)

    async def _send_tenant_notification(self, recipient_id: str, permit_id: str, message: str):
        """Send notification to tenant about permit updates"""
        notification_data = {
            "id": str(uuid.uuid4()),
            "recipient_id": recipient_id,
            "title": "Work Order Permit Update",
            "message": message,
            "notification_type": "permit_update",
            "related_id": permit_id,
            "is_read": False,
            "created_at": datetime.utcnow()
        }
        await self.db.create_document("notifications", notification_data["id"], notification_data)
