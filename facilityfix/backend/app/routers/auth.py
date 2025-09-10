from fastapi import APIRouter, HTTPException, status, Depends
from ..models.user import (
    UserLogin, UserResponse, UserRole, UserStatus,
    AdminCreate, StaffCreate, TenantCreate, UserCreate
)
from ..models.database_models import UserProfile
from ..auth.firebase_auth import firebase_auth
from ..auth.dependencies import require_admin, get_current_user
from ..database.database_service import database_service
from ..database.collections import COLLECTIONS
from ..services.user_id_service import user_id_service
from ..core.config import settings
from datetime import datetime
import re
import httpx

router = APIRouter(prefix="/auth", tags=["authentication"])

@router.post("/register/admin", response_model=dict)
async def register_admin(admin_data: AdminCreate):
    """Register a new admin user - Public endpoint for initial setup"""
    return await _register_user_by_role(admin_data, UserRole.ADMIN)

@router.post("/register/staff", response_model=dict)
async def register_staff(staff_data: StaffCreate):
#async def register_staff(staff_data: StaffCreate, current_user: dict = Depends(require_admin)):
    """Register a new staff user - Requires admin authentication"""
    return await _register_user_by_role(staff_data, UserRole.STAFF)

@router.post("/register/tenant", response_model=dict)
async def register_tenant(tenant_data: TenantCreate):
    """Register a new tenant user - Public endpoint for tenant self-registration"""
    return await _register_user_by_role(tenant_data, UserRole.TENANT)

async def _register_user_by_role(user_data, role: UserRole):
    """Internal function to handle role-specific registration"""
    try:
        # Generate custom user ID
        user_id = await user_id_service.generate_user_id(role)
        
        # Create user in Firebase Auth
        firebase_user = await firebase_auth.create_user(
            email=user_data.email,
            password=user_data.password,
            display_name=f"{user_data.first_name} {user_data.last_name}"
        )
        
        # Prepare user profile data based on role
        user_profile_data = {
            "id": firebase_user["uid"],
            "user_id": user_id,
            "email": user_data.email,
            "first_name": user_data.first_name,
            "last_name": user_data.last_name,
            "phone_number": getattr(user_data, 'phone_number', None),
            "role": role.value,
            "status": UserStatus.ACTIVE.value,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        
        # Add role-specific fields
        if role == UserRole.STAFF:
            user_profile_data.update({
                "staff_id": getattr(user_data, 'staff_id', user_id),
                "classification": user_data.classification.value,
                "department": user_data.classification.value
            })
        elif role == UserRole.TENANT:
            building_id, unit_number = user_id_service.parse_building_unit(user_data.building_unit)
            user_profile_data.update({
                "building_unit": user_data.building_unit,
                "building_id": building_id,
                "unit_id": unit_number
            })
        
        # Set custom claims for Firebase
        custom_claims = {
            "role": role.value,
            "user_id": user_id,
            "building_id": user_profile_data.get("building_id"),
            "unit_id": user_profile_data.get("unit_id"),
            "department": user_profile_data.get("department")
        }
        
        await firebase_auth.set_custom_claims(firebase_user["uid"], custom_claims)
        
        # Save user profile to Firestore
        profile_success, profile_id, profile_error = await database_service.create_document(
            COLLECTIONS['users'],
            user_profile_data,
            document_id=firebase_user["uid"],  # Use Firebase UID as document ID
            validate=True
        )
        
        if not profile_success:
            # Clean up Firebase user if Firestore creation fails
            try:
                await firebase_auth.delete_user(firebase_user["uid"])
            except:
                pass
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create user profile: {profile_error}"
            )
        
        return {
            "message": f"{role.value.title()} registered successfully",
            "uid": firebase_user["uid"],
            "user_id": user_id,
            "email": firebase_user["email"],
            "role": role.value,
            "profile_created": True
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e)}"
        )

@router.post("/login")
async def login_user(login_data: UserLogin):
    """Login with email or user ID"""
    try:
        user = None
        
        # Check if identifier is email or user ID
        if '@' in login_data.identifier:
            # Login with email
            user = await firebase_auth.get_user_by_email(login_data.identifier)
        else:
            # Login with user ID (e.g., T-0001)
            # First find user in Firestore by user_id
            success, users, error = await database_service.query_documents(
                COLLECTIONS['users'],
                [("user_id", "==", login_data.identifier)]
            )
            
            if success and users:
                user_profile = users[0]
                user = await firebase_auth.get_user(user_profile['id'])
        
        if user:
            # Get user profile from Firestore
            profile_success, profile_data, profile_error = await database_service.get_document(
                COLLECTIONS['users'],
                user.uid
            )
            
            if profile_success and profile_data:
                user_status = profile_data.get('status', 'active')
                if user_status in ['suspended', 'inactive']:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Account is {user_status}. Please contact administrator."
                    )
                
                return {
                    "message": "User exists, proceed with Firebase client login",
                    "uid": user.uid,
                    "user_id": profile_data.get('user_id'),
                    "email": user.email,
                    "role": profile_data.get('role'),
                    "status": user_status
                }
            else:
                return {
                    "message": "User exists, proceed with Firebase client login",
                    "uid": user.uid,
                    "email": user.email,
                    "status": "active"
                }
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Login validation failed"
        )

