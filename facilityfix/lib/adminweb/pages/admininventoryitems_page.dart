import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../services/api_service.dart';
import '../../services/auth_storage.dart';

class InventoryManagementItemsPage extends StatefulWidget {
  const InventoryManagementItemsPage({super.key});

  @override
  State<InventoryManagementItemsPage> createState() =>
      _InventoryManagementItemsPageState();
}

class _InventoryManagementItemsPageState
    extends State<InventoryManagementItemsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  // TODO: Replace with actual building ID from user session
  final String _buildingId = 'default_building_id';

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        print('[v0] Auth token retrieved and set in API service');
      } else {
        print('[v0] Warning: No auth token found in storage');
        setState(() {
          _errorMessage = 'Authentication required. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final response = await _apiService.getInventoryItems(
        buildingId: _buildingId,
      );

      if (response['success'] == true) {
        setState(() {
          _inventoryItems = List<Map<String, dynamic>>.from(
            response['data'] ?? [],
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load inventory items';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[v0] Error fetching inventory items: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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

  // Column widths for table
  final List<double> _colW = <double>[
    180, // ITEM NO.
    340, // ITEM NAME
    120, // STOCK
    140, // TAG
    120, // STATUS
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
    Map<String, dynamic> item,
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
        _handleActionSelection(value, item);
      }
    });
  }

  // Handle action selection
  void _handleActionSelection(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'view':
        _viewItem(item);
        break;
      case 'edit':
        _editItem(item);
        break;
      case 'delete':
        _deleteItem(item);
        break;
    }
  }

  // View item method
  void _viewItem(Map<String, dynamic> item) {
    final itemId = item['id'] ?? item['item_code'];
    context.go('/inventory/item/$itemId');
  }

  // Edit item method
  void _editItem(Map<String, dynamic> item) {
    // Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit item: ${item['id']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete item ${item['item_name']}?',
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
                  await _apiService.deleteInventoryItem(item['id']);
                  // Reload the list
                  _loadInventoryItems();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Item ${item['item_name']} deleted'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting item: $e'),
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

  String _getItemStatus(Map<String, dynamic> item) {
    final currentStock = item['current_stock'] ?? 0;
    final reorderLevel = item['reorder_level'] ?? 0;

    if (currentStock == 0) {
      return 'Out of Stock';
    } else if (currentStock <= reorderLevel) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  String _getItemTag(Map<String, dynamic> item) {
    final isCritical = item['is_critical'] ?? false;
    final currentStock = item['current_stock'] ?? 0;
    final reorderLevel = item['reorder_level'] ?? 0;

    if (isCritical) {
      return 'Critical';
    } else if (currentStock > reorderLevel * 2) {
      return 'High-Turnover';
    } else {
      return 'Essential';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'inventory_items',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Inventory Management",
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
                          onPressed: () => context.go('/inventory/items'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Inventory Management'),
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
                          child: const Text('Items'),
                        ),
                      ],
                    ),
                  ],
                ),
                // Create New button
                ElevatedButton.icon(
                  onPressed: () {
                    context.goNamed('inventory_item_create');
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
                          "Inventory Items",
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
                  else if (_errorMessage != null)
                    Padding(
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
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadInventoryItems,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_inventoryItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No inventory items found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    // Data Table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 30,
                        headingRowHeight: 56,
                        dataRowHeight: 64,
                        headingRowColor: WidgetStateProperty.all(
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
                          DataColumn(
                            label: _fixedCell(0, const Text("ITEM NO.")),
                          ),
                          DataColumn(
                            label: _fixedCell(1, const Text("ITEM NAME")),
                          ),
                          DataColumn(label: _fixedCell(2, const Text("STOCK"))),
                          DataColumn(label: _fixedCell(3, const Text("TAG"))),
                          DataColumn(
                            label: _fixedCell(4, const Text("STATUS")),
                          ),
                          DataColumn(label: _fixedCell(5, const Text(""))),
                        ],
                        rows:
                            _inventoryItems.map((item) {
                              final itemNo =
                                  item['item_code'] ?? item['id'] ?? 'N/A';
                              final itemName = item['item_name'] ?? 'Unknown';
                              final stock =
                                  (item['current_stock'] ?? 0).toString();
                              final tag = _getItemTag(item);
                              final status = _getItemStatus(item);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    _fixedCell(
                                      0,
                                      _ellipsis(
                                        itemNo,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(_fixedCell(1, _ellipsis(itemName))),
                                  DataCell(_fixedCell(2, _ellipsis(stock))),
                                  DataCell(_fixedCell(3, _buildTagChip(tag))),
                                  DataCell(
                                    _fixedCell(4, _buildStatusChip(status)),
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
                                                item,
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
                          "Showing 1 to ${_inventoryItems.length} of ${_inventoryItems.length} entries",
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

  // Tag chip widget
  Widget _buildTagChip(String tag) {
    Color bgColor;
    Color textColor;

    switch (tag) {
      case 'High-Turnover':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'Critical':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'Essential':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Status chip widget
  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'In Stock':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'Low Stock':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case 'Out of Stock':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
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
