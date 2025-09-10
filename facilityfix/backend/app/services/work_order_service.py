from typing import List, Optional, Dict, Any
from datetime import datetime
from app.database.database_service import DatabaseService
from app.models.database_models import WorkOrder, StatusHistory, Feedback, RepairRequest
from app.database.collections import COLLECTIONS

class WorkOrderService:
    def __init__(self, db_service: DatabaseService):
        self.db = db_service
        self.work_orders_collection = COLLECTIONS['work_orders']
        self.status_history_collection = COLLECTIONS['status_history']
        self.feedback_collection = COLLECTIONS['feedback']
        self.repair_request_collection = COLLECTIONS['repair_requests']
    
    async def create_work_order(self, work_order_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new work order from a repair request"""
        work_order = WorkOrder(**work_order_data)
        work_order.created_at = datetime.utcnow()
        work_order.updated_at = datetime.utcnow()

        # Create work order in database
        result = await self.db.create_document(
            self.work_orders_collection,
            work_order.dict(exclude_none=True)
        )

        # Create initial status history entry
        await self._create_status_history(
            work_order_id=result['id'],
            new_status=work_order.status,
            updated_by=work_order.created_by,
            remarks="Work order created"
        )
        
        return result
    
    async def assign_work_order(self, work_order_id: str, assigned_to: str, 
                               scheduled_date: Optional[datetime] = None, 
                               updated_by: str = None) -> Dict[str, Any]:
        """Assign work order to staff/contractor"""
        # Get current work order
        current_wo = await self.db.get_document(self.work_orders_collection, work_order_id)
        if not current_wo:
            raise ValueError("Work order not found")
        
        previous_status = current_wo.get('status')
        update_data = {
            'assigned_to': assigned_to,
            'status': 'assigned',
            'updated_at': datetime.utcnow()
        }
        
        if scheduled_date:
            update_data['scheduled_date'] = scheduled_date
        
        # Update work order
        result = await self.db.update_document(
            self.work_orders_collection, 
            work_order_id, 
            update_data
        )
        
        # Create status history entry
        await self._create_status_history(
            work_order_id=work_order_id,
            previous_status=previous_status,
            new_status='assigned',
            updated_by=updated_by or assigned_to,
            remarks=f"Assigned to {assigned_to}"
        )
        
        return result
    
    async def update_work_order_status(self, work_order_id: str, new_status: str, 
                                     updated_by: str, remarks: Optional[str] = None,
                                     additional_data: Optional[Dict] = None) -> Dict[str, Any]:
        """Update work order status with history tracking"""
        # Get current work order
        current_wo = await self.db.get_document(self.work_orders_collection, work_order_id)
        if not current_wo:
            raise ValueError("Work order not found")
        
        previous_status = current_wo.get('status')
        update_data = {
            'status': new_status,
            'updated_at': datetime.utcnow()
        }
        
        # Add completion date if status is completed
        if new_status == 'completed':
            update_data['completed_date'] = datetime.utcnow()
        
        # Add any additional data (materials, cost, etc.)
        if additional_data:
            update_data.update(additional_data)
        
        # Update work order
        result = await self.db.update_document(
            self.work_orders_collection, 
            work_order_id, 
            update_data
        )
        
        # Create status history entry
        await self._create_status_history(
            work_order_id=work_order_id,
            previous_status=previous_status,
            new_status=new_status,
            updated_by=updated_by,
            remarks=remarks
        )
        
        return result
    
    async def close_work_order(self, work_order_id: str, closed_by: str, 
                              final_notes: Optional[str] = None) -> Dict[str, Any]:
        """Close work order and update related repair request"""
        # Update work order status to closed
        result = await self.update_work_order_status(
            work_order_id=work_order_id,
            new_status='closed',
            updated_by=closed_by,
            remarks=final_notes or "Work order closed by admin"
        )
        
        # Get work order to find related repair request
        work_order = await self.db.get_document(self.work_orders_collection, work_order_id)
        if work_order and work_order.get('request_id'):
            # Update repair request status to resolved
            await self.db.update_document(
                self.repair_requests_collection,
                work_order['request_id'],
                {
                    'status': 'resolved',
                    'updated_at': datetime.utcnow()
                }
            )
        
        return result

    async def add_work_order_notes(self, work_order_id: str, notes: str, 
                                  added_by: str) -> Dict[str, Any]:
        """Add notes to work order"""
        current_wo = await self.db.get_document(self.work_orders_collection, work_order_id)
        if not current_wo:
            raise ValueError("Work order not found")
        
        # Append new notes to existing notes
        existing_notes = current_wo.get('notes', '')
        timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        new_note = f"\n[{timestamp}] {added_by}: {notes}"
        updated_notes = existing_notes + new_note
        
        return await self.db.update_document(
            self.work_orders_collection,
            work_order_id,
            {
                'notes': updated_notes,
                'updated_at': datetime.utcnow()
            }
        )

    async def submit_feedback(self, feedback_data: Dict[str, Any]) -> Dict[str, Any]:
        """Submit tenant feedback for completed work order"""
        feedback = Feedback(**feedback_data)
        feedback.submitted_at = datetime.utcnow()
        
        return await self.db.create_document(
            self.feedback_collection,
            feedback.dict(exclude_none=True)
        )

    async def get_work_orders_by_status(self, status: str) -> List[Dict[str, Any]]:
        """Get all work orders by status"""
        return await self.db.query_documents(
            self.work_orders_collection,
            [('status', '==', status)]
        )

    async def get_work_orders_by_assignee(self, assigned_to: str) -> List[Dict[str, Any]]:
        """Get work orders assigned to specific user"""
        return await self.db.query_documents(
            self.work_orders_collection,
            [('assigned_to', '==', assigned_to)]
        )

    async def get_work_order_history(self, work_order_id: str) -> List[Dict[str, Any]]:
        """Get status history for a work order"""
        return await self.db.query_documents(
            self.status_history_collection,
            [('work_order_id', '==', work_order_id)],
            order_by=[('timestamp', 'desc')]
        )

    async def _create_status_history(self, work_order_id: str, new_status: str, 
                                   updated_by: str, previous_status: Optional[str] = None,
                                   remarks: Optional[str] = None) -> Dict[str, Any]:
        """Internal method to create status history entry"""
        status_history = StatusHistory(
            work_order_id=work_order_id,
            previous_status=previous_status,
            new_status=new_status,
            updated_by=updated_by,
            remarks=remarks,
            timestamp=datetime.utcnow()
        )
        
        return await self.db.create_document(
            self.status_history_collection,
            status_history.dict(exclude_none=True)
        )