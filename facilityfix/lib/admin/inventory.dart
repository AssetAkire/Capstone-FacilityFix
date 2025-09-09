import 'dart:async';
import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/forms/inventory.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/view_details/inventory_details.dart' show InventoryDetails;
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/cards.dart';
import 'package:facilityfix/widgets/modals.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

/// Inventory page (Admin)
/// - Tabs: Items | Requests
/// - Filters: Search, Status, Department
/// - Uses demo data; replace _allItems/_allRequests with backend later.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // ── Tabs ───────────────────────────────────────────────────────────────────
  String selectedTabLabel = 'Items';

  // ── Search & Filters ───────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // We treat "Department" as your "Classification" in the UI.
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';

  final List<String> _statusOptions = const [
    'All',
    'In Stock',
    'Low',
    'Out of Stock',
    'Pending',
    'Approved',
    'Rejected',
  ];

  final List<String> _deptOptions = const [
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Masonry',
    'Maintenance',
  ];

  // ── Demo data (replace with backend) ───────────────────────────────────────
  final List<_Item> _allItems = const [
    _Item(
      name: 'Galvanized Screw 3mm',
      department: 'Carpentry',
      id: 'MAT-CIV-003',
      stockStatus: 'In Stock',
      quantity: 15,
    ),
    _Item(
      name: 'LED Tube Light 24W',
      department: 'Electrical',
      id: 'EL-LED-024',
      stockStatus: 'Low',
      quantity: 3,
    ),
    _Item(
      name: 'PVC Pipe 1 1/2"',
      department: 'Plumbing',
      id: 'PL-PVC-112',
      stockStatus: 'In Stock',
      quantity: 42,
    ),
  ];

  final List<_Request> _allRequests = const [
    _Request(
      name: 'LED Tube Light',
      requestId: 'REQ-2025-001',
      department: 'Electrical',
      status: 'Pending',
    ),
    _Request(
      name: 'Door Hinge Set',
      requestId: 'REQ-2025-010',
      department: 'Carpentry',
      status: 'Approved',
    ),
  ];

  // ── Debounce for search ────────────────────────────────────────────────────
  Timer? _debounce;

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        // Trigger re-filter
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering helpers ──────────────────────────────────────────────────────
  String _q() => _searchController.text.trim().toLowerCase();

  bool _searchMatch(String haystack) {
    final q = _q();
    if (q.isEmpty) return true;
    return haystack.toLowerCase().contains(q);
  }

  bool _deptAllowed(String department) {
    if (_selectedDepartment == 'All') return true;
    return department == _selectedDepartment;
  }

  bool _statusAllowedForItem(String stockStatus) {
    if (_selectedStatus == 'All') return true;
    // Items consider stock statuses; map "Out of Stock" vs "Out"
    final normalized = stockStatus.toLowerCase();
    if (_selectedStatus == 'Out of Stock') {
      return normalized == 'out of stock' || normalized == 'out';
    }
    return _selectedStatus.toLowerCase() == normalized;
  }

  bool _statusAllowedForRequest(String status) {
    if (_selectedStatus == 'All') return true;
    // Requests consider Pending/Approved/Rejected
    return status == _selectedStatus;
  }

  List<_Item> get _filteredItems {
    final list = _allItems.where((it) {
      final deptOk = _deptAllowed(it.department);
      final statusOk = _statusAllowedForItem(it.stockStatus);
      final searchOk = _searchMatch('${it.name} ${it.id} ${it.department} ${it.stockStatus} ${it.quantity}');
      return deptOk && statusOk && searchOk;
    }).toList();

    // Optional: sort by quantity ascending (low → high)
    list.sort((a, b) => a.quantity.compareTo(b.quantity));
    return list;
  }

  List<_Request> get _filteredRequests {
    final list = _allRequests.where((rq) {
      final deptOk = _deptAllowed(rq.department);
      final statusOk = _statusAllowedForRequest(rq.status);
      final searchOk = _searchMatch('${rq.name} ${rq.requestId} ${rq.department} ${rq.status}');
      return deptOk && statusOk && searchOk;
    }).toList();
    return list;
  }

  // ── Refresh (stub) ────────────────────────────────────────────────────────
  Future<void> _refresh() async {
    // TODO: replace with backend fetch
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {/* after fetch, rebuild */});
  }

  // ── Dialog: Create Inventory Item ─────────────────────────────────────────
  void _showCreateItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Create Inventory Item',
        message: 'Would you like to create a new inventory item?',
        primaryText: 'Yes',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InventoryForm(requestType: 'Inventory Form'),
            ),
          );
        },
        secondaryText: 'Cancel',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // ── Tab content builders ───────────────────────────────────────────────────
  Widget _buildItemsList() {
    final list = _filteredItems;
    if (list.isEmpty) {
      return const _EmptyState(
        title: 'No items found',
        subtitle: 'Try adjusting search or filters.',
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final it = list[i];
        return InventoryCard(
          itemName: it.name,
          stockStatus: it.stockStatus,
          itemId: it.id,
          department: it.department,
          quantityInStock: it.quantity.toString(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InventoryDetails(
                  selectedTabLabel: 'inventory details',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsList() {
    final list = _filteredRequests;
    if (list.isEmpty) {
      return const _EmptyState(
        title: 'No item found',
        subtitle: 'Try adjusting search or filters.',
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final rq = list[i];
        return InventoryRequestCard(
          itemName: rq.name,
          requestId: rq.requestId,
          department: rq.department,
          status: rq.status,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InventoryDetails(
                  selectedTabLabel: 'inventory request',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabContent() {
    return selectedTabLabel.toLowerCase() == 'items'
        ? _buildItemsList()
        : _buildRequestsList();
  }

  // ── Bottom navigation ──────────────────────────────────────────────────────
  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const CalendarPage(),
      const InventoryPage(),
    ];
    if (index != 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute tab counts on the fly to avoid setState in build.
    final computedTabs = [
      TabItem(label: 'Items', count: _filteredItems.length),
      TabItem(label: 'Requests', count: _filteredRequests.length),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Inventory',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search + Status + Department filters
                SearchAndFilterBar(
                  searchController: _searchController,
                  selectedStatus: _selectedStatus,
                  statuses: _statusOptions,
                  selectedClassification: _selectedDepartment, // using dept as classification
                  classifications: _deptOptions,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedStatus = status.trim().isEmpty ? 'All' : status;
                    });
                  },
                  onClassificationChanged: (dept) {
                    setState(() {
                      _selectedDepartment = dept.trim().isEmpty ? 'All' : dept;
                    });
                  },
                  onSearchChanged: (_) {
                    // already debounced via listener; setState only if you want immediate
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                // Tabs (with live counts)
                StatusTabSelector(
                  tabs: computedTabs,
                  selectedLabel: selectedTabLabel,
                  onTabSelected: (label) {
                    setState(() => selectedTabLabel = label);
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  selectedTabLabel == 'Items' ? 'Recent Items' : 'Recent Requests',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        ),
      ),

      // FAB only on Items tab
      floatingActionButton: selectedTabLabel.toLowerCase() == 'items'
          ? AddButton(onPressed: () => _showCreateItemDialog(context))
          : null,

      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: 4,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ── Local helpers/models ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF9AA0A6)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF697076)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String name;
  final String department; // Electrical | Plumbing | Carpentry | ...
  final String id;
  final String stockStatus; // In Stock | Low | Out of Stock
  final int quantity;

  const _Item({
    required this.name,
    required this.department,
    required this.id,
    required this.stockStatus,
    required this.quantity,
  });
}

class _Request {
  final String name;
  final String requestId;
  final String department;
  final String status; // Pending | Approved | Rejected

  const _Request({
    required this.name,
    required this.requestId,
    required this.department,
    required this.status,
  });
}
