from typing import List, Optional, Dict, Any
from datetime import datetime
import logging
import uuid

from ..models.database_models import Announcement
from ..database.database_service import database_service
from ..database.collections import COLLECTIONS
from .notification_service import notification_service
from .email_service import email_service
from .websocket_service import websocket_notification_service

logger = logging.getLogger(__name__)

class AnnouncementService:
    """Service for managing announcements and broadcasting them via multiple channels"""
    
    def __init__(self):
        self.db = database_service
        self.notification_service = notification_service
    
    async def create_announcement(
        self,
        created_by: str,
        building_id: str,
        title: str,
        content: str,
        announcement_type: str = "general",
        audience: str = "all",
        location_affected: Optional[str] = None,
        send_notifications: bool = True,
        send_email: bool = False
    ) -> tuple[bool, Optional[str], Optional[str]]:
        """
        Create new announcement and broadcast it via multiple channels
        
        Args:
            created_by: Admin user ID creating the announcement
            building_id: Building where announcement applies
            title: Short headline for the announcement
            content: Full announcement message
            announcement_type: Type of announcement (maintenance, reminder, event, policy, general)
            audience: Target audience (tenants, staff, all)
            location_affected: Specific location/area affected
            send_notifications: Whether to send push/websocket notifications
            send_email: Whether to send email notifications
            
        Returns:
            (success, announcement_id, error_message)
        """
        try:
            # Generate unique announcement ID
            announcement_id = str(uuid.uuid4())
            
            # Create announcement data
            announcement_data = {
                "id": announcement_id,
                "created_by": created_by,
                "building_id": building_id,
                "title": title,
                "content": content,
                "type": announcement_type,
                "audience": audience,
                "location_affected": location_affected,
                "is_active": True,
                "date_added": datetime.now(),
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            }
            
            # Save to database
            success, doc_id, error = await self.db.create_document(
                COLLECTIONS['announcements'],
                announcement_data
            )
            
            if not success:
                return False, None, f"Failed to create announcement: {error}"
            
            logger.info(f"Announcement created: {announcement_id} by {created_by}")
            
            # Broadcast announcement via notification channels
            if send_notifications or send_email:
                await self._broadcast_announcement(
                    announcement_data, 
                    send_notifications=send_notifications,
                    send_email=send_email
                )
            
            return True, announcement_id, None
            
        except Exception as e:
            logger.error(f"Error creating announcement: {str(e)}")
            return False, None, str(e)
    
    async def get_announcements(
        self,
        building_id: str,
        audience: str = "all",
        active_only: bool = True,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """
        Get announcements for a specific building and audience
        
        Args:
            building_id: Building ID to filter by
            audience: Target audience (tenants, staff, all)
            active_only: Whether to return only active announcements
            limit: Maximum number of announcements to return
            
        Returns:
            List of announcement dictionaries
        """
        try:
            # Build filters
            filters = [('building_id', '==', building_id)]
            
            # Filter by audience
            if audience != "all":
                # Include announcements for specific audience OR "all"
                filters.append(('audience', 'in', [audience, 'all']))
            
            # Filter by active status
            if active_only:
                filters.append(('is_active', '==', True))
            
            # Query announcements
            success, announcements, error = await self.db.query_documents(
                COLLECTIONS['announcements'],
                filters,
                order_by=[('date_added', 'desc')],
                limit=limit
            )
            
            if success:
                return announcements
            else:
                logger.error(f"Failed to get announcements: {error}")
                return []
                
        except Exception as e:
            logger.error(f"Error getting announcements: {str(e)}")
            return []
    
    async def get_announcement_by_id(self, announcement_id: str) -> Optional[Dict[str, Any]]:
        """Get specific announcement by ID"""
        try:
            success, announcement, error = await self.db.get_document(
                COLLECTIONS['announcements'],
                announcement_id
            )
            
            if success:
                return announcement
            else:
                logger.error(f"Failed to get announcement {announcement_id}: {error}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting announcement {announcement_id}: {str(e)}")
            return None
    
    async def update_announcement(
        self,
        announcement_id: str,
        updated_by: str,
        updates: Dict[str, Any],
        notify_changes: bool = False
    ) -> tuple[bool, Optional[str]]:
        """
        Update existing announcement
        
        Args:
            announcement_id: ID of announcement to update
            updated_by: User ID making the update
            updates: Dictionary of fields to update
            notify_changes: Whether to send notifications about the update
            
        Returns:
            (success, error_message)
        """
        try:
            # Get existing announcement
            existing = await self.get_announcement_by_id(announcement_id)
            if not existing:
                return False, "Announcement not found"
            
            # Add update metadata
            updates['updated_at'] = datetime.now()
            
            # Update in database
            success, error = await self.db.update_document(
                COLLECTIONS['announcements'],
                announcement_id,
                updates
            )
            
            if not success:
                return False, f"Failed to update announcement: {error}"
            
            logger.info(f"Announcement {announcement_id} updated by {updated_by}")
            
            # Send update notifications if requested
            if notify_changes and existing.get('is_active', True):
                updated_announcement = {**existing, **updates}
                await self._broadcast_announcement_update(updated_announcement)
            
            return True, None
            
        except Exception as e:
            logger.error(f"Error updating announcement {announcement_id}: {str(e)}")
            return False, str(e)
    
    async def deactivate_announcement(
        self,
        announcement_id: str,
        deactivated_by: str,
        notify_deactivation: bool = False
    ) -> tuple[bool, Optional[str]]:
        """
        Deactivate an announcement (soft delete)
        
        Args:
            announcement_id: ID of announcement to deactivate
            deactivated_by: User ID performing the deactivation
            notify_deactivation: Whether to notify about deactivation
            
        Returns:
            (success, error_message)
        """
        try:
            updates = {
                'is_active': False,
                'updated_at': datetime.now()
            }
            
            success, error = await self.update_announcement(
                announcement_id,
                deactivated_by,
                updates,
                notify_changes=notify_deactivation
            )
            
            if success:
                logger.info(f"Announcement {announcement_id} deactivated by {deactivated_by}")
            
            return success, error
            
        except Exception as e:
            logger.error(f"Error deactivating announcement {announcement_id}: {str(e)}")
            return False, str(e)
    
    async def _broadcast_announcement(
        self,
        announcement_data: Dict[str, Any],
        send_notifications: bool = True,
        send_email: bool = False
    ):
        """
        Broadcast announcement via multiple notification channels
        
        Args:
            announcement_data: Announcement data dictionary
            send_notifications: Send push and websocket notifications
            send_email: Send email notifications
        """
        try:
            building_id = announcement_data['building_id']
            audience = announcement_data['audience']
            title = announcement_data['title']
            content = announcement_data['content']
            announcement_type = announcement_data['type']
            
            # Get target users based on audience
            target_users = await self._get_target_users(building_id, audience)
            
            if not target_users:
                logger.warning(f"No target users found for announcement in building {building_id}")
                return
            
            # Send WebSocket real-time updates
            if send_notifications:
                await self._send_websocket_announcement(announcement_data)
            
            # Send push notifications and in-app notifications
            if send_notifications:
                await self._send_push_notifications(announcement_data, target_users)
            
            # Send email notifications
            if send_email:
                await self._send_email_announcements(announcement_data, target_users)
            
            logger.info(f"Announcement broadcast completed for {len(target_users)} users")
            
        except Exception as e:
            logger.error(f"Error broadcasting announcement: {str(e)}")
    
    async def _get_target_users(self, building_id: str, audience: str) -> List[Dict[str, Any]]:
        """Get target users based on building and audience criteria"""
        try:
            filters = [
                ('building_id', '==', building_id),
                ('status', '==', 'active')
            ]
            
            # Filter by audience role
            if audience == 'tenants':
                filters.append(('role', '==', 'tenant'))
            elif audience == 'staff':
                filters.append(('role', '==', 'staff'))
            elif audience == 'admins':
                filters.append(('role', '==', 'admin'))
            # 'all' doesn't add role filter
            
            success, users, error = await self.db.query_documents(
                COLLECTIONS['user_profiles'],
                filters
            )
            
            if success:
                return users
            else:
                logger.error(f"Failed to get target users: {error}")
                return []
                
        except Exception as e:
            logger.error(f"Error getting target users: {str(e)}")
            return []
    
    async def _send_websocket_announcement(self, announcement_data: Dict[str, Any]):
        """Send announcement via WebSocket for real-time updates"""
        try:
            await websocket_notification_service.send_announcement(announcement_data)
            logger.info(f"WebSocket announcement sent: {announcement_data['id']}")
        except Exception as e:
            logger.error(f"Error sending WebSocket announcement: {str(e)}")
    
    async def _send_push_notifications(
        self,
        announcement_data: Dict[str, Any],
        target_users: List[Dict[str, Any]]
    ):
        """Send push notifications and create in-app notifications for users"""
        try:
            title = announcement_data['title']
            content = announcement_data['content']
            announcement_type = announcement_data['type']
            announcement_id = announcement_data['id']
            
            # Create notifications for each target user
            for user in target_users:
                user_id = user.get('id') or user.get('user_id')
                if user_id:
                    # Create comprehensive notification (push + in-app + websocket)
                    await notification_service.create_notification(
                        user_id=user_id,
                        title=title,
                        message=content,
                        notification_type=f"announcement_{announcement_type}",
                        related_id=announcement_id,
                        send_push=True,
                        send_email=False,  # Email handled separately
                        send_websocket=False  # Already sent via broadcast
                    )
            
            logger.info(f"Push notifications sent for announcement {announcement_id}")
            
        except Exception as e:
            logger.error(f"Error sending push notifications: {str(e)}")
    
    async def _send_email_announcements(
        self,
        announcement_data: Dict[str, Any],
        target_users: List[Dict[str, Any]]
    ):
        """Send email announcements to target users"""
        try:
            # Prepare recipients list
            recipients = []
            for user in target_users:
                email = user.get('email')
                name = f"{user.get('first_name', '')} {user.get('last_name', '')}".strip()
                if email and name:
                    recipients.append({"email": email, "name": name})
            
            if not recipients:
                logger.warning("No email recipients found for announcement")
                return
            
            # Send bulk email announcement
            result = await email_service.send_announcement_email(
                announcement_data,
                recipients
            )
            
            logger.info(f"Email announcements sent: {result}")
            
        except Exception as e:
            logger.error(f"Error sending email announcements: {str(e)}")
    
    async def _broadcast_announcement_update(self, announcement_data: Dict[str, Any]):
        """Broadcast announcement updates via WebSocket"""
        try:
            update_message = {
                "type": "announcement_updated",
                "data": announcement_data,
                "timestamp": datetime.now().isoformat()
            }
            
            building_id = announcement_data['building_id']
            audience = announcement_data['audience']
            
            if audience == 'all':
                await websocket_notification_service.manager.broadcast_to_building(
                    building_id, update_message
                )
            else:
                await websocket_notification_service.manager.broadcast_to_role(
                    audience, update_message, building_id
                )
            
            logger.info(f"Announcement update broadcast sent: {announcement_data['id']}")
            
        except Exception as e:
            logger.error(f"Error broadcasting announcement update: {str(e)}")
    
    async def get_announcement_statistics(self, building_id: str) -> Dict[str, Any]:
        """Get statistics about announcements for a building"""
        try:
            # Get all announcements for building
            all_announcements = await self.get_announcements(
                building_id, 
                audience="all", 
                active_only=False, 
                limit=1000
            )
            
            # Calculate statistics
            total_announcements = len(all_announcements)
            active_announcements = len([a for a in all_announcements if a.get('is_active', True)])
            
            # Group by type
            type_breakdown = {}
            for announcement in all_announcements:
                ann_type = announcement.get('type', 'general')
                type_breakdown[ann_type] = type_breakdown.get(ann_type, 0) + 1
            
            # Group by audience
            audience_breakdown = {}
            for announcement in all_announcements:
                audience = announcement.get('audience', 'all')
                audience_breakdown[audience] = audience_breakdown.get(audience, 0) + 1
            
            return {
                "total_announcements": total_announcements,
                "active_announcements": active_announcements,
                "inactive_announcements": total_announcements - active_announcements,
                "type_breakdown": type_breakdown,
                "audience_breakdown": audience_breakdown,
                "building_id": building_id,
                "generated_at": datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting announcement statistics: {str(e)}")
            return {
                "error": str(e),
                "building_id": building_id,
                "generated_at": datetime.now().isoformat()
            }

# Create global service instance
announcement_service = AnnouncementService()
