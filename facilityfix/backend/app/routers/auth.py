"""
Authentication & account routes for FacilityFix.

Login rules (server-validated):
- Admin:  email, user_id, password
- Staff:  email, user_id, staffDepartment, password
- Tenant: email, user_id, buildingUnitId, password

Flow:
1) Validate required fields based on role.
2) Resolve Firebase user (email ↔ user_id), verify role & profile match.
3) Verify password via Firebase signInWithPassword (returns ID token).
4) Return id_token + profile info.

"""

from __future__ import annotations

import logging
from datetime import datetime
from typing import Any, Dict, Optional, Tuple, Union

import httpx
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, EmailStr
from typing_extensions import Literal

# Domain models
from ..models.user import (
    UserLogin, UserResponse, UserRole, UserStatus,
    AdminCreate, StaffCreate, TenantCreate, UserCreate,
    AdminLogin, StaffLogin, TenantLogin    
)

from ..models.database_models import UserProfile  # noqa: F401

# Auth/admin deps
from ..auth.firebase_auth import firebase_auth
from ..auth.dependencies import require_admin, get_current_user

# DB
from ..database.database_service import database_service
from ..database.collections import COLLECTIONS

# Services & settings
from ..services.user_id_service import user_id_service
from ..core.config import settings

logger = logging.getLogger("facilityfix.routers.auth")

router = APIRouter(prefix="/auth", tags=["authentication"])

#<<<<<<< back-end
@router.post("/login/admin")
async def login_admin(login_data: AdminLogin):
    """Admin login with userEmail, userId, and userPassword"""
    return await _login_user_by_role(
        email=login_data.userEmail,
        user_id=login_data.userId,
        password=login_data.userPassword,
        role=UserRole.ADMIN
    )

@router.post("/login/staff")
async def login_staff(login_data: StaffLogin):
    """Staff login with userEmail, userId, userDepartment, and userPassword"""
    return await _login_user_by_role(
        email=login_data.userEmail,
        user_id=login_data.userId,
        password=login_data.userPassword,
        role=UserRole.STAFF,
        department=login_data.userDepartment
    )

@router.post("/login/tenant")
async def login_tenant(login_data: TenantLogin):
    """Tenant login with userEmail, userId, buildingUnitNo, and userPassword"""
    return await _login_user_by_role(
        email=login_data.userEmail,
        user_id=login_data.userId,
        password=login_data.userPassword,
        role=UserRole.TENANT,
        building_unit=login_data.buildingUnitNo
    )

async def _login_user_by_role(email: str, user_id: str, password: str, role: UserRole, **kwargs):
    """Internal function to handle role-specific login validation"""
    try:
        # Verify user exists by email
        user = await firebase_auth.get_user_by_email(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Get user profile from Firestore
        profile_success, profile_data, profile_error = await database_service.get_document(
            COLLECTIONS['users'],
            user.uid
        )
        
        if not profile_success or not profile_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        # Validate role matches
        if profile_data.get('role') != role.value:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Invalid role. Expected {role.value}"
            )
        
        # Validate user_id matches
        if profile_data.get('user_id') != user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid user ID"
            )
        
        # Role-specific validations
        if role == UserRole.STAFF:
            department = kwargs.get('department')
            if profile_data.get('department') != department:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid department"
                )
        elif role == UserRole.TENANT:
            building_unit = kwargs.get('building_unit')
            if profile_data.get('building_unit') != building_unit:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid building unit"
                )
        
        # Check user status
        user_status = profile_data.get('status', 'active')
        if user_status in ['suspended', 'inactive']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Account is {user_status}. Please contact administrator."
            )
        
        return {
            "message": "Login validation successful, proceed with Firebase client authentication",
            "uid": user.uid,
            "user_id": profile_data.get('user_id'),
            "email": user.email,
            "role": profile_data.get('role'),
            "status": user_status
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Login validation failed"
        )
#=======

