import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationDialog extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback? onRefresh; // Added refresh callback

  const NotificationDialog({
    super.key,
    required this.notifications,
    this.onRefresh, // Added refresh callback
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();

  // Static method to show the notification dialog
  static void show(
    BuildContext context,
    List<Map<String, dynamic>> notifications, {
    VoidCallback? onRefresh, // Added refresh callback
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return NotificationDialog(
          notifications: notifications,
          onRefresh: onRefresh, // Pass refresh callback
        );
      },
    );
  }
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: Alignment.topRight, // Position at top-right
      insetPadding: const EdgeInsets.only(top: 60, right: 20, left: 20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(context),

            // Notifications List
            Flexible(
              child:
                  widget.notifications.isEmpty
                      ? _buildEmptyState()
                      : _buildNotificationsList(),
            ),

            // Footer Section (optional settings or clear all)
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Settings button (optional)
          IconButton(
            onPressed: () => _openNotificationSettings(),
            icon: Icon(Icons.settings, color: Colors.grey[600], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Notifications list builder
  Widget _buildNotificationsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children:
            widget.notifications.map((notification) {
              return _buildNotificationItem(notification);
            }).toList(),
      ),
    );
  }

  // Individual notification item
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            notification['isRead'] == false
                ? Colors.blue[50]
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon/avatar
              _buildNotificationIcon(notification['type']),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and timestamp row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  notification['isRead'] == false
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimestamp(notification['timestamp']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Notification message
                    Text(
                      notification['message'] ?? 'No message',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons (dismiss, more options)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 16),
                padding: EdgeInsets.zero,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Text(
                          notification['isRead'] == false
                              ? 'Mark as read'
                              : 'Mark as unread',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'dismiss',
                        child: Text('Dismiss'),
                      ),
                    ],
                onSelected:
                    (value) => _handleNotificationAction(notification, value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Notification type icon builder
  Widget _buildNotificationIcon(String? type) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (type?.toLowerCase()) {
      case 'maintenance':
        bgColor = Colors.orange[100]!;
        iconColor = Colors.orange[700]!;
        icon = Icons.build;
        break;
      case 'repair':
        bgColor = Colors.red[100]!;
        iconColor = Colors.red[700]!;
        icon = Icons.handyman;
        break;
      case 'inspection':
        bgColor = Colors.blue[100]!;
        iconColor = Colors.blue[700]!;
        icon = Icons.checklist;
        break;
      case 'announcement':
        bgColor = Colors.green[100]!;
        iconColor = Colors.green[700]!;
        icon = Icons.campaign;
        break;
      case 'system':
        bgColor = Colors.purple[100]!;
        iconColor = Colors.purple[700]!;
        icon = Icons.settings;
        break;
      default:
        bgColor = Colors.grey[100]!;
        iconColor = Colors.grey[700]!;
        icon = Icons.notifications;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  // Empty state when no notifications
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: Colors.grey[400], size: 48),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Footer section with actions
  Widget _buildFooter(BuildContext context) {
    if (widget.notifications.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _clearAllNotifications,
            child: Text(
              'Clear all',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  // Format timestamp for display
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  // Handle notification tap - navigate to relevant screen or show details
  void _handleNotificationTap(Map<String, dynamic> notification) {
    Navigator.of(context).pop();

    // Mark as read when tapped
    _markNotificationAsRead(notification['id']);

    // TODO: Navigate to relevant screen based on notification type
    switch (notification['type']?.toLowerCase()) {
      case 'maintenance':
        // Navigate to maintenance details
        print('Navigate to maintenance: ${notification['relatedId']}');
        break;
      case 'repair':
        // Navigate to repair request details
        print('Navigate to repair: ${notification['relatedId']}');
        break;
      case 'announcement':
        // Show announcement details
        print('Show announcement: ${notification['relatedId']}');
        break;
      default:
        // Default action
        print('Notification tapped: ${notification['id']}');
    }
  }

  // Handle notification context menu actions
  void _handleNotificationAction(
    Map<String, dynamic> notification,
    String action,
  ) {
    switch (action) {
      case 'mark_read':
        _toggleNotificationReadStatus(notification);
        break;
      case 'dismiss':
        _dismissNotification(notification['id']);
        break;
    }
  }

  // Open notification settings
  void _openNotificationSettings() {
    Navigator.of(context).pop();
    // TODO: Navigate to notification settings page
    print('Open notification settings');
  }

  // Mark all notifications as read
  void _markAllAsRead() async {
    final unreadIds =
        widget.notifications
            .where((n) => n['isRead'] == false)
            .map((n) => n['id'] as String)
            .toList();

    if (unreadIds.isEmpty) return;

    try {
      await ApiService().markNotificationsAsRead(unreadIds);

      setState(() {
        for (var notification in widget.notifications) {
          notification['isRead'] = true;
        }
      });

      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[v0] Error marking all as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark notifications as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Clear all notifications
  void _clearAllNotifications() async {
    if (widget.notifications.isEmpty) return;

    try {
      // Delete all notifications via API
      for (var notification in widget.notifications) {
        await ApiService().deleteNotification(notification['id']);
      }

      setState(() {
        widget.notifications.clear();
      });

      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      print('[v0] Error clearing notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Toggle notification read status
  void _toggleNotificationReadStatus(Map<String, dynamic> notification) async {
    final newReadStatus = !(notification['isRead'] ?? false);

    try {
      if (newReadStatus) {
        await ApiService().markNotificationsAsRead([notification['id']]);
      }

      setState(() {
        notification['isRead'] = newReadStatus;
      });

      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      print('[v0] Error toggling notification read status: $e');
    }
  }

  // Mark single notification as read
  void _markNotificationAsRead(String id) async {
    try {
      await ApiService().markNotificationsAsRead([id]);

      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      print('[v0] Error marking notification as read: $e');
    }
  }

  // Dismiss notification
  void _dismissNotification(String id) async {
    try {
      await ApiService().deleteNotification(id);

      setState(() {
        widget.notifications.removeWhere((notif) => notif['id'] == id);
      });

      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      print('[v0] Error deleting notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
