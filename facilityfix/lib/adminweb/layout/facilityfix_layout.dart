import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../popupwidgets/webnotification_popup.dart';
import '../services/api_service.dart';

class FacilityFixLayout extends StatefulWidget {
  final Widget body;
  final String currentRoute;
  final Function(String)? onNavigate; // Add navigation callback

  const FacilityFixLayout({
    super.key,
    required this.body,
    required this.currentRoute,
    this.onNavigate,
  });

  @override
  State<FacilityFixLayout> createState() => _FacilityFixLayoutState();
}

class _FacilityFixLayoutState extends State<FacilityFixLayout> {
  // Dropdown expansion state management
  Map<String, bool> _expanded = {
    'user': false,
    'work': false,
    'inventory': false,
  };

  // Track hover states for navigation items
  Map<String, bool> _hovered = {};

  // Debug logging toggle for highlight component
  final bool _enableHighlightLogs = true;

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoadingNotifications = false;

  void _logHighlight(String message) {
    if (!_enableHighlightLogs) return;
    debugPrint('[Highlight] $message');
  }

  @override
  void initState() {
    super.initState();
    // Auto-expand sections if current route is a child
    _autoExpandForCurrentRoute();
    _logHighlight(
      'initState -> currentRoute=${widget.currentRoute}, expanded=$_expanded',
    );
    _initializeAuth();
  }

  // Automatically expand parent dropdown if child route is active
  void _autoExpandForCurrentRoute() {
    if (widget.currentRoute.startsWith('user_')) {
      _expanded['user'] = true;
    } else if (widget.currentRoute.startsWith('work_')) {
      _expanded['work'] = true;
    } else if (widget.currentRoute.startsWith('inventory_')) {
      _expanded['inventory'] = true;
    }
  }

  // Handle navigation when item is clicked
  void _handleNavigation(String routeKey) {
    _logHighlight('Navigate -> $routeKey');
    if (widget.onNavigate != null) {
      widget.onNavigate!(routeKey);
    } else {
      print('Navigate to $routeKey');
    }
  }