# Request models
class AdminLogin(BaseModel):
    role: Literal["admin"]
    email: EmailStr
    user_id: str
    password: str

class StaffLogin(BaseModel):
    role: Literal["staff"]
    email: EmailStr
    user_id: str
    staffDepartment: str
    password: str

class TenantLogin(BaseModel):
    role: Literal["tenant"]
    email: EmailStr
    user_id: str
    buildingUnitId: str
    password: str

LoginBody = Union[AdminLogin, StaffLogin, TenantLogin]

# Utilities

def _model_dump(obj: Any) -> Dict[str, Any]:
    try:
        return obj.model_dump(exclude_none=True)  # Pydantic v2
    except AttributeError:
        try:
            return obj.dict(exclude_none=True)    # Pydantic v1
        except Exception:
            return dict(getattr(obj, "__dict__", {}))


def _redact_sensitive(d: Dict[str, Any]) -> Dict[str, Any]:
    redacted = dict(d)
    if "password" in redacted and redacted["password"] is not None:
        redacted["password"] = "***"
    return redacted


async def _get_profile_by_uid(uid: str) -> Tuple[bool, Optional[Dict[str, Any]], Optional[str]]:
    return await database_service.get_document(COLLECTIONS["users"], uid)


async def _get_user_doc_by_user_id(user_id: str) -> Optional[Dict[str, Any]]:
    success, users, _ = await database_service.query_documents(
        COLLECTIONS["users"], [("user_id", "==", user_id)]
    )
    if success and users:
        return users[0]
    return None


async def _sign_in_with_password(email: str, password: str) -> Dict[str, Any]:
    """
    Server-side password verification using Firebase REST API.
    Returns token payload {idToken, refreshToken, expiresIn, localId, ...}
    """
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={settings.FIREBASE_WEB_API_KEY}"
    payload = {"email": email, "password": password, "returnSecureToken": True}
    async with httpx.AsyncClient() as client:
        resp = await client.post(url, json=payload, headers={"Content-Type": "application/json"})
    if resp.status_code != 200:
        # Leak as little as possible
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    return resp.json()


def _normalize_building_unit(s: Optional[str]) -> Optional[str]:
    if not s:
        return s
    return s.strip().replace(" ", "").upper()


# Registration 
#>>>>>>> back-end

@router.post("/register/admin", response_model=dict)
async def register_admin(admin_data: AdminCreate) -> Dict[str, Any]:
    """Register a new admin user - Public endpoint for initial setup."""
    return await _register_user_by_role(admin_data, UserRole.ADMIN)


@router.post("/register/staff", response_model=dict)
#<<<<<<< back-end
async def register_staff(staff_data: StaffCreate, current_user: dict = Depends(require_admin)):
    """Register a new staff user - Requires admin authentication"""
#=======
async def register_staff(staff_data: StaffCreate) -> Dict[str, Any]:
    """Register a new staff user."""
    # To require admin auth: add param current_user: dict = Depends(require_admin)
#>>>>>>> back-end
    return await _register_user_by_role(staff_data, UserRole.STAFF)


@router.post("/register/tenant", response_model=dict)
async def register_tenant(tenant_data: TenantCreate) -> Dict[str, Any]:
    """Register a new tenant user - Public endpoint for tenant self-registration."""
    return await _register_user_by_role(tenant_data, UserRole.TENANT)


