from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from ..models.user import UserResponse, UserRole
from ..models.database_models import UserProfile
from ..auth.dependencies import require_admin, require_staff_or_admin, get_current_user
from ..database.database_service import database_service
from ..database.collections import COLLECTIONS
from ..auth.firebase_auth import firebase_auth
from pydantic import BaseModel, EmailStr
from datetime import datetime

router = APIRouter(prefix="/users", tags=["user-management"])

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    department: Optional[str] = None
    building_id: Optional[str] = None
    unit_id: Optional[str] = None

class UserStatusUpdate(BaseModel):
    status: str  # active, suspended, inactive

class PasswordChange(BaseModel):
    new_password: str

class UserSearchFilters(BaseModel):
    role: Optional[UserRole] = None
    building_id: Optional[str] = None
    status: Optional[str] = None
    department: Optional[str] = None

@router.get("/", response_model=List[dict])
async def get_users(
    role: Optional[str] = Query(None, description="Filter by user role"),
    building_id: Optional[str] = Query(None, description="Filter by building ID"),
    status: Optional[str] = Query(None, description="Filter by user status"),
    department: Optional[str] = Query(None, description="Filter by department"),
    limit: Optional[int] = Query(50, description="Maximum number of users to return"),
    current_user: dict = Depends(require_staff_or_admin)
):
    """Get all users with optional filtering"""
    try:
        # Build filters
        filters = []
        if role:
            filters.append(('role', '==', role))
        if building_id:
            filters.append(('building_id', '==', building_id))
        if status:
            filters.append(('status', '==', status))
        if department:
            filters.append(('department', '==', department))
        
        # Query users from Firestore
        success, users, error = await database_service.query_collection(
            COLLECTIONS['users'], 
            filters=filters if filters else None,
            limit=limit
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve users: {error}"
            )
        
        return users
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving users: {str(e)}"
        )

@router.get("/{user_id}")
async def get_user(
    user_id: str,
    current_user: dict = Depends(require_staff_or_admin)
):
    """Get a specific user by ID"""
    try:
        # Get user from Firestore
        success, user_data, error = await database_service.get_document(
            COLLECTIONS['users'], 
            user_id
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User not found: {error}"
            )
        
        # Get Firebase Auth data
        try:
            firebase_user = await firebase_auth.get_user_by_email(user_data.get('email', ''))
            if firebase_user:
                user_data['firebase_uid'] = firebase_user.uid
                user_data['email_verified'] = firebase_user.email_verified
                user_data['last_sign_in'] = firebase_user.user_metadata.last_sign_in_time
        except:
            pass  # Firebase data is optional
        
        return user_data
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving user: {str(e)}"
        )

@router.put("/{user_id}")
async def update_user(
    user_id: str,
    user_update: UserUpdate,
    current_user: dict = Depends(require_admin)
):
    """Update user profile information"""
    try:
        # Prepare update data
        update_data = {}
        if user_update.first_name is not None:
            update_data['first_name'] = user_update.first_name
        if user_update.last_name is not None:
            update_data['last_name'] = user_update.last_name
        if user_update.phone_number is not None:
            update_data['phone_number'] = user_update.phone_number
        if user_update.department is not None:
            update_data['department'] = user_update.department
        if user_update.building_id is not None:
            update_data['building_id'] = user_update.building_id
        if user_update.unit_id is not None:
            update_data['unit_id'] = user_update.unit_id
        
        update_data['updated_at'] = datetime.utcnow()
        
        # Update user in Firestore
        success, error = await database_service.update_document(
            COLLECTIONS['users'],
            user_id,
            update_data
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update user: {error}"
            )
        
        return {"message": "User updated successfully", "user_id": user_id}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating user: {str(e)}"
        )

