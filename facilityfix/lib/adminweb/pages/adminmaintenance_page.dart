import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../popupwidgets/createmaintenancedialogue_popup.dart';
import '../popupwidgets/maintenance_firesafety_popup.dart';
import '../popupwidgets/maintenance_earthquake_popup.dart';
import '../popupwidgets/maintenance_typhoonflood_popup.dart';
import '../services/api_service.dart';
import '../../services/auth_storage.dart';

class AdminMaintenancePage extends StatefulWidget {
  const AdminMaintenancePage({super.key});

  @override
  State<AdminMaintenancePage> createState() => _AdminMaintenancePageState();
}

class _AdminMaintenancePageState extends State<AdminMaintenancePage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAndFetchData();
  }

  Future<void> _initializeAndFetchData() async {
    try {
      // Get auth token from storage
      final token = await AuthStorage.getToken();
      if (token != null) {
        _apiService.setAuthToken(token);
      }

      await _fetchMaintenanceTasks();
    } catch (e) {
      print('[v0] Error initializing: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMaintenanceTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: Replace with actual building ID from user context
      final response = await _apiService.getMaintenanceTasks(
        buildingId: 'default_building_id',
      );

      if (response['success'] == true) {
        final tasks = response['tasks'] as List<dynamic>;
        setState(() {
          _tasks = tasks.map((task) => task as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(response['error'] ?? 'Failed to load tasks');
      }
    } catch (e) {
      print('[v0] Error fetching maintenance tasks: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load maintenance tasks: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to convert routeKey to actual route path
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

  // Handle logout functionality
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
                context.go('/'); // Go back to login page
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  final List<double> _colW = <double>[
    160, // ID
    180, // LOCATION
    250, // TASK TITLE
    140, // STATUS
    120, // DATE
    100, // RECURRENCE
    48, // ACTION
  ];

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
    Map<String, dynamic> maintenance,
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
        _handleActionSelection(value, maintenance);
      }
    });
  }

  // Handle action selection
  void _handleActionSelection(String action, Map<String, dynamic> maintenance) {
    switch (action) {
      case 'view':
        _viewMaintenance(maintenance);
        break;
      case 'edit':
        _editMaintenance(maintenance);
        break;
      case 'delete':
        _deleteMaintenance(maintenance);
        break;
    }
  }

  // View method
  void _viewMaintenance(Map<String, dynamic> maintenance) {
    final id = (maintenance['id'] ?? '').toString();
    final rawType =
        (maintenance['maintenanceType'] ??
                maintenance['type'] ??
                maintenance['maintenance_type'] ??
                '')
            .toString()
            .toLowerCase()
            .trim();

    if (rawType.contains('internal')) {
      context.push('/work/maintenance/$id/internal', extra: maintenance);
    } else if (rawType.contains('external')) {
      context.push('/work/maintenance/$id/external', extra: maintenance);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown maintenance type.')),
      );
    }
  }

  // Edit method
  void _editMaintenance(Map<String, dynamic> maintenance) {
    final id = (maintenance['id'] ?? '').toString();
    final rawType =
        (maintenance['maintenanceType'] ??
                maintenance['type'] ??
                maintenance['maintenance_type'] ??
                '')
            .toString()
            .toLowerCase()
            .trim();

    if (rawType.contains('internal')) {
      context.push('/work/maintenance/$id/internal?edit=1', extra: maintenance);
    } else if (rawType.contains('external')) {
      context.push('/work/maintenance/$id/external?edit=1', extra: maintenance);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown maintenance type.')),
      );
    }
  }

  void _deleteMaintenance(Map<String, dynamic> maintenance) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Maintenance'),
          content: Text(
            'Are you sure you want to delete maintenance ${maintenance['id']}?',
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
                  await _apiService.deleteMaintenanceTask(maintenance['id']);
                  await _fetchMaintenanceTasks(); // Refresh the list
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Maintenance ${maintenance['id']} deleted',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'work_maintenance',
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
            // Header section with title and Create New button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Work Orders",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //breadcrumbs
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
                          onPressed: () => context.go('/work/maintenance'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Work Orders'),
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
                          child: const Text('Maintenance Tasks'),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed:
                      () => showCreateMaintenanceTaskDialog(
                        context,
                        onInternal:
                            () =>
                                context.go('/work/maintenance/create/internal'),
                        onExternal:
                            () =>
                                context.go('/work/maintenance/create/external'),
                      ),
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
                    elevation: 2, // slight shadow for emphasis
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Summary cards
            Row(
              children: [
                _buildSummaryCard(
                  "FIRE SAFETY",
                  "3/5 Passed",
                  "Next: July 2025",
                  Colors.white,
                  onTap: () {
                    FireSafetyDialog.show(context, {
                      "description": "Fire safety inspection",
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  "EARTHQUAKE",
                  "1/2 Passed",
                  "Next: Sept 2025",
                  Colors.white,
                  onTap: () {
                    EarthquakeDialog.show(context, {
                      'description': 'Earthquake safety inspection tasks',
                      'priority': 'High',
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  "TYPHOON/FLOOD",
                  "2/3 Passed",
                  "Next: Jan 2026",
                  Colors.white,
                  onTap: () {
                    TyphoonFloodDialog.show(context, {
                      'description':
                          'Typhoon and flood safety inspection tasks for this facility',
                      'priority': 'High',
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  "PENDING ITEMS",
                  "${_tasks.where((t) => t['status'] == 'pending' || t['status'] == 'scheduled').length}",
                  "Total Pending",
                  Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                          "Maintenance Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _fetchMaintenanceTasks,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 240,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
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
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey[400]),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Error: $_error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchMaintenanceTasks,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No maintenance tasks found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    // Table content
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
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
                            label: _fixedCell(1, const Text("LOCATION")),
                          ),
                          DataColumn(
                            label: _fixedCell(2, const Text("TASK TITLE")),
                          ),
                          DataColumn(
                            label: _fixedCell(3, const Text("STATUS")),
                          ),
                          DataColumn(label: _fixedCell(4, const Text("DATE"))),
                          DataColumn(
                            label: _fixedCell(5, const Text("RECURRENCE")),
                          ),
                          DataColumn(label: _fixedCell(6, const Text(""))),
                        ],
                        rows:
                            _tasks.map((task) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    _fixedCell(
                                      0,
                                      _ellipsis(
                                        task['id'] ??
                                            task['task_code'] ??
                                            'N/A',
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
                                      _ellipsis(task['location'] ?? 'N/A'),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      2,
                                      _ellipsis(
                                        task['task_title'] ??
                                            task['taskTitle'] ??
                                            'N/A',
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      3,
                                      _buildStatusChip(
                                        task['status'] ?? 'scheduled',
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      4,
                                      _ellipsis(
                                        _formatDate(
                                          task['scheduled_date'] ??
                                              task['startDate'],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      5,
                                      _ellipsis(
                                        task['recurrence'] ??
                                            task['recurrence_pattern'] ??
                                            'N/A',
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _fixedCell(
                                      6,
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
                                                task,
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

                  // Pagination
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing 1 to ${_tasks.length} of ${_tasks.length} entries",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: null,
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
                              onPressed: () {},
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

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final dt = DateTime.parse(date);
        return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}-${dt.year}';
      }
      return date.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  // Widget for summary cards
  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    Color backgroundColor, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for status chips
  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    final statusLower = status.toLowerCase();

    if (statusLower.contains('progress')) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (statusLower.contains('new') ||
        statusLower.contains('scheduled')) {
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
    } else if (statusLower.contains('completed')) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF388E3C);
    } else {
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
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