async def _register_user_by_role(
    user_data: Union[AdminCreate, StaffCreate, TenantCreate, UserCreate],
    role: UserRole
) -> Dict[str, Any]:
    # Safe log
    try:
        logger.info("Registration request role=%s payload=%s", role.value, _redact_sensitive(_model_dump(user_data)))
    except Exception:
        logger.debug("Could not log registration payload.", exc_info=True)

    try:
        # Generate short user ID
        user_id = await user_id_service.generate_user_id(role)

        # Create user in Firebase Auth
        firebase_user = await firebase_auth.create_user(
#<<<<<<< back-end
            email=user_data.userEmail,  # Updated field name
            password=user_data.userPassword,  # Updated field name
            display_name=f"{user_data.firstName} {user_data.lastName}"  # Updated field names
#=======
            email=user_data.email,
            password=user_data.password,
            display_name=f"{user_data.first_name} {user_data.last_name}",
#>>>>>>> back-end
        )

        # Profile doc
        profile: Dict[str, Any] = {
            "id": firebase_user["uid"],
            "user_id": user_id,
#<<<<<<< back-end
            "email": user_data.userEmail,  # Updated field name
            "first_name": user_data.firstName,  # Updated field name
            "last_name": user_data.lastName,  # Updated field name
            "phone_number": user_data.contactNumber,  # Updated field name
            "birth_date": user_data.birthDate,  # Added birth date
#=======
            "email": user_data.email,
            "first_name": user_data.first_name,
            "last_name": user_data.last_name,
            "phone_number": getattr(user_data, "phone_number", None),
#>>>>>>> back-end
            "role": role.value,
            "status": UserStatus.ACTIVE.value,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }

        if role == UserRole.STAFF:
