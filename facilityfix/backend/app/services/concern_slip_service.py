from typing import List, Optional
from datetime import datetime
from app.models.database_models import ConcernSlip, Notification
from app.database.database_service import DatabaseService, database_service
from app.database.collections import COLLECTIONS
import uuid

class ConcernSlipService:
    def __init__(self):
        self.db = DatabaseService()

    async def create_concern_slip(self, reported_by: str, concern_data: dict) -> ConcernSlip:
        """Create a new concern slip - the entry point for repair/maintenance issues"""

        # Fetch reporter profile from Firestore
        success, user_profile, error = await database_service.get_document(
            COLLECTIONS['users'], reported_by
        )
        if not success or not user_profile:
            raise ValueError("Reporter profile not found")

        if user_profile.get("role") != "tenant":
            raise ValueError("Only tenants can submit concern slips")

        concern_slip_data = {
            "id": str(uuid.uuid4()),
            "reported_by": reported_by,
            "title": concern_data["title"],
            "description": concern_data["description"],
            "location": concern_data["location"],
            "category": concern_data["category"],
            "priority": concern_data.get("priority", "medium"),
            "unit_id": concern_data.get("unit_id"),
            "attachments": concern_data.get("attachments", []),
            "status": "pending",
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }

        success, doc_id, error = await self.db.create_document("concern_slips", concern_slip_data, concern_slip_data["id"])
        if not success:
            raise Exception(f"Failed to create concern slip: {error}")

        # Send notification to all admins
        await self._send_admin_notification(
            concern_slip_data["id"],
            f"New concern slip submitted: {concern_slip_data['title']}"
        )

        return ConcernSlip(**concern_slip_data)

    async def get_concern_slip(self, concern_slip_id: str) -> Optional[ConcernSlip]:
        """Get concern slip by ID"""
        # Fetch concern slip (by doc ID first)
        success, concern_data, error = await self.db.get_document("concern_slips", concern_slip_id)
        
        if not success or not concern_data:
            # Try lookup by "id" field if not found by document ID
            success, results, error = await self.db.query_documents("concern_slips", [("id", "==", concern_slip_id)])
            if not success or not results:
                return None
            concern_data = results[0]
        
        return ConcernSlip(**concern_data)

    async def get_concern_slips_by_tenant(self, tenant_id: str) -> List[ConcernSlip]:
        """Get all concern slips submitted by a tenant"""
        # Fetch concern slips by tenant ID
        success, concerns, error = await self.db.query_documents("concern_slips", [("reported_by", "==", tenant_id)])
        
        if not success or not concerns:
            return []
        
        return [ConcernSlip(**concern) for concern in concerns]

    async def get_concern_slips_by_status(self, status: str) -> List[ConcernSlip]:
        """Get all concern slips with specific status"""
        # Fetch concern slips by status
        success, concerns, error = await self.db.query_documents("concern_slips", [("status", "==", status)])
        
        if not success or not concerns:
            return []
        
        return [ConcernSlip(**concern) for concern in concerns]

    async def get_pending_concern_slips(self) -> List[ConcernSlip]:
        """Get all pending concern slips awaiting evaluation"""
        # Fetch pending concern slips
        success, concerns, error = await self.db.query_documents("concern_slips", [("status", "==", "pending")])
        
        if not success or not concerns:
            return []
        
        return [ConcernSlip(**concern) for concern in concerns]

    async def get_approved_concern_slips(self) -> List[ConcernSlip]:
        """Get all approved concern slips ready for resolution"""
        # Fetch approved concern slips
        success, concerns, error = await self.db.query_documents("concern_slips", [("status", "==", "approved")])
        
        if not success or not concerns:
            return []
        
        return [ConcernSlip(**concern) for concern in concerns]

    async def get_all_concern_slips(self) -> List[ConcernSlip]:
        """Get all concern slips (Admin only)"""
        try:
            concerns = await self.db.get_all_documents("concern_slips")
            
            if not concerns:
                return []
            
            return [ConcernSlip(**concern) for concern in concerns]
        except Exception as e:
            raise Exception(f"Failed to get concern slips: {str(e)}")

    async def _send_admin_notification(self, concern_slip_id: str, message: str):
        """Send notification to all admins"""
        # Get all admin users
        admin_users = await self.db.query_documents("user_profiles", {"role": "admin"})

        for admin in admin_users:
            notification_data = {
                "id": str(uuid.uuid4()),
                "recipient_id": admin.get("id"),
                "title": "New Concern Slip",
                "message": message,
                "notification_type": "concern_submitted",
                "related_id": concern_slip_id,
                "is_read": False,
                "created_at": datetime.utcnow()
            }
            await self.db.create_document("notifications", notification_data["id"], notification_data)

    async def _send_tenant_notification(self, recipient_id: str, concern_slip_id: str, message: str):
        """Send notification to tenant about concern slip updates"""
        notification_data = {
            "id": str(uuid.uuid4()),
            "recipient_id": recipient_id,
            "title": "Concern Slip Update",
            "message": message,
            "notification_type": "concern_update",
            "related_id": concern_slip_id,
            "is_read": False,
            "created_at": datetime.utcnow()
        }
        await self.db.create_document("notifications", notification_data["id"], notification_data)