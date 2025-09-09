import 'dart:async';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/chat.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/notification.dart';
import 'package:facilityfix/staff/view_details/workorder.dart' show WorkOrderDetails;
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/cards.dart'; // RepairCard, MaintenanceCard, SearchAndFilterBar, StatusTabSelector, EmptyState
import 'package:facilityfix/widgets/helper_models.dart'; // WorkOrder, UiDateParser, TabItem
import 'package:flutter/material.dart';

/// Staff-only Work Order page
/// - Locks data to the staff's department (e.g., "Plumbing")
/// - Provides search and status filter (no department/classification filter)
/// - Two tabs: Repair Task / Maintenance Task
class WorkOrderPage extends StatefulWidget {
  /// Staff department. This page will ONLY show items from this department.
  final String staffDepartment;

  const WorkOrderPage({
    super.key,
    this.staffDepartment = 'Plumbing', // e.g., "Plumbing"
  });

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  String _selectedTabLabel = 'Repair Task';
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  /// Map requestId → details tab (for routing classification only).
  final Map<String, String> _taskTypeById = const {
    'CS-2025-001': 'repair detail',
    'CS-2025-002': 'repair detail',
    'JS-2025-031': 'repair detail',
    'JS-2025-032': 'repair detail',
    'JS-2025-033': 'repair detail',
    'MT-P-2025-011': 'maintenance detail',
    'MT-P-2025-012': 'maintenance detail',
  };