#<<<<<<< back-end
            user_profile_data.update({
                "staff_id": user_id,
                "department": user_data.staffDepartment,  # Updated field name
                "classification": user_data.staffDepartment  # Use department as classification
            })
        elif role == UserRole.TENANT:
            building_id, unit_number = user_id_service.parse_building_unit(user_data.buildingUnitNo)  # Updated field name
            user_profile_data.update({
                "building_unit": user_data.buildingUnitNo,  # Updated field name
#=======
            profile.update({
                "staff_id": getattr(user_data, "staff_id", user_id),
                "classification": user_data.classification.value,
                "department": user_data.classification.value,
            })
        elif role == UserRole.TENANT:
            building_id, unit_number = user_id_service.parse_building_unit(user_data.building_unit)
            profile.update({
                "building_unit": user_data.building_unit,
#>>>>>>> back-end
                "building_id": building_id,
                "unit_id": unit_number,
            })

        # Custom claims
        claims = {
            "role": role.value,
            "user_id": user_id,
            "building_id": profile.get("building_id"),
            "unit_id": profile.get("unit_id"),
            "department": profile.get("department"),
        }
        await firebase_auth.set_custom_claims(firebase_user["uid"], claims)

        # Save profile
        ok, _, err = await database_service.create_document(
            COLLECTIONS["users"], profile, document_id=firebase_user["uid"], validate=True
        )
        if not ok:
            try:
                await firebase_auth.delete_user(firebase_user["uid"])
            except Exception:
                logger.warning("Rollback Firebase user failed.", exc_info=True)
            raise HTTPException(status_code=500, detail=f"Failed to create user profile: {err}")

        logger.info("Registered %s uid=%s user_id=%s email=%s", role.value, firebase_user["uid"], user_id, user_data.email)
        return {
            "message": f"{role.value.title()} registered successfully",
            "uid": firebase_user["uid"],
            "user_id": user_id,
            "email": firebase_user["email"],
            "role": role.value,
            "profile_created": True,
        }

#<<<<<<< back-end
@router.post("/login")
async def login_user(login_data: UserLogin):
    """Generic login with email or user ID - Backward compatibility"""
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
#=======
#>>>>>>> back-end
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Registration failed role=%s", role.value)
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")


#<<<<<<< back-end
@router.post("/exchange-token")
async def exchange_custom_token_for_id_token(login_data: UserLogin):
    """
    Exchange custom token for ID token (testing-only endpoint).
    Allows testing in Swagger UI without external tools.
    """
    try:
        user = None

        # Find user by identifier (email or user_id)
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
            exchange_url = (
                f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken"
                f"?key={settings.FIREBASE_WEB_API_KEY}"
            )

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

        # Step 3: Fetch user profile from Firestore (match by Firebase UID)
        profile_success, profile_docs, profile_error = await database_service.query_documents(
            COLLECTIONS['users'],
            [("id", "==", user.uid)]
        )
        profile_data = profile_docs[0] if profile_success and profile_docs else {}

        return {
            "id_token": id_token,
            "token_type": "Bearer",
            "expires_in": token_data.get("expiresIn", "3600"),
            "refresh_token": token_data.get("refreshToken"),
            "uid": user.uid,
            "user_id": profile_data.get("user_id"),
            "email": user.email,
            "role": profile_data.get("role"),
            "instructions": "Use the 'id_token' as Bearer token in Authorization header for protected endpoints"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Token exchange failed: {str(e)}"
        )
        
        # Get user profile for additional info
        profile_success, profile_data, profile_error = await database_service.get_document(
            COLLECTIONS['users'],
            user.uid
        )
        
        return {
#=======
# LOGIN (role-based required fields + server-side password check)

@router.post("/login")
async def login_user(body: LoginBody) -> Dict[str, Any]:
    """
    Role-based login with server-side password check.
    Expects AdminLogin | StaffLogin | TenantLogin.
    """
    try:
        # Safe log without password
        logger.info("Login attempt: %s", _redact_sensitive(_model_dump(body)))

        # 1) Resolve Firebase user by email and cross-check user_id via Firestore
        #    (email & user_id are required by all role bodies)
        email = body.email
        user_id = body.user_id

        # Find Firebase user by email
        user = await firebase_auth.get_user_by_email(email)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Fetch Firestore profile by UID
        prof_ok, profile, _ = await _get_profile_by_uid(user.uid)
        if not prof_ok or not profile:
            raise HTTPException(status_code=404, detail="User profile not found")

        # Enforce user_id match
        if profile.get("user_id") != user_id:
            raise HTTPException(status_code=403, detail="User ID does not match this email")

        # Enforce role match (profile vs request)
        profile_role = str(profile.get("role", "")).lower()
        requested_role = body.role  # 'admin'|'staff'|'tenant'
        if profile_role != requested_role:
            raise HTTPException(status_code=403, detail="Role mismatch")

        # Role-specific checks
        if requested_role == "staff":
            # staffDepartment must match profile.department or classification
            dept_req = (body.staffDepartment or "").strip().lower()
            dept_profile = str(profile.get("department", "")).strip().lower()
            class_profile = str(profile.get("classification", "")).strip().lower()
            if dept_req not in (dept_profile, class_profile):
                raise HTTPException(status_code=403, detail="Department mismatch")
        elif requested_role == "tenant":
            # buildingUnitId must match profile.building_unit (normalized)
            want = _normalize_building_unit(body.buildingUnitId)
            have = _normalize_building_unit(profile.get("building_unit"))
            if not want or not have or want != have:
                raise HTTPException(status_code=403, detail="Building/Unit mismatch")

        # 2) Verify password with Firebase REST API (returns ID token)
        token_data = await _sign_in_with_password(email, body.password)
        id_token = token_data.get("idToken")
        refresh_token = token_data.get("refreshToken")
        expires_in = token_data.get("expiresIn", "3600")

        # 3) Return token + profile summary
        result: Dict[str, Any] = {
#>>>>>>> back-end
            "id_token": id_token,
            "token_type": "Bearer",
            "refresh_token": refresh_token,
            "expires_in": expires_in,
            "uid": user.uid,
            "user_id": profile.get("user_id"),
            "email": email,
            "role": profile_role,
            "status": profile.get("status", "active"),
        }

        if requested_role == "staff":
            result.update({
                "department": profile.get("department"),
                "classification": profile.get("classification"),
                "staff_id": profile.get("staff_id"),
            })
        elif requested_role == "tenant":
            result.update({
                "building_unit": profile.get("building_unit"),
                "building_id": profile.get("building_id"),
                "unit_id": profile.get("unit_id"),
            })

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Login failed (role-based)")
        raise HTTPException(status_code=400, detail=f"Login failed: {str(e)}")


# ------------------------------------------------------------------------------
# IDENTITY / SELF-SERVICE (unchanged)
# ------------------------------------------------------------------------------

@router.get("/me")
async def get_current_user_info(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Return current user identity and profile info."""
    try:
        prof_ok, profile, _ = await _get_profile_by_uid(current_user.get("uid"))

        info: Dict[str, Any] = {
            "uid": current_user.get("uid"),
            "user_id": current_user.get("user_id"),
            "email": current_user.get("email"),
            "role": current_user.get("role"),
            "building_id": current_user.get("building_id"),
            "unit_id": current_user.get("unit_id"),
            "department": current_user.get("department"),
        }

        if prof_ok and profile:
            info.update({
                "first_name": profile.get("first_name"),
                "last_name": profile.get("last_name"),
                "phone_number": profile.get("phone_number"),
                "status": profile.get("status"),
                "staff_id": profile.get("staff_id"),
                "classification": profile.get("classification"),
                "building_unit": profile.get("building_unit"),
                "created_at": profile.get("created_at"),
                "updated_at": profile.get("updated_at"),
            })

        return info

    except Exception:
        logger.exception("/auth/me failed")
        return {
            "uid": current_user.get("uid"),
            "user_id": current_user.get("user_id"),
            "email": current_user.get("email"),
            "role": current_user.get("role"),
            "error": "Could not load complete profile",
        }


@router.patch("/change-password")
async def change_own_password(
    new_password: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
) -> Dict[str, Any]:
    """Allow users to change their own password."""
    try:
        if not new_password:
            raise HTTPException(status_code=400, detail="New password is required")
        await firebase_auth.update_user(current_user.get("uid"), password=new_password)
        return {"message": "Password changed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Failed to change password for uid=%s", current_user.get("uid"))
        raise HTTPException(status_code=400, detail=f"Failed to change password: {str(e)}")


@router.patch("/profile")
async def update_own_profile(
    first_name: Optional[str] = None,
    last_name: Optional[str] = None,
    phone_number: Optional[str] = None,
    current_user: Dict[str, Any] = Depends(get_current_user),
) -> Dict[str, Any]:
    """Allow users to update their own profile (Firestore doc)."""
    try:
        update: Dict[str, Any] = {}
        if first_name is not None:
            update["first_name"] = first_name
        if last_name is not None:
            update["last_name"] = last_name
        if phone_number is not None:
            update["phone_number"] = phone_number
        if update:
            update["updated_at"] = datetime.utcnow()
            ok, err = await database_service.update_document(COLLECTIONS["users"], current_user.get("uid"), update)
            if not ok:
                raise HTTPException(status_code=400, detail=f"Failed to update profile: {err}")
        return {"message": "Profile updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Profile update failed for uid=%s", current_user.get("uid"))
        raise HTTPException(status_code=500, detail=f"Error updating profile: {str(e)}")


@router.post("/logout")
async def logout_user(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Logout current user by revoking refresh tokens."""
    try:
        await firebase_auth.revoke_refresh_tokens(current_user.get("uid"))
        return {"message": "Logged out successfully"}
    except Exception as e:
        logger.exception("Logout failed for uid=%s", current_user.get("uid"))
        raise HTTPException(status_code=400, detail=f"Logout failed: {str(e)}")


@router.post("/logout-all-devices")
async def logout_all_devices(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Logout user from all devices by revoking all tokens & bumping claims."""
    try:
        await firebase_auth.revoke_refresh_tokens(current_user.get("uid"))
        claims = {**(current_user or {}), "tokens_valid_after": datetime.utcnow().timestamp()}
        await firebase_auth.set_custom_claims(current_user.get("uid"), claims)
        return {"message": "Logged out from all devices successfully"}
    except Exception as e:
        logger.exception("Logout-all-devices failed for uid=%s", current_user.get("uid"))
        raise HTTPException(status_code=400, detail=f"Logout from all devices failed: {str(e)}")