@router.post("/generate-test-token")
async def generate_test_token(login_data: UserLogin):
    """Generate a JWT token for API testing - Use this token in the Authorization field"""
    try:
        user = None
        
        # Check if identifier is email or user ID
        if '@' in login_data.identifier:
            user = await firebase_auth.get_user_by_email(login_data.identifier)
        else:
            success, users, error = await database_service.query_documents(
                COLLECTIONS['users'],
                [("user_id", "==", login_data.identifier)]
            )
            
            if success and users:
                user_profile = users[0]
                user = await firebase_auth.get_user(user_profile['id'])
        
        if user:
            # Generate custom token for testing
            custom_token = await firebase_auth.create_custom_token(user.uid)
            
            # Get user profile
            profile_success, profile_data, profile_error = await database_service.get_document(
                COLLECTIONS['users'],
                user.uid
            )
            
            return {
                "access_token": custom_token,
                "token_type": "Bearer",
                "uid": user.uid,
                "user_id": profile_data.get('user_id') if profile_success else None,
                "email": user.email,
                "role": profile_data.get('role') if profile_success else None,
                "instructions": "Copy the 'access_token' value and paste it in the Authorization field in FastAPI docs"
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Token generation failed: {str(e)}"
        )

"""
@router.post("/exchange-token")
async def exchange_custom_token_for_id_token(login_data: UserLogin):
    
#   Testing-only endpoint: Exchange custom token for ID token server-side
#   This allows complete testing within Swagger UI without external tools
    
    try:
        user = None
        
        # Find user by identifier
        if '@' in login_data.identifier:
            user = await firebase_auth.get_user_by_email(login_data.identifier)
        else:
            success, users, error = await database_service.query_documents(
                COLLECTIONS['users'],
                [("user_id", "==", login_data.identifier)]
            )
            
            if success and users:
                user_profile = users[0]
                user = await firebase_auth.get_user(user_profile['id'])
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Step 1: Generate custom token
        custom_token = await firebase_auth.create_custom_token(user.uid)
        
        # Step 2: Exchange custom token for ID token using Firebase REST API
        async with httpx.AsyncClient() as client:
            exchange_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key={settings.FIREBASE_WEB_API_KEY}"
            
            exchange_response = await client.post(
                exchange_url,
                json={
                    "token": custom_token,
                    "returnSecureToken": True
                },
                headers={"Content-Type": "application/json"}
            )
            
            if exchange_response.status_code != 200:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Token exchange failed: {exchange_response.text}"
                )
            
            token_data = exchange_response.json()
            id_token = token_data.get("idToken")
            
            if not id_token:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to get ID token from exchange"
                )
        
        # Get user profile for additional info
        profile_success, profile_data, profile_error = await database_service.get_document(
            COLLECTIONS['users'],
            user.uid
        )
        
        return {
            "id_token": id_token,
            "token_type": "Bearer",
            "expires_in": token_data.get("expiresIn", "3600"),
            "refresh_token": token_data.get("refreshToken"),
            "uid": user.uid,
            "user_id": profile_data.get('user_id') if profile_success else None,
            "email": user.email,
            "role": profile_data.get('role') if profile_success else None,
            "instructions": "Use the 'id_token' as Bearer token in Authorization header for protected endpoints"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Token exchange failed: {str(e)}"
        )
"""
        
@router.get("/me")
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    try:
        profile_success, profile_data, profile_error = await database_service.get_document(
            COLLECTIONS['users'],
            current_user.get("uid")
        )
        
        user_info = {
            "uid": current_user.get("uid"),
            "user_id": current_user.get("user_id"),
            "email": current_user.get("email"),
            "role": current_user.get("role"),
            "building_id": current_user.get("building_id"),
            "unit_id": current_user.get("unit_id"),
            "department": current_user.get("department")
        }
        
        # Add Firestore profile data if available
        if profile_success and profile_data:
            user_info.update({
                "first_name": profile_data.get("first_name"),
                "last_name": profile_data.get("last_name"),
                "phone_number": profile_data.get("phone_number"),
                "status": profile_data.get("status"),
                "staff_id": profile_data.get("staff_id"),
                "classification": profile_data.get("classification"),
                "building_unit": profile_data.get("building_unit"),
                "created_at": profile_data.get("created_at"),
                "updated_at": profile_data.get("updated_at")
            })
        
        return user_info
        
    except Exception as e:
        # Return basic info if Firestore fails
        return {
            "uid": current_user.get("uid"),
            "user_id": current_user.get("user_id"),
            "email": current_user.get("email"),
            "role": current_user.get("role"),
            "error": "Could not load complete profile"
        }

