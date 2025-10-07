import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../popupwidgets/roledialogue_popup.dart';
import '../data/rolepermission_metadata.dart';

class AdminRolePage extends StatefulWidget {
  const AdminRolePage({super.key});

  @override
  State<AdminRolePage> createState() => _AdminRolePageState();
}

class _AdminRolePageState extends State<AdminRolePage> {
  // ---- Controllers and State Variables ----
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All Roles';
  String _selectedStatusFilter = 'All Status';
  String? _selectedRoleId; // Track which role is selected for details view

  // ---- Sample Role Data ----
  final List<Map<String, dynamic>> _allRoles = [
    {
      'id': 'administrator',
      'name': 'ADMINISTRATOR',
      'description': 'Full access to all system features and settings',
      'userCount': 4,
      'permissions': [
        {
          'category': 'Users',
          'icon': Icons.group,
          'color': Colors.green,
          'actions': [
            {
              'name': 'View Users',
              'description': 'See all users in the system',
            },
            {
              'name': 'Create Users',
              'description': 'Add new users to the system',
            },
            {
              'name': 'Edit Users',
              'description': 'Update user details, roles, and access',
            },
            {
              'name': 'Delete Users',
              'description': 'Remove users from the system',
            },
          ],
        },
        {
          'category': 'Role & Access Control',
          'icon': Icons.security,
          'color': Colors.blue,
          'actions': [
            {
              'name': 'Assign roles and manage user permissions',
              'description': '',
            },
          ],
        },
      ],
    },
    {
      'id': 'maintenance_department',
      'name': 'MAINTENANCE DEPARTMENT',
      'description':
          'Access to work orders, maintenance scheduling, and inventory management.',
      'userCount': 4,
      'permissions': [
        {
          'category': 'Work Orders',
          'icon': Icons.build,
          'color': Colors.orange,
          'actions': [
            {
              'name': 'Create Work Orders',
              'description': 'Generate new maintenance tasks',
            },
            {
              'name': 'Update Work Orders',
              'description': 'Modify existing work orders',
            },
            {
              'name': 'View Work Orders',
              'description': 'Access all work order information',
            },
          ],
        },
        {
          'category': 'Inventory Management',
          'icon': Icons.inventory,
          'color': Colors.purple,
          'actions': [
            {
              'name': 'Manage Inventory',
              'description': 'Control inventory items and requests',
            },
          ],
        },
      ],
    },
    {
      'id': 'tenants',
      'name': 'TENANTS',
      'description':
          'Limited access to submit repair requests and view updates, announcements, and shared calendars.',
      'userCount': 4,
      'permissions': [
        {
          'category': 'Repair Requests',
          'icon': Icons.build_circle,
          'color': Colors.red,
          'actions': [
            {
              'name': 'Submit Requests',
              'description': 'Create new repair requests',
            },
            {
              'name': 'View Request Status',
              'description': 'Track repair request progress',
            },
          ],
        },
        {
          'category': 'Announcements',
          'icon': Icons.announcement,
          'color': Colors.amber,
          'actions': [
            {
              'name': 'View Announcements',
              'description': 'Read system announcements',
            },
          ],
        },
      ],
    },
  ];

