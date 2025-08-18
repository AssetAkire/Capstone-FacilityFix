import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Auto-expand sections if current route is a child
    _autoExpandForCurrentRoute();
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
    if (widget.onNavigate != null) {
      widget.onNavigate!(routeKey);
    } else {
      print('Navigate to $routeKey');
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
                
                // Logo section with company branding (retained original design)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset('lib/adminweb/assets/images/logo.png', height: 40),
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
                        key: 'user',
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
                        key: 'work',
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
                        key: 'inventory',
                        children: [
                          _subNavItem('View Inventory', 'inventory_view'),
                          _subNavItem('Add Inventory', 'inventory_add'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Analytics navigation item
                      _navItem(Icons.analytics_outlined, 'Analytics', 'analytics'),
                      const SizedBox(height: 4),
                      
                      // Notice navigation item
                      _navItem(Icons.campaign_outlined, 'Notice', 'notice'),
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
                      _navItem(Icons.logout, 'Logout', 'logout', isLogout: true),
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
                // Top header section with search bar and user actions (retained original profile design)
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
                            hintStyle: const TextStyle(color: Color(0xFF64748B)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      // Header action buttons (retained original design)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.dashboard_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.grey),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                // Main content area with background
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: widget.body,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ====== NAVIGATION ITEM BUILDERS ======

  /// Builds a regular navigation item with hover effects and active state highlighting
  Widget _navItem(IconData icon, String title, String routeKey, {bool isLogout = false}) {
    final isSelected = widget.currentRoute == routeKey;
    final isHovered = _hovered[routeKey] ?? false;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered[routeKey] = true),
      onExit: (_) => setState(() => _hovered[routeKey] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFDBEAFE) 
              : isHovered 
                  ? const Color(0xFFF1F5F9)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border(
                  left: BorderSide(
                    color: Colors.blue.shade600,
                    width: 3,
                  ),
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
                    color: isSelected 
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected 
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
    required String key,
    required List<Widget> children,
  }) {
    // Check if any child is currently selected
    final hasSelectedChild = children.any((w) {
      final valueKey = w.key as ValueKey?;
      return valueKey?.value == widget.currentRoute;
    });
    
    final isExpanded = _expanded[key] == true;
    final isHovered = _hovered[key] ?? false;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered[key] = true),
      onExit: (_) => setState(() => _hovered[key] = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent dropdown header
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: hasSelectedChild 
                  ? const Color(0xFFDBEAFE) 
                  : isHovered 
                      ? const Color(0xFFF1F5F9)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: hasSelectedChild 
                  ? Border(
                      left: BorderSide(
                        color: Colors.blue.shade600,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expanded[key] = !isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        icon, 
                        size: 20,
                        color: hasSelectedChild 
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
                            fontWeight: hasSelectedChild ? FontWeight.w600 : FontWeight.w500,
                            color: hasSelectedChild 
                                ? Colors.blue.shade700
                                : isHovered 
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      // Animated expand/collapse arrow
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: hasSelectedChild 
                              ? Colors.blue.shade600
                              : isHovered 
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Expandable children container
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 48, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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
      onEnter: (_) => setState(() => _hovered[routeKey] = true),
      onExit: (_) => setState(() => _hovered[routeKey] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected 
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