@router.patch("/{user_id}/status")
async def update_user_status(
    user_id: str,
    status_update: UserStatusUpdate,
    current_user: dict = Depends(require_admin)
):
    """Update user status (active, suspended, inactive)"""
    try:
        valid_statuses = ['active', 'suspended', 'inactive']
        if status_update.status not in valid_statuses:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status. Must be one of: {valid_statuses}"
            )
        
        update_data = {
            'status': status_update.status,
            'updated_at': datetime.utcnow()
        }
        
        # Update user status in Firestore
        success, error = await database_service.update_document(
            COLLECTIONS['users'],
            user_id,
            update_data
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update user status: {error}"
            )
        
        return {
            "message": f"User status updated to {status_update.status}",
            "user_id": user_id,
            "new_status": status_update.status
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating user status: {str(e)}"
        )

@router.delete("/{user_id}")
async def delete_user(
    user_id: str,
    permanent: bool = Query(False, description="Permanently delete user (default: deactivate)"),
    current_user: dict = Depends(require_admin)
):
    """Delete or deactivate a user"""
    try:
        if permanent:
            # Permanently delete user from Firestore
            success, error = await database_service.delete_document(
                COLLECTIONS['users'],
                user_id
            )
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to delete user: {error}"
                )
            
            # Also delete from Firebase Auth if possible
            try:
                firebase_auth.delete_user(user_id)
            except:
                pass  # Firebase deletion is optional
            
            return {"message": "User permanently deleted", "user_id": user_id}
        else:
            # Soft delete - just deactivate
            update_data = {
                'status': 'inactive',
                'updated_at': datetime.utcnow()
            }
            
            success, error = await database_service.update_document(
                COLLECTIONS['users'],
                user_id,
                update_data
            )
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to deactivate user: {error}"
                )
            
            return {"message": "User deactivated", "user_id": user_id}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting user: {str(e)}"
        )

@router.patch("/{user_id}/password")
async def change_user_password(
    user_id: str,
    password_change: PasswordChange,
    current_user: dict = Depends(require_admin)
):
    """Change user password (Admin only)"""
    try:
        # Update password in Firebase Auth
        firebase_auth.update_user(user_id, password=password_change.new_password)
        
        return {"message": "Password updated successfully", "user_id": user_id}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update password: {str(e)}"
        )

@router.get("/stats/overview")
async def get_user_statistics(
    current_user: dict = Depends(require_admin)
):
    """Get user statistics overview"""
    try:
        # Get all users
        success, all_users, error = await database_service.query_collection(COLLECTIONS['users'])
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to retrieve user statistics: {error}"
            )
        
        # Calculate statistics
        total_users = len(all_users)
        role_counts = {}
        status_counts = {}
        building_counts = {}
        
        for user in all_users:
            # Count by role
            role = user.get('role', 'unknown')
            role_counts[role] = role_counts.get(role, 0) + 1
            
            # Count by status
            status = user.get('status', 'unknown')
            status_counts[status] = status_counts.get(status, 0) + 1
            
            # Count by building
            building_id = user.get('building_id', 'unassigned')
            building_counts[building_id] = building_counts.get(building_id, 0) + 1
        
        return {
            "total_users": total_users,
            "by_role": role_counts,
            "by_status": status_counts,
            "by_building": building_counts
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error retrieving user statistics: {str(e)}"
        )

@router.post("/bulk/status")
async def bulk_update_user_status(
    user_ids: List[str],
    new_status: str,
    current_user: dict = Depends(require_admin)
):
    """Bulk update user status"""
    try:
        valid_statuses = ['active', 'suspended', 'inactive']
        if new_status not in valid_statuses:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status. Must be one of: {valid_statuses}"
            )
        
        results = []
        update_data = {
            'status': new_status,
            'updated_at': datetime.utcnow()
        }
        
        for user_id in user_ids:
            try:
                success, error = await database_service.update_document(
                    COLLECTIONS['users'],
                    user_id,
                    update_data
                )
                
                results.append({
                    "user_id": user_id,
                    "success": success,
                    "error": error if not success else None
                })
            except Exception as e:
                results.append({
                    "user_id": user_id,
                    "success": False,
                    "error": str(e)
                })
        
        successful_updates = sum(1 for r in results if r["success"])
        
        return {
            "message": f"Bulk update completed. {successful_updates}/{len(user_ids)} users updated.",
            "new_status": new_status,
            "results": results
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error in bulk update: {str(e)}"
        )