  // Convert dialog's nested map -> page's grouped display format + keep 'permissionKeys' for edit
  List<Map<String, dynamic>> _dialogPermsToDisplayList(
    Map<String, Map<String, bool>> perms,
    List<String> outKeys,
  ) {
    final selectedKeys = <String>[];
    perms.forEach((_, cat) {
      cat.forEach((k, v) {
        if (v == true) selectedKeys.add(k);
      });
    });
    outKeys.addAll(selectedKeys); // return the flat keys too (for editing)

    // group by category using _permMeta
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final key in selectedKeys) {
      final meta = permissionMetadata[key];
      if (meta == null) continue;
      final cat = meta['category'] as String;
      grouped.putIfAbsent(cat, () {
        return {
          'category': cat,
          'icon': meta['icon'],
          'color': meta['color'],
          'actions': <Map<String, String>>[],
        };
      });
      (grouped[cat]!['actions'] as List).add({
        'name': meta['label'],
        'description': meta['desc'],
      });
    }
    return grouped.values.toList();
  }

  // Convert page model (flat 'permissionKeys') -> dialog nested map
  Map<String, Map<String, bool>> _permissionKeysToDialogMap(List<String> keys) {
    // Start with all known permissions set to false, grouped by dialog category key
    final Map<String, Map<String, bool>> result = {};

    // Seed structure using the centralized permissionMetadata
    permissionMetadata.forEach((permKey, meta) {
      final categoryName = meta['category'] as String;
      final categoryKey = catKey(categoryName);
      result.putIfAbsent(categoryKey, () => <String, bool>{});
      result[categoryKey]![permKey] = false;
    });

    // Flip the ones that are present in the flat list
    for (final k in keys) {
      final meta = permissionMetadata[k];

      if (meta == null) {
        // OPTIONAL: if you want to keep unknown keys instead of skipping
        // put them under a "misc" category.
        result.putIfAbsent('misc', () => <String, bool>{});
        result['misc']![k] = true;
        continue;
      }

      final categoryKey = catKey(meta['category'] as String);
      result.putIfAbsent(categoryKey, () => <String, bool>{});
      result[categoryKey]![k] = true;
    }

    return result;
  }

  // Map visual category name to dialog categoryKey
  String catKey(String category) {
    switch (category) {
      case 'Users':
        return 'users';
      case 'System':
        return 'system';
      case 'Analytics':
        return 'analytics';
      case 'Announcements':
        return 'announcements';
      case 'Inventory Management':
        return 'inventory';
      case 'Work Orders':
        return 'workOrder';
      case 'Calendar':
        return 'calendar';
      case 'Role & Access Control':
        return 'users'; // 'roleAccessControl' lives under Users in dialog
      default:
        return 'misc';
    }
  }

  // ---- Filtered Roles List ----
  List<Map<String, dynamic>> get _filteredRoles {
    return _allRoles.where((role) {
      final q = _searchController.text.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          role['name'].toString().toLowerCase().contains(q) ||
          role['description'].toString().toLowerCase().contains(q);

      final matchesRole =
          _selectedRoleFilter == 'All Roles' ||
          role['name'] == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == 'All Status';

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
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
      'inventory_items': '/inventory/items',
      'inventory_request': '/inventory/request',
      'analytics': '/analytics',
      'announcement': '/announcement',
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
  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
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
          items:
              options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    '$label: $option',
                    style: const TextStyle(fontSize: 14),
                  ),
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

  // ---- Role Card Builder ----
  Widget _buildRoleCard(Map<String, dynamic> role) {
    final bool isSelected = _selectedRoleId == role['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedRoleId = null;
            //_selectedRole = null;
          } else {
            _selectedRoleId = role['id'];
            //_selectedRole = role;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${role['userCount']} user${role['userCount'] != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    final hasKeys =
                        (role['permissionKeys'] is List) &&
                        (role['permissionKeys'] as List).isNotEmpty;

                    // Prepare initialRole for dialog (name, description, permissions)
                    final initialRole = <String, dynamic>{
                      'id': role['id'],
                      'name': role['name'],
                      'description': role['description'],
                      'permissions':
                          hasKeys
                              ? _permissionKeysToDialogMap(
                                List<String>.from(role['permissionKeys']),
                              )
                              : <
                                String,
                                Map<String, bool>
                              >{}, // legacy roles open with no checks
                    };

                    RoleDialog.showEdit(
                      context,
                      initialRole: initialRole,
                      onRoleUpdated: (updated) {
                        setState(() {
                          // Convert back to page display + keep keys
                          final updatedKeys = <String>[];
                          final displayPerms = _dialogPermsToDisplayList(
                            Map<String, Map<String, bool>>.from(
                              updated['permissions'] ?? {},
                            ),
                            updatedKeys,
                          );

                          final idx = _allRoles.indexWhere(
                            (r) => r['id'] == role['id'],
                          );
                          if (idx != -1) {
                            _allRoles[idx] = {
                              ..._allRoles[idx],
                              'name': updated['name'] ?? _allRoles[idx]['name'],
                              'description':
                                  updated['description'] ??
                                  _allRoles[idx]['description'],
                              'permissions': displayPerms,
                              'permissionKeys': updatedKeys,
                            };
                          }
                        });
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Delete Role"),
                            content: const Text(
                              "Are you sure you want to delete this role?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(ctx).pop(), // Cancel
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _allRoles.removeWhere(
                                      (r) => r['id'] == role['id'],
                                    );
                                    //_filteredRoles = List.from(_allRoles);
                                  });
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- Role Details Widget ----
  Widget _buildRoleDetails() {
    if (_selectedRoleId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        margin: const EdgeInsets.only(top: 12),
        constraints: const BoxConstraints(minHeight: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select A Role To View Its Details And Permissions',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // get selected role
    final selectedRole = _allRoles.firstWhere(
      (role) => role['id'] == _selectedRoleId,
    );

    // ensure permissions is a List
    final List permissions =
        (selectedRole['permissions'] is List)
            ? List.from(selectedRole['permissions'])
            : [];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Role Details Header ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (selectedRole['name'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (selectedRole['description'] ?? '').toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Users with this role: ${selectedRole['userCount'] ?? 0}', // default to 0
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // --- Permissions (non-scrollable list; parent scrolls) ---
          if (permissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'No permissions assigned to this role.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final permission =
                    (permissions[index] ?? {}) as Map<String, dynamic>;
                final IconData permissionIcon =
                    permission['icon'] is IconData
                        ? permission['icon'] as IconData
                        : Icons.lock_outline;
                final Color permissionColor =
                    permission['color'] is Color
                        ? permission['color'] as Color
                        : Colors.grey;
                final List actions =
                    permission['actions'] is List
                        ? List.from(permission['actions'])
                        : [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: permissionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          permissionIcon,
                          color: permissionColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              permission['category'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...actions.map<Widget>((action) {
                              final String name =
                                  (action is Map && action['name'] != null)
                                      ? action['name'].toString()
                                      : action.toString();
                              final String desc =
                                  (action is Map &&
                                          action['description'] != null)
                                      ? action['description'].toString()
                                      : '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    if (desc.isNotEmpty)
                                      Text(
                                        desc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoles = _filteredRoles;

    return FacilityFixLayout(
      currentRoute: 'user_roles',
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
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Dashboard'),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                TextButton(
                  onPressed: () => context.go('/user/users'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('User and Role Management'),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Roles'),
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
                        hintText: 'Search',
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
                  ['All Roles'],
                  (value) => setState(() => _selectedRoleFilter = value),
                ),
                const SizedBox(width: 16),

                // Status Filter
                _buildFilterDropdown(
                  'Status',
                  _selectedStatusFilter,
                  ['All Status'],
                  (value) => setState(() => _selectedStatusFilter = value),
                ),
                const SizedBox(width: 16),

                // Filter Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ---- Role Management Section (Wrapped in One Container) ----
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, // background to match other cards
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Management Header
                  const Text(
                    'Role Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 24),

                  // Roles & Details Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel - Roles List
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // Roles Header with Create Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Roles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    RoleDialog.showCreate(
                                      context,
                                      onRoleCreated: (newRole) {
                                        setState(() {
                                          // newRole['permissions'] is nested map -> convert to display + keep keys
                                          final keys = <String>[];
                                          final displayPerms =
                                              _dialogPermsToDisplayList(
                                                Map<
                                                  String,
                                                  Map<String, bool>
                                                >.from(
                                                  newRole['permissions'] ?? {},
                                                ),
                                                keys,
                                              );

                                          final normalized = <String, dynamic>{
                                            'id':
                                                (newRole['id'] ??
                                                        DateTime.now()
                                                            .millisecondsSinceEpoch)
                                                    .toString(),
                                            'name':
                                                newRole['name'] ??
                                                newRole['roleName'] ??
                                                '',
                                            'description':
                                                newRole['description'] ?? '',
                                            'userCount':
                                                newRole['userCount'] ?? 0,
                                            'permissions': displayPerms,
                                            // keep a flat list for edit round-trip:
                                            'permissionKeys': keys,
                                          };

                                          _allRoles.add(normalized);
                                          _selectedRoleId =
                                              normalized['id']; // auto-select
                                        });
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Create New'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Roles List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredRoles.length,
                              itemBuilder: (context, index) {
                                return _buildRoleCard(filteredRoles[index]);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Right Panel - Role Details
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Roles Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildRoleDetails(),
                          ],
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
    );
  }
}