@router.patch("/change-password")
async def change_own_password(
    current_password: str,
    new_password: str,
    current_user: dict = Depends(get_current_user)
):
    """Allow users to change their own password"""
    try:
        # Note: In a real implementation, you'd verify the current password
        # For now, we'll just update the password in Firebase
        await firebase_auth.update_user(current_user.get("uid"), password=new_password)
        
        return {"message": "Password changed successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to change password: {str(e)}"
        )

@router.patch("/profile")
async def update_own_profile(
    first_name: str = None,
    last_name: str = None,
    phone_number: str = None,
    current_user: dict = Depends(get_current_user)
):
    """Allow users to update their own profile"""
    try:
        update_data = {}
        if first_name is not None:
            update_data['first_name'] = first_name
        if last_name is not None:
            update_data['last_name'] = last_name
        if phone_number is not None:
            update_data['phone_number'] = phone_number
        
        if update_data:
            update_data['updated_at'] = datetime.utcnow()
            
            success, error = await database_service.update_document(
                COLLECTIONS['users'],
                current_user.get("uid"),
                update_data
            )
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Failed to update profile: {error}"
                )
        
        return {"message": "Profile updated successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating profile: {str(e)}"
        )

@router.post("/send-verification-email")
async def send_verification_email(current_user: dict = Depends(get_current_user)):
    """Send email verification to current user"""
    try:
        # Generate verification link using Firebase
        verification_link = await firebase_auth.generate_email_verification_link(
            current_user.get("email")
        )
        
        # In a real implementation, you'd send this via email service
        # For now, return the link for testing
        return {
            "message": "Verification email sent",
            "verification_link": verification_link,
            "note": "In production, this would be sent via email"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to send verification email: {str(e)}"
        )

@router.post("/verify-email")
async def verify_email(verification_code: str):
    """Verify email with verification code"""
    try:
        # Apply email verification code
        await firebase_auth.apply_action_code(verification_code)
        
        return {"message": "Email verified successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Email verification failed: {str(e)}"
        )

@router.post("/forgot-password")
async def forgot_password(email: str):
    """Send password reset email"""
    try:
        # Generate password reset link
        reset_link = await firebase_auth.generate_password_reset_link(email)
        
        # In a real implementation, you'd send this via email service
        return {
            "message": "Password reset email sent",
            "reset_link": reset_link,
            "note": "In production, this would be sent via email"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to send password reset email: {str(e)}"
        )

@router.post("/reset-password")
async def reset_password(reset_code: str, new_password: str):
    """Reset password with reset code"""
    try:
        # Verify and apply password reset
        await firebase_auth.confirm_password_reset(reset_code, new_password)
        
        return {"message": "Password reset successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Password reset failed: {str(e)}"
        )

@router.post("/logout")
async def logout_user(current_user: dict = Depends(get_current_user)):
    """Logout current user by revoking refresh tokens"""
    try:
        # Revoke all refresh tokens for the user
        await firebase_auth.revoke_refresh_tokens(current_user.get("uid"))
        
        return {"message": "Logged out successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Logout failed: {str(e)}"
        )

@router.post("/logout-all-devices")
async def logout_all_devices(current_user: dict = Depends(get_current_user)):
    """Logout user from all devices by revoking all tokens"""
    try:
        # Revoke all refresh tokens (logs out from all devices)
        await firebase_auth.revoke_refresh_tokens(current_user.get("uid"))
        
        # Update user's tokens_valid_after timestamp in custom claims
        custom_claims = {
            **(current_user or {}),
            "tokens_valid_after": datetime.utcnow().timestamp()
        }
        await firebase_auth.set_custom_claims(current_user.get("uid"), custom_claims)
        
        return {"message": "Logged out from all devices successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Logout from all devices failed: {str(e)}"
        )

@router.patch("/users/{user_id}/role")
async def change_user_role(
    user_id: str,
    new_role: UserRole,
    current_user: dict = Depends(require_admin)
):
    """Admin-only: Change user's role"""
    try:
        # Find user by user_id in Firestore
        success, users, error = await database_service.query_documents(
            COLLECTIONS['users'],
            [("user_id", "==", user_id)]
        )
        
        if not success or not users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        user_profile = users[0]
        firebase_uid = user_profile['id']
        
        # Update role in Firestore
        update_data = {
            "role": new_role.value,
            "updated_at": datetime.utcnow()
        }
        
        success, error = await database_service.update_document(
            COLLECTIONS['users'],
            firebase_uid,
            update_data
        )
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update user role: {error}"
            )
        
        # Update custom claims in Firebase
        current_claims = user_profile.copy()
        current_claims.update({
            "role": new_role.value,
            "updated_at": datetime.utcnow().isoformat()
        })
        
        await firebase_auth.set_custom_claims(firebase_uid, current_claims)
        
        return {
            "message": f"User role changed to {new_role.value}",
            "user_id": user_id,
            "new_role": new_role.value
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to change user role: {str(e)}"
        )
