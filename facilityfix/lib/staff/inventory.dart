import 'package:facilityfix/staff/form/inventory_form.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/view_details/invetory_details.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/cards.dart';
import 'package:facilityfix/staff/notification.dart';

class InventoryItem {
  final String itemName;
  final String itemId;
  final String department;
  final int quantity;
  final String status; // Stock | Out of Stock | Critical

  const InventoryItem({
    required this.itemName,
    required this.itemId,
    required this.department,
    required this.quantity,
    required this.status,
  });
}

class InventoryRequest {
  final String itemName;
  final String requestId;
  final String department;
  final String status;

  const InventoryRequest({
    required this.itemName,
    required this.requestId,
    required this.department,
    required this.status,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // ----- Tabs -----
  String selectedTabLabel = "Items";
  final tabs = [
    TabItem(label: 'Items', count: 1),
    TabItem(label: 'Requests', count: 1),
  ];

  // ----- Bottom nav -----
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

  // ----- Filters -----
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';

  final List<String> _statusOptions = const [
    'All',
    'In Stock',
    'Out of Stock',
    'Critical',
  ];
  final List<String> _deptOptions = const [
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Masonry',
    'Maintenance',
  ];

  // ----- Demo data -----
  final List<InventoryItem> _items = const [
    InventoryItem(
      itemName: 'Galvanized Screw 3mm',
      itemId: 'MAT-CIV-003',
      department: 'Carpentry',
      quantity: 50,
      status: 'Stock',
    ),
    InventoryItem(
      itemName: 'LED Tube Light 18W',
      itemId: 'ELE-LED-018',
      department: 'Electrical',
      quantity: 0,
      status: 'Out of Stock',
    ),
    InventoryItem(
      itemName: 'PVC Elbow 1/2"',
      itemId: 'PLB-PVC-012E',
      department: 'Plumbing',
      quantity: 25,
      status: 'Critical',
    ),
  ];

  final List<InventoryRequest> _requests = const [
    InventoryRequest(
      itemName: 'LED Tube Light',
      requestId: 'REQ-2025-001',
      department: 'Electrical',
      status: 'Pending',
    ),
  ];

  // ===== Filtering =====
  bool _statusAllowed(InventoryItem it) {
    if (_selectedStatus == 'All') return true;
    return it.status == _selectedStatus;
  }

  bool _deptAllowed(InventoryItem it) {
    if (_selectedDepartment == 'All') return true;
    return it.department == _selectedDepartment;
  }

  bool _searchMatchesItem(InventoryItem it) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      it.itemName,
      it.itemId,
      it.department,
      it.status,
      it.quantity.toString(),
    ].any((s) => s.toLowerCase().contains(q));
  }

  List<InventoryItem> get _filteredItems {
    final list = _items.where(_statusAllowed).where(_deptAllowed).where(_searchMatchesItem).toList();
    list.sort((a, b) => a.quantity.compareTo(b.quantity)); // sort lower → upper
    return list;
  }

  List<InventoryRequest> get _filteredRequests {
    final q = _searchController.text.trim().toLowerCase();
    return _requests.where((r) {
      if (q.isEmpty) return true;
      return [
        r.itemName,
        r.requestId,
        r.department,
        r.status,
      ].any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  Widget _buildTabContent() {
    switch (selectedTabLabel.toLowerCase()) {
      case 'items':
        final items = _filteredItems;
        if (items.isEmpty) return const Center(child: Text('No items found.'));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final it = items[i];
            return InventoryCard(
              itemName: it.itemName,
              stockStatus: it.status,
              itemId: it.itemId,
              department: it.department,
              quantityInStock: it.quantity.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryDetails(
                      selectedTabLabel: 'inventory details',
                    ),
                  ),
                );
              },
            );
          },
        );

      case 'requests':
        final reqs = _filteredRequests;
        if (reqs.isEmpty) return const Center(child: Text('No requests found.'));
        return ListView.separated(
          itemCount: reqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = reqs[i];
            return InventoryRequestCard(
              itemName: r.itemName,
              requestId: r.requestId,
              department: r.department,
              status: r.status,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryDetails(
                      selectedTabLabel: 'inventory request',
                    ),
                  ),
                );
              },
            );
          },
        );

      default:
        return const Center(child: Text('No data.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRequestsTab = selectedTabLabel.toLowerCase() == 'requests';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Inventory Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search + Status + Department filters
                  SearchAndFilterBar(
                    searchController: _searchController,
                    selectedStatus: _selectedStatus,
                    statuses: _statusOptions,
                    selectedClassification: _selectedDepartment,
                    classifications: _deptOptions,
                    onStatusChanged: (status) {
                      setState(() => _selectedStatus = status.trim().isEmpty ? 'All' : status);
                    },
                    onClassificationChanged: (dept) {
                      setState(() => _selectedDepartment = dept.trim().isEmpty ? 'All' : dept);
                    },
                    onSearchChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  StatusTabSelector(
                    tabs: tabs,
                    selectedLabel: selectedTabLabel,
                    onTabSelected: (label) => setState(() => selectedTabLabel = label),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    selectedTabLabel.toLowerCase() == 'items' ? 'Recent Items' : 'Recent Requests',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),

            // ✅ Direct to InventoryForm on Add
            if (isRequestsTab)
              Positioned(
                bottom: 24,
                right: 24,
                child: AddButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InventoryForm(
                          requestType: 'Basic Information', // start at Basic Info
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: 4,
        onTap: _onTabTapped,
      ),
    );
  }
}
