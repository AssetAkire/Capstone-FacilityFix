import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../layout/facilityfix_layout.dart';
import '../popupwidgets/announcement_viewdetails_popup.dart';
import '../services/api_service.dart';

class AdminWebAnnouncementPage extends StatefulWidget {
  const AdminWebAnnouncementPage({super.key});

  @override
  State<AdminWebAnnouncementPage> createState() =>
      _AdminWebAnnouncementPageState();
}

class _AdminWebAnnouncementPageState extends State<AdminWebAnnouncementPage> {
  // Route mapping helper function
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_items': '/inventory/items',
      'inventory_request': '/inventory/request',
      'analytics': '/analytics',
      'announcement': '/announcement',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

  // Logout functionality
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _announcementItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  // Search and filter controllers for backend integration
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Utility Interruption',
    'Maintenance',
    'Emergency',
    'Announcement',
  ];

  // Column widths for table
  final List<double> _colW = <double>[
    140, // ID
    270, // TITLE
    180, // TYPE
    200, // LOCATION
    110, // DATE ADDED
    48, // ACTION
  ];

  // Fixed width cell helper
  Widget _fixedCell(
    int i,
    Widget child, {
    Alignment align = Alignment.centerLeft,
  }) {
    return SizedBox(
      width: _colW[i],
      child: Align(alignment: align, child: child),
    );
  }

  // Text with ellipsis helper
  Text _ellipsis(String s, {TextStyle? style}) => Text(
    s,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
    style: style,
  );

  // Action dropdown menu methods
  void _showActionMenu(
    BuildContext context,
    Map<String, dynamic> announcement,
    Offset position,
  ) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: Colors.green[600],
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'View',
                style: TextStyle(color: Colors.green[600], fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue[600], size: 18),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(color: Colors.blue[600], fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600], size: 18),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(color: Colors.red[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
    ).then((value) {
      if (value != null) {
        _handleActionSelection(value, announcement);
      }
    });
  }

  // Handle action selection
  void _handleActionSelection(
    String action,
    Map<String, dynamic> announcement,
  ) {
    switch (action) {
      case 'view':
        _viewaAnnouncement(announcement);
        break;
      case 'edit':
        _editAnnouncement(announcement);
        break;
      case 'delete':
        _deleteAnnouncement(announcement);
        break;
    }
  }

  // View announcement method
  void _viewaAnnouncement(Map<String, dynamic> announcement) {
    AnnouncementDetailDialog.show(context, announcement);
  }

  void _editAnnouncement(Map<String, dynamic> announcement) {
    final announcementId = announcement['database_id'];
    if (announcementId != null) {
      context.go('/announcement/edit/$announcementId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit: Announcement ID not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteAnnouncement(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Announcement'),
          content: Text(
            'Are you sure you want to delete announcement ${announcement['id']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await _apiService.deleteAnnouncement(
                    announcement['database_id'],
                    notifyDeactivation: false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Announcement ${announcement['id']} deleted',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh the list
                  _fetchAnnouncements();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete announcement: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Search functionality
  void _onSearchChanged(String value) {
    // TODO: Implement search functionality with backend API
    // For now, just update the controller
    setState(() {
      // Filter logic will go here
    });
  }

  // Filter functionality
  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      // TODO: Implement filter functionality with backend API
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  // Auth initialization method
  Future<void> _initializeAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          _apiService.setAuthToken(token);
          print('[v0] Auth token set for user: ${user.email}');
        }
      }
      // Fetch announcements after auth is set
      await _fetchAnnouncements();
    } catch (e) {
      print('[v0] Error initializing auth: $e');
      setState(() {
        _errorMessage = 'Authentication error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      const buildingId = 'building_001';

      print('[v0] Fetching announcements for building: $buildingId');

      final response = await _apiService.getAnnouncements(
        buildingId: buildingId,
        audience: 'all',
        activeOnly: false,
      );

      print('[v0] Full API response: $response');

      if (response.containsKey('announcements')) {
        final announcementsList = response['announcements'];

        if (announcementsList != null && announcementsList is List) {
          setState(() {
            _announcementItems = List<Map<String, dynamic>>.from(
              announcementsList.map((announcement) {
                return {
                  // Display fields for table
                  'id':
                      announcement['formatted_id'] ??
                      announcement['id'] ??
                      'N/A',
                  'database_id': announcement['id'],
                  'Title': announcement['title'] ?? 'Untitled',
                  'type': announcement['type'] ?? 'General',
                  'location':
                      announcement['location_affected'] ?? 'Not specified',
                  'dateAdded':
                      announcement['date_added'] != null
                          ? DateTime.parse(
                            announcement['date_added'],
                          ).toString().split(' ')[0]
                          : 'N/A',

                  // Additional fields for detail popup
                  'title': announcement['title'] ?? 'Untitled',
                  'messageBody':
                      announcement['content'] ??
                      'No message content available.',
                  'audiences': _parseAudience(announcement['audience']),
                  'scheduleVisibility': _parseSchedule(announcement),
                  'attachments': announcement['attachments'] ?? [],
                  'isPinned': announcement['is_pinned'] ?? false,
                  'content': announcement['content'] ?? '',
                  'audience': announcement['audience'] ?? 'all',
                  'is_active': announcement['is_active'] ?? true,
                  'building_id': announcement['building_id'] ?? buildingId,
                  'created_at': announcement['created_at'],
                  'updated_at': announcement['updated_at'],
                };
              }),
            );
            _isLoading = false;
            print(
              '[v0] Successfully loaded ${_announcementItems.length} announcements',
            );
          });
        } else {
          setState(() {
            _announcementItems = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid response format from server';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('[v0] Error fetching announcements: $e');
      print('[v0] Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load announcements: $e';
        _isLoading = false;
      });
    }
  }

  List<String> _parseAudience(String? audience) {
    if (audience == null || audience.isEmpty) return ['All'];

    switch (audience.toLowerCase()) {
      case 'tenant':
      case 'tenants':
        return ['Tenants'];
      case 'staff':
      case 'maintenance staff':
        return ['Maintenance Staff'];
      case 'all':
      default:
        return ['All'];
    }
  }

  Map<String, dynamic>? _parseSchedule(Map<String, dynamic> announcement) {
    final startDate = announcement['start_date'];
    final endDate = announcement['end_date'];
    final startTime = announcement['start_time'];
    final endTime = announcement['end_time'];

    if (startDate != null || endDate != null) {
      return {
        'startDate': startDate,
        'endDate': endDate,
        'startTime': startTime ?? '00:00',
        'endTime': endTime ?? '23:59',
      };
    }

    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'announcement',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with breadcrumbs and Create New button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Breadcrumb and title section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Announcement",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Breadcrumb navigation
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => context.go('/dashboard'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Dashboard'),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 16,
                        ),
                        TextButton(
                          onPressed: null,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Announcement'),
                        ),
                      ],
                    ),
                  ],
                ),
                // Create New button
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/announcement/create');
                  },
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    "Create New",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAnnouncements,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Main Content Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table header with search and filter
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Announcement",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          // Search and Filter section
                          Row(
                            children: [
                              // Search field
                              Container(
                                width: 240,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Filter button
                              PopupMenuButton<String>(
                                initialValue: _selectedFilter,
                                onSelected: _onFilterChanged,
                                itemBuilder:
                                    (context) =>
                                        _filterOptions.map((filter) {
                                          return PopupMenuItem(
                                            value: filter,
                                            child: Text(filter),
                                          );
                                        }).toList(),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        color: Colors.grey[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Filter",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[400]),

                    // Data Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 30,
                        headingRowHeight: 56,
                        dataRowHeight: 64,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey[50],
                        ),
                        headingTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        columns: [
                          DataColumn(label: _fixedCell(0, const Text("ID"))),
                          DataColumn(
                            label: _fixedCell(
                              1,
                              const Text("ANNOUNCEMENT TITLE"),
                            ),
                          ),
                          DataColumn(label: _fixedCell(2, const Text("TYPE"))),
                          DataColumn(
                            label: _fixedCell(3, const Text("LOCATION")),
                          ),
                          DataColumn(
                            label: _fixedCell(4, const Text("DATE ADDED")),
                          ),
                          DataColumn(label: _fixedCell(5, const Text(""))),
                        ],
                        rows:
                            _announcementItems.map((announcement) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    _fixedCell(
                                      0,
                                      _ellipsis(
                                        announcement['id'],
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      1,
                                      _ellipsis(announcement['Title']),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      2,
                                      _buildTypeChip(announcement['type']),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      3,
                                      _ellipsis(announcement['location']),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      4,
                                      _ellipsis(announcement['dateAdded']),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      5,
                                      Builder(
                                        builder: (context) {
                                          return IconButton(
                                            onPressed: () {
                                              final rbx =
                                                  context.findRenderObject()
                                                      as RenderBox;
                                              final position = rbx
                                                  .localToGlobal(Offset.zero);
                                              _showActionMenu(
                                                context,
                                                announcement,
                                                position,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.grey[400],
                                              size: 20,
                                            ),
                                          );
                                        },
                                      ),
                                      align: Alignment.center,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.grey[400]),

                    // Pagination section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing 1 to ${_announcementItems.length} of ${_announcementItems.length} entries",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          // Pagination controls
                          Row(
                            children: [
                              IconButton(
                                onPressed:
                                    null, // TODO: Implement previous page
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: Colors.grey[400],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text(
                                    "01",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    "02",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Implement next page
                                },
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Type chip widget - styled for announcement types
  Widget _buildTypeChip(String type) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case 'Utility Interruption':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'Maintenance':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'Emergency':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case 'Announcement':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
