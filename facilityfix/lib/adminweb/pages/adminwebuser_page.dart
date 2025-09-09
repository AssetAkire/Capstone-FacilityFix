import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  // ---- Controllers and State Variables ----
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All Roles';
  String _selectedStatusFilter = 'All Status';
  List<bool> _selectedRows = [];

  // ---- Sample User Data ----
  final List<Map<String, dynamic>> _allUsers = [
    {
      'id': 1,
      'name': 'Noel Cruz',
      'role': 'Admin',
      'department': 'HVAC',
      'status': 'Online',
      'email': 'noel.cruz@facility.com',
      'lastActive': '2 min ago'
    },
    {
      'id': 2,
      'name': 'Juan Dela Cruz',
      'role': 'Staff',
      'department': 'Maintenance',
      'status': 'Online',
      'email': 'juan.delacruz@facility.com',
      'lastActive': '5 min ago'
    },
    {
      'id': 3,
      'name': 'Erika De Guzman',
      'role': 'Tenant',
      'department': '',
      'status': 'Offline',
      'email': 'erika.deguzman@tenant.com',
      'lastActive': '2 hours ago'
    },
  ];

  // ---- Filtered Users List ----
  List<Map<String, dynamic>> get _filteredUsers {
    return _allUsers.where((user) {
      // Search filter
      bool matchesSearch = _searchController.text.isEmpty ||
          user['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      
      // Role filter
      bool matchesRole = _selectedRoleFilter == 'All Roles' || user['role'] == _selectedRoleFilter;
      
      // Status filter
      bool matchesStatus = _selectedStatusFilter == 'All Status' || user['status'] == _selectedStatusFilter;
      
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Initialize selection state
    _selectedRows = List.generate(_allUsers.length, (index) => false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---- Navigation Helper ----
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_view': '/inventory/view',
      'inventory_add': '/inventory/add',
      'analytics': '/analytics',
      'notice': '/notice',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

  // ---- Logout Dialog ----
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

  // ---- Filter Dropdown Builder ----
  Widget _buildFilterDropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text('$label: $option', style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  // ---- Role Badge Widget ----
  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;

    switch (role) {
      case 'Admin':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case 'Staff':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
      case 'Tenant':
        backgroundColor = Colors.yellow.shade100;
        textColor = Colors.orange.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ---- Status Badge Widget ----
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status == 'Online' ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status == 'Online' ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  // ---- User Actions Menu ----
  void _showUserActions(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions for ${user['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit User'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit user functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit ${user['name']} - Feature coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Colors.orange),
                title: const Text('Reset Password'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement reset password functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset password for ${user['name']} - Feature coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  user['status'] == 'Online' ? Icons.block : Icons.check_circle,
                  color: user['status'] == 'Online' ? Colors.red : Colors.green,
                ),
                title: Text(user['status'] == 'Online' ? 'Deactivate User' : 'Activate User'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement user activation/deactivation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${user['status'] == 'Online' ? 'Deactivate' : 'Activate'} ${user['name']} - Feature coming soon!'
                      ),
                    ),
                  );
                },
              ),
              if (user['role'] != 'Admin')
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete User'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete User'),
                          content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // TODO: Implement delete functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete ${user['name']} - Feature coming soon!')),
                                );
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---- Create New User Dialog ----
  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New User'),
          content: const SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement create user functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create user - Feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filteredUsers;

    return FacilityFixLayout(
      currentRoute: 'user_users',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Page Header ----
            const Text(
              'User and Role Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // ---- Breadcrumb Navigation ----
            Row(
              children: [
                TextButton(
                  onPressed: () => context.go('/dashboard'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Dashboard'),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('User and Role Management'),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Users',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ---- Search and Filter Controls ----
            Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Role Filter
                _buildFilterDropdown(
                  'Role',
                  _selectedRoleFilter,
                  ['All Roles', 'Admin', 'Staff', 'Tenant'],
                  (value) => setState(() => _selectedRoleFilter = value),
                ),
                const SizedBox(width: 16),

                // Status Filter
                _buildFilterDropdown(
                  'Status',
                  _selectedStatusFilter,
                  ['All Status', 'Online', 'Offline'],
                  (value) => setState(() => _selectedStatusFilter = value),
                ),
                const SizedBox(width: 16),

                // Filter Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Filter',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Export Button
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),

                // Create New Button
                ElevatedButton.icon(
                  onPressed: _showCreateUserDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ---- Users Table ----
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 40), // Checkbox space
                          Expanded(flex: 3, child: Text('USER', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(flex: 2, child: Text('ROLE', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(flex: 2, child: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                          SizedBox(width: 48), // Actions space
                        ],
                      ),
                    ),

                    // Table Body
                    Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: index < _selectedRows.length ? _selectedRows[index] : false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (index < _selectedRows.length) {
                                        _selectedRows[index] = value ?? false;
                                      }
                                    });
                                  },
                                ),
                                
                                // User Info
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user['email'],
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Role Badge
                                Expanded(
                                  flex: 2,
                                  child: _buildRoleBadge(user['role']),
                                ),

                                // Department
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    user['department'].isEmpty ? '-' : user['department'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),

                                // Status Badge
                                Expanded(
                                  flex: 2,
                                  child: _buildStatusBadge(user['status']),
                                ),

                                // Actions Button
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onPressed: () => _showUserActions(context, user),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Pagination ----
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 1 to ${filteredUsers.length} of ${filteredUsers.length} entries',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        // TODO: Implement previous page
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '01',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Go to page 2
                      },
                      child: const Text('02'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        // TODO: Implement next page
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}