  Future<void> _initializeAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          ApiService().setAuthToken(token);
          await _fetchNotifications();
        }
      }
    } catch (e) {
      print('[v0] Error initializing auth: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    if (_isLoadingNotifications) return;

    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final response = await ApiService().getNotifications();

      // Extract the notifications list from the response
      final notificationsList = response['notifications'] as List? ?? [];

      // Transform backend data to match popup format
      final transformedNotifications =
          notificationsList.map((notif) {
            return {
              'id': notif['id'],
              'type': notif['notification_type'] ?? 'system',
              'title': notif['title'] ?? 'Notification',
              'message': notif['message'] ?? '',
              'timestamp':
                  notif['created_at'] ?? DateTime.now().toIso8601String(),
              'isRead': notif['is_read'] ?? false,
              'relatedId': notif['related_id'],
            };
          }).toList();

      setState(() {
        _notifications = transformedNotifications;
        _unreadCount =
            transformedNotifications.where((n) => n['isRead'] == false).length;
        _isLoadingNotifications = false;
      });

      print(
        '[v0] Loaded ${_notifications.length} notifications, $_unreadCount unread',
      );
    } catch (e) {
      print('[v0] Error fetching notifications: $e');
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FacilityFixLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      _logHighlight(
        'Route changed: ${oldWidget.currentRoute} -> ${widget.currentRoute}',
      );
      if (widget.currentRoute.startsWith('user_')) {
        _logHighlight('Active section: user');
      } else if (widget.currentRoute.startsWith('work_')) {
        _logHighlight('Active section: work');
      } else if (widget.currentRoute.startsWith('inventory_')) {
        _logHighlight('Active section: inventory');
      } else {
        _logHighlight('Active top-level item: ${widget.currentRoute}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ====== LEFT SIDEBAR NAVIGATION ======
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Logo section with company branding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        'lib/adminweb/assets/images/logo.png',
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FacilityFix',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main navigation section label
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'MAIN',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Main navigation menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      // Dashboard navigation item
                      _navItem(Icons.home_outlined, 'Dashboard', 'dashboard'),
                      const SizedBox(height: 4),

                      // User and Role Management dropdown
                      _dropdownNav(
                        icon: Icons.group,
                        title: 'User and Role Management',
                        sectionKey: 'user',
                        children: [
                          _subNavItem('Users', 'user_users'),
                          _subNavItem('Roles Management', 'user_roles'),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Work Orders dropdown
                      _dropdownNav(
                        icon: Icons.build_outlined,
                        title: 'Work Orders',
                        sectionKey: 'work',
                        children: [
                          _subNavItem('Maintenance Tasks', 'work_maintenance'),
                          _subNavItem('Repair Tasks', 'work_repair'),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Calendar navigation item
                      _navItem(Icons.calendar_today, 'Calendar', 'calendar'),
                      const SizedBox(height: 4),

                      // Inventory Management dropdown
                      _dropdownNav(
                        icon: Icons.inventory_2_outlined,
                        title: 'Inventory Management',
                        sectionKey: 'inventory',
                        children: [
                          _subNavItem('Inventory Items', 'inventory_items'),
                          _subNavItem('Inventory Request', 'inventory_request'),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Analytics navigation item
                      _navItem(
                        Icons.analytics_outlined,
                        'Analytics',
                        'analytics',
                      ),
                      const SizedBox(height: 4),

                      // Announcement navigation item - Fixed: changed from 'announcement' to 'announcements'
                      _navItem(
                        Icons.campaign_outlined,
                        'Announcement',
                        'announcement',
                      ),
                    ],
                  ),
                ),

                // Bottom navigation items (Settings & Logout)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),
                      _navItem(Icons.settings, 'Settings', 'settings'),
                      const SizedBox(height: 4),
                      _navItem(
                        Icons.logout,
                        'Logout',
                        'logout',
                        isLogout: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====== MAIN CONTENT AREA ======
          Expanded(
            child: Column(
              children: [
                // Top header section with search bar and user actions
                Container(
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Enhanced modern search bar
                      SizedBox(
                        width: 350,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search anything...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF64748B),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      // Header action buttons
                      Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () async {
                                  NotificationDialog.show(
                                    context,
                                    _notifications,
                                    onRefresh: _fetchNotifications,
                                  );
                                },
                              ),
                              if (_unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      _unreadCount > 99
                                          ? '99+'
                                          : '$_unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.grey),
                            onPressed: () {
                              context.go('/profile');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main content area with background
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: widget.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====== NAVIGATION ITEM BUILDERS ======

  /// Builds a regular navigation item with hover effects and active state highlighting
  Widget _navItem(
    IconData icon,
    String title,
    String routeKey, {
    bool isLogout = false,
  }) {
    final isSelected = widget.currentRoute == routeKey;
    final isHovered = _hovered[routeKey] ?? false;

    return MouseRegion(
      onEnter: (_) {
        _logHighlight('Hover ON -> $routeKey');
        setState(() => _hovered[routeKey] = true);
      },
      onExit: (_) {
        _logHighlight('Hover OFF -> $routeKey');
        setState(() => _hovered[routeKey] = false);
      },
      // Animation
      child: Container(
        // duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFDBEAFE)
                  : isHovered
                  ? const Color(0xFFF1F5F9)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border(
                    left: BorderSide(color: Colors.blue.shade600, width: 3),
                  )
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNavigation(routeKey),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color:
                        isSelected
                            ? Colors.blue.shade600
                            : isLogout
                            ? Colors.red.shade600
                            : isHovered
                            ? const Color(0xFF475569)
                            : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.blue.shade700
                                : isLogout
                                ? Colors.red.shade600
                                : isHovered
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a dropdown navigation item with expandable children
  Widget _dropdownNav({
    required IconData icon,
    required String title,
    required String sectionKey,
    required List<Widget> children,
  }) {
    // Check if any child is currently selected
    final hasSelectedChild = children.any((w) {
      final valueKey = w.key as ValueKey?;
      return valueKey?.value == widget.currentRoute;
    });

    final isExpanded = _expanded[sectionKey] == true;
    final isHovered = _hovered[sectionKey] ?? false;

    return MouseRegion(
      onEnter: (_) {
        _logHighlight('Hover ON -> section:$sectionKey');
        setState(() => _hovered[sectionKey] = true);
      },
      onExit: (_) {
        _logHighlight('Hover OFF -> section:$sectionKey');
        setState(() => _hovered[sectionKey] = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent dropdown header
          // Animation
          Container(
            // duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color:
                  hasSelectedChild
                      ? const Color(0xFFDBEAFE)
                      : isHovered
                      ? const Color(0xFFF1F5F9)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border:
                  hasSelectedChild
                      ? Border(
                        left: BorderSide(color: Colors.blue.shade600, width: 3),
                      )
                      : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final next = !isExpanded;
                  _logHighlight(
                    'Toggle expand -> section:$sectionKey -> $next',
                  );
                  setState(() {
                    _expanded[sectionKey] = next;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color:
                            hasSelectedChild
                                ? Colors.blue.shade600
                                : isHovered
                                ? const Color(0xFF475569)
                                : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                hasSelectedChild
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                            color:
                                hasSelectedChild
                                    ? Colors.blue.shade700
                                    : isHovered
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      // Animated expand/collapse arrow
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        // turns: isExpanded ? 0.5 : 0,
                        // duration: const Duration(milliseconds: 200),
                        // child: Icon(
                        //   Icons.expand_more,
                        size: 20,
                        color:
                            hasSelectedChild
                                ? Colors.blue.shade600
                                : isHovered
                                ? const Color(0xFF475569)
                                : const Color(0xFF64748B),
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Expandable children container
          isExpanded
              ? Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              )
              : const SizedBox.shrink(),
          // AnimatedSize(
          //   duration: const Duration(milliseconds: 300),
          //   curve: Curves.easeInOut,
          //   child: isExpanded
          //       ? Padding(
          //           padding: const EdgeInsets.only(left: 48, top: 4),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: children,
          //           ),
          //         )
          //       : const SizedBox.shrink(),
          // ),
        ],
      ),
    );
  }

  /// Builds a sub-navigation item for dropdown children
  Widget _subNavItem(String title, String routeKey) {
    final isSelected = widget.currentRoute == routeKey;
    final isHovered = _hovered[routeKey] ?? false;

    return MouseRegion(
      key: ValueKey(routeKey),
      onEnter: (_) {
        _logHighlight('Hover ON -> sub:$routeKey');
        setState(() => _hovered[routeKey] = true);
      },
      onExit: (_) {
        _logHighlight('Hover OFF -> sub:$routeKey');
        setState(() => _hovered[routeKey] = false);
      },
      // Animation commented out - using regular Container instead
      child: Container(
        // duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.blue.shade50
                  : isHovered
                  ? const Color(0xFFF8FAFC)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNavigation(routeKey),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
