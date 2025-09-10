from typing import Dict, Any, List, Optional
from .firestore_client import get_firestore_client
from .schema_validator import schema_validator
from .collections import COLLECTIONS
from datetime import datetime

class DatabaseService:
    """High-level database service with validation and error handling"""
    
    def __init__(self):
        self.client = get_firestore_client()
        if not self.client:
            raise Exception("Firestore client not available")
    
    async def create_document(self, collection: str, data: Dict[str, Any], 
                            document_id: str = None, validate: bool = True) -> tuple[bool, str, Optional[str]]:
        """
        Create a document with validation
        
        Args:
            collection: Collection name
            data: Document data
            document_id: Optional custom document ID (if None, auto-generates)
            validate: Whether to validate against schema
            
        Returns:
            Tuple of (success, document_id_or_error, error_message)
        """
        try:
            # Validate schema if requested
            if validate:
                is_valid, error_msg = schema_validator.validate_document(collection, data)
                if not is_valid:
                    return False, f"Validation failed: {error_msg}", error_msg
            
            # Create document with custom ID if provided
            doc_id = self.client.create_document(collection, document_id=document_id, data=data)
            return True, doc_id, None
            
        except Exception as e:
            error_msg = f"Failed to create document in {collection}: {str(e)}"
            return False, error_msg, error_msg
    
    async def get_document(self, collection: str, document_id: str) -> tuple[bool, Optional[Dict[str, Any]], Optional[str]]:
        """
        Get a document by ID
        
        Returns:
            Tuple of (success, document_data, error_message)
        """
        try:
            doc_data = self.client.get_document(collection, document_id)
            if doc_data:
                return True, doc_data, None
            else:
                return False, None, f"Document {document_id} not found in {collection}"
                
        except Exception as e:
            error_msg = f"Failed to get document {document_id} from {collection}: {str(e)}"
            return False, None, error_msg
    
    async def update_document(self, collection: str, document_id: str, 
                            data: Dict[str, Any], validate: bool = True) -> tuple[bool, Optional[str]]:
        """
        Update a document with validation
        
        Returns:
            Tuple of (success, error_message)
        """
        try:
            # Get existing document for validation
            if validate:
                existing_doc = self.client.get_document(collection, document_id)
                if not existing_doc:
                    return False, f"Document {document_id} not found in {collection}"
                
                # Merge with existing data for validation
                merged_data = {**existing_doc, **data}
                is_valid, error_msg = schema_validator.validate_document(collection, merged_data)
                if not is_valid:
                    return False, f"Validation failed: {error_msg}"
            
            # Update document
            success = self.client.update_document(collection, document_id, data)
            if success:
                return True, None
            else:
                return False, "Update operation failed"
                
        except Exception as e:
            error_msg = f"Failed to update document {document_id} in {collection}: {str(e)}"
            return False, error_msg
    
    async def delete_document(self, collection: str, document_id: str) -> tuple[bool, Optional[str]]:
        """
        Delete a document
        
        Returns:
            Tuple of (success, error_message)
        """
        try:
            success = self.client.delete_document(collection, document_id)
            if success:
                return True, None
            else:
                return False, "Delete operation failed"
                
        except Exception as e:
            error_msg = f"Failed to delete document {document_id} from {collection}: {str(e)}"
            return False, error_msg
    
    async def query_collection(self, collection: str, filters: List[tuple] = None, 
                             limit: int = None) -> tuple[bool, List[Dict[str, Any]], Optional[str]]:
        """
        Query a collection with filters
        
        Returns:
            Tuple of (success, documents, error_message)
        """
        try:
            documents = self.client.get_collection(collection, filters, limit)
            return True, documents, None
            
        except Exception as e:
            error_msg = f"Failed to query collection {collection}: {str(e)}"
            return False, [], error_msg
    
    async def query_documents(self, collection: str, filters: List[tuple] = None, 
                            limit: int = None) -> tuple[bool, List[Dict[str, Any]], Optional[str]]:
        """
        Query documents in a collection with filters (alias for query_collection)
        
        Args:
            collection: Collection name
            filters: List of filter tuples (field, operator, value)
            limit: Maximum number of documents to return
            
        Returns:
            Tuple of (success, documents, error_message)
        """
        return await self.query_collection(collection, filters, limit)
    
    async def get_building_data(self, building_id: str) -> tuple[bool, Dict[str, Any], Optional[str]]:
        """
        Get comprehensive building data including units, equipment, etc.
        
        Returns:
            Tuple of (success, building_data, error_message)
        """
        try:
            # Get building info
            building_success, building_data, building_error = await self.get_document('buildings', building_id)
            if not building_success:
                return False, {}, building_error
            
            # Get related data
            units_success, units, _ = await self.query_collection('units', [('building_id', '==', building_id)])
            equipment_success, equipment, _ = await self.query_collection('equipment', [('building_id', '==', building_id)])
            inventory_success, inventory, _ = await self.query_collection('inventory', [('building_id', '==', building_id)])
            
            # Combine data
            comprehensive_data = {
                'building': building_data,
                'units': units if units_success else [],
                'equipment': equipment if equipment_success else [],
                'inventory': inventory if inventory_success else []
            }
            
            return True, comprehensive_data, None
            
        except Exception as e:
            error_msg = f"Failed to get building data for {building_id}: {str(e)}"
            return False, {}, error_msg

# Create global service instance
database_service = DatabaseService()