  // Sample Data (replace with API)
  final List<WorkOrder> _all = [
    // Concern Slip (assigned)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'CS-2025-001',
      date: 'Aug 25',
      status: 'Assigned',
      department: 'Plumbing',
      requestType: 'Concern Slip',
      unit: 'A 1001',
      priority: null,
      assignedTo: 'Juan Dela Cruz',
      assignedDepartment: 'Plumbing',
      assignedPhotoUrl: 'assets/images/avatar.png',
    ),
    // Concern Slip (done)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'CS-2025-002',
      date: 'Aug 22',
      status: 'Done',
      department: 'Plumbing',
      requestType: 'Concern Slip',
      unit: 'A 1001',
      priority: 'High',
      hasInitialAssessment: true,
      initialAssigneeName: 'Juan Dela Cruz',
      initialAssigneeDepartment: 'Plumbing',
      initialAssigneePhotoUrl: 'assets/images/avatar.png',
    ),

    // Job Service (assigned)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-031',
      date: 'Aug 21',
      status: 'Assigned',
      department: 'Plumbing',
      requestType: 'Job Service',
      unit: 'A 1001',
      priority: 'High',
      assignedTo: 'Juan Dela Cruz',
      assignedDepartment: 'Plumbing',
      assignedPhotoUrl: 'assets/images/avatar.png',
    ),
    // Job Service (done)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-032',
      date: 'Aug 22',
      status: 'Done',
      department: 'Plumbing',
      requestType: 'Job Service',
      unit: 'A 1001',
      priority: 'High',
      hasCompletionAssessment: true,
      completionAssigneeName: 'Juan Dela Cruz',
      completionAssigneeDepartment: 'Plumbing',
      completionAssigneePhotoUrl: 'assets/images/avatar.png',
    ),
    // Job Service (on hold)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-033',
      date: 'Aug 23',
      status: 'On Hold',
      department: 'Plumbing',
      requestType: 'Job Service',
      unit: 'A 1001',
      priority: 'High',
      hasInitialAssessment: true,
      initialAssigneeName: 'Juan Dela Cruz',
      initialAssigneeDepartment: 'Plumbing',
    ),

    // Maintenance Task (scheduled)
    WorkOrder(
      title: 'Quarterly Pipe Inspection',
      requestId: 'MT-P-2025-011',
      date: 'Aug 30',
      status: 'Scheduled',
      department: 'Plumbing',
      unit: 'Tower A - 5th Floor',
      priority: 'High',
      hasInitialAssessment: true,
      initialAssigneeName: 'Juan Dela Cruz',
      initialAssigneeDepartment: 'Plumbing',
      initialAssigneePhotoUrl: 'assets/images/avatar.png',
    ),
    // Maintenance Task (done)
    WorkOrder(
      title: 'Quarterly Pipe Inspection',
      requestId: 'MT-P-2025-012',
      date: 'Aug 28',
      status: 'Done',
      department: 'Plumbing',
      unit: 'Tower A - 5th Floor',
      priority: 'High',
      hasInitialAssessment: true,
      initialAssigneeName: 'Juan Dela Cruz',
      initialAssigneeDepartment: 'Plumbing',
      // initialAssigneePhotoUrl: 'assets/images/avatar.png',
    ),
  ];

  // Optional status override (e.g., if something moves On Hold → In Progress)
  final Map<String, String> _statusOverrideById = {};
  String _statusOf(WorkOrder w) => _statusOverrideById[w.requestId] ?? w.status;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

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
      WorkOrderPage(staffDepartment: widget.staffDepartment),
      const AnnouncementPage(),
      const CalendarPage(),
      const InventoryPage(),
    ];
    if (index != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  // Helpers: classification & filters

  /// True if a work order is a maintenance item based on the routing map.
  bool _isMaintenanceTask(WorkOrder w) =>
      (_taskTypeById[w.requestId]?.toLowerCase() ?? 'repair detail') ==
      'maintenance detail';

  /// True if a work order is a repair item.
  bool _isRepairTask(WorkOrder w) => !_isMaintenanceTask(w);

  /// Tab predicate
  bool _tabMatches(WorkOrder w) {
    final tab = _selectedTabLabel.toLowerCase();
    if (tab == 'repair task') return _isRepairTask(w);
    return _isMaintenanceTask(w); // 'Maintenance Task'
  }

  /// Enforce staff department only. (If staffDepartment == 'All', show all.)
  bool _departmentAllowed(WorkOrder w) {
    final dep = (w.department ?? '').toLowerCase().trim();
    final staff = widget.staffDepartment.toLowerCase().trim();
    if (staff == 'all' || staff.isEmpty) return true;
    return dep == staff;
  }

  /// Allow item if it matches the currently selected status.
  bool _statusAllowed(WorkOrder w) {
    final sel = _selectedStatus.toLowerCase().trim();
    if (sel == 'all' || sel.isEmpty) return true;
    return _statusOf(w).toLowerCase().trim() == sel;
  }

  /// Text search over several fields.
  bool _searchMatches(WorkOrder w) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      w.title,
      w.requestId,
      w.department ?? '',
      w.unit ?? '',
      w.status,
    ].any((s) => s.toLowerCase().contains(q));
  }

  /// Items after applying staff department → status → tab → search.
  List<WorkOrder> get _filtered {
    return _all
        .where(_departmentAllowed)
        .where(_statusAllowed)
        .where(_tabMatches)
        .where(_searchMatches)
        .toList();
  }

  /// Sort by date (latest first).
  List<WorkOrder> get _filteredSorted {
    final list = List<WorkOrder>.from(_filtered);
    list.sort(
      (a, b) => UiDateParser.parse(b.date).compareTo(UiDateParser.parse(a.date)),
    );
    return list;
  }

  /// Tabs with counts (within staff department + search scope; status-agnostic).
  List<TabItem> get _tabs {
    final visible = _all.where(_departmentAllowed).where(_searchMatches).toList();
    final repairCount = visible.where(_isRepairTask).length;
    final maintenanceCount = visible.where(_isMaintenanceTask).length;

    return [
      TabItem(label: 'Repair Task', count: repairCount),
      TabItem(label: 'Maintenance Task', count: maintenanceCount),
    ];
  }

  /// Status filter options available to staff. Always includes 'All'.
  List<String> get _statusOptions {
    final set = <String>{};
    for (final w in _all) {
      final status = (w.status).trim();
      if (status.isNotEmpty) set.add(status);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  /// Maps a WorkOrder to the exact detail label that WorkOrderDetails expects.
  /// All returned strings are lowercase to match WorkOrderDetails init logic.
  String _routeLabelFor(WorkOrder w) {
    final status = (w.status).toLowerCase().trim();
    final type = (w.requestType ?? '').toLowerCase().trim();

    // Maintenance items (based on _taskTypeById)
    if (_isMaintenanceTask(w)) {
      if (status == 'scheduled') return 'maintenance task scheduled';
      // treat done/assessed/closed as assessed view
      if (status == 'done' || status == 'assessed' || status == 'closed') {
        return 'maintenance task assessed';
      }
      // fallback
      return 'maintenance task scheduled';
    }

    // Repairs (tenant-originated)
    if (type == 'concern slip') {
      if (status == 'assigned') return 'concern slip assigned';
      if (status == 'assessed' || status == 'done' || status == 'closed') {
        return 'concern slip assessed';
      }
      // pending or others → default to assigned view
      return 'concern slip assigned';
    }

    if (type == 'job service') {
      if (status == 'done' || status == 'assessed' || status == 'closed') {
        return 'job service assessed';
      }
      // assigned / in progress / on hold → assigned view
      return 'job service assigned';
    }

    // Unknown type → safest fallback
    return 'concern slip assigned';
  }

  // Cards (Maintenance & Repair)
  Widget buildCard(WorkOrder w) {
    final forcedDept = widget.staffDepartment; // optional: show staff dept on card

    if (_isMaintenanceTask(w)) {
      return MaintenanceCard(
        title: w.title,
        requestId: w.requestId,
        unit: w.unit ?? '-',
        date: w.date,
        status: _statusOf(w),
        priority: w.priority ?? 'Medium',
        department: forcedDept,

        // Assignee (initial) so avatar shows
        hasInitialAssessment: w.hasInitialAssessment,
        initialAssigneeName: w.initialAssigneeName,
        initialAssigneeDepartment: w.initialAssigneeDepartment,
        initialAssigneePhotoUrl: w.initialAssigneePhotoUrl,

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkOrderDetails(
                selectedTabLabel: _routeLabelFor(w), workOrder: null, 
              ),
            ),
          );
        },
        onChatTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
      );
    }

    return RepairCard(
      title: w.title,
      requestId: w.requestId,
      reqDate: w.date,
      statusTag: _statusOf(w),
      unit: w.unit,
      priority: w.priority,
      departmentTag: forcedDept,
      requestType: w.requestType ?? '',

      // Initial assignee (avatar)
      hasInitialAssessment: w.hasInitialAssessment,
      initialAssigneeName: w.initialAssigneeName,
      initialAssigneeDepartment: w.initialAssigneeDepartment,
      initialAssigneePhotoUrl: w.initialAssigneePhotoUrl,

      // Completion assignee (avatar)
      hasCompletionAssessment: w.hasCompletionAssessment,
      completionAssigneeName: w.completionAssigneeName,
      completionAssigneeDepartment: w.completionAssigneeDepartment,
      completionAssigneePhotoUrl: w.completionAssigneePhotoUrl,

      // Current assignment
      assignedTo: w.assignedTo,
      assignedDepartment: w.assignedDepartment,
      assignedPhotoUrl: w.assignedPhotoUrl,

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkOrderDetails(
              selectedTabLabel: _routeLabelFor(w), workOrder: null, 
            ),
          ),
        );
      },
      onChatTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredSorted;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Work Order Management',
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search + Status filter only 
                SearchAndFilterBar(
                  searchController: _searchController,
                  // (Do NOT pass classification props → classification button hidden)
                  selectedStatus: _selectedStatus,
                  statuses: _statusOptions,
                  onStatusChanged: (status) {
                    setState(() {
                      final v = status.trim();
                      _selectedStatus = v.isEmpty ? 'All' : v;
                    });
                  },
                  onSearchChanged: (_) => setState(() {}), // instant search
                ),
                const SizedBox(height: 16),

                // Tabs
                StatusTabSelector(
                  tabs: _tabs,
                  selectedLabel: _selectedTabLabel,
                  onTabSelected: (label) =>
                      setState(() => _selectedTabLabel = label),
                ),
                const SizedBox(height: 20),

                // Header with count
                Row(
                  children: [
                    const Text(
                      'Recent Requests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${items.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => buildCard(items[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: 1,
        onTap: _onTabTapped,
      ),
    );
  }
}
