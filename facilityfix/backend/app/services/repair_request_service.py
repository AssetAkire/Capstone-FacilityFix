from typing import Dict, List, Any, Optional
from datetime import datetime
from app.database.database_service import DatabaseService
from app.models.database_models import RepairRequest

class RepairRequestService:
    def __init__(self, db_service: DatabaseService):
        self.db_service = db_service
        self.collection_name = "repair_requests"

    async def create_repair_request(self, repair_data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            repair_data.setdefault("created_at", datetime.utcnow())
            repair_data["updated_at"] = datetime.utcnow()
            repair_request = RepairRequest(**repair_data)
            return await self.db_service.create_document(
                self.collection_name, repair_request.dict(exclude={"id"})
            )
        except Exception as e:
            raise Exception(f"Failed to create repair request: {str(e)}")
                        
    async def get_repair_requests(self, filters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Get all repair requests with optional filters"""
        try:
            if filters:
                return await self.db_service.query_documents(self.collection_name, filters)
            else:
                return await self.db_service.get_all_documents(self.collection_name)
                
        except Exception as e:
            raise Exception(f"Failed to retrieve repair requests: {str(e)}")

    async def get_repair_requests_by_user(self, user_id: str) -> List[Dict[str, Any]]:
        """Get repair requests submitted by a specific user"""
        try:
            filters = {"reported_by": user_id}
            return await self.db_service.query_documents(self.collection_name, filters)
            
        except Exception as e:
            raise Exception(f"Failed to retrieve user repair requests: {str(e)}")

    async def get_repair_request_by_id(self, request_id: str) -> Dict[str, Any]:
        """Get a specific repair request by ID"""
        try:
            request_data = await self.db_service.get_document(self.collection_name, request_id)
            if not request_data:
                raise ValueError(f"Repair request with ID {request_id} not found")
            return request_data
            
        except ValueError:
            raise
        except Exception as e:
            raise Exception(f"Failed to retrieve repair request: {str(e)}")

    async def get_repair_requests_by_status(self, status: str) -> List[Dict[str, Any]]:
        """Get repair requests filtered by status"""
        try:
            filters = {"status": status}
            return await self.db_service.query_documents(self.collection_name, filters)
            
        except Exception as e:
            raise Exception(f"Failed to retrieve repair requests by status: {str(e)}")

    async def update_repair_request_status(
        self, 
        request_id: str, 
        new_status: str, 
        updated_by: str,
        remarks: Optional[str] = None,
        assigned_to: Optional[str] = None
    ) -> Dict[str, Any]:
        """Update repair request status"""
        try:
            # Get current request
            current_request = await self.get_repair_request_by_id(request_id)
            
            # Prepare update data
            update_data = {
                "status": new_status,
                "updated_at": datetime.utcnow()
            }
            
            if assigned_to:
                update_data["assigned_to"] = assigned_to
                
            # Update the document
            await self.db_service.update_document(self.collection_name, request_id, update_data)
            
            # Log status change (you might want to implement a status history service)
            await self._log_status_change(
                request_id, 
                current_request.get("status"), 
                new_status, 
                updated_by, 
                remarks
            )
            
            # Return updated request
            return await self.get_repair_request_by_id(request_id)
            
        except ValueError:
            raise
        except Exception as e:
            raise Exception(f"Failed to update repair request status: {str(e)}")

    async def delete_repair_request(self, request_id: str, deleted_by: str) -> bool:
        """Delete a repair request (use with caution)"""
        try:
            # Verify request exists
            await self.get_repair_request_by_id(request_id)
            
            # Delete the document
            await self.db_service.delete_document(self.collection_name, request_id)
            
            return True
            
        except ValueError:
            raise
        except Exception as e:
            raise Exception(f"Failed to delete repair request: {str(e)}")

    async def _log_status_change(
        self, 
        request_id: str, 
        old_status: Optional[str], 
        new_status: str, 
        updated_by: str, 
        remarks: Optional[str]
    ):
        """Log status changes for audit trail"""
        try:
            log_data = {
                "request_id": request_id,
                "previous_status": old_status,
                "new_status": new_status,
                "updated_by": updated_by,
                "remarks": remarks,
                "timestamp": datetime.utcnow()
            }
            
            await self.db_service.create_document("repair_request_history", log_data)
            
        except Exception as e:
            # Don't fail the main operation if logging fails
            print(f"Warning: Failed to log status change: {str(e)}")
