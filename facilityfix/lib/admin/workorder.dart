import 'dart:async';
import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/chat.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/forms/maintenance_task.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/view_details/workorder_details.dart'; // <-- CONNECTED
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/cards.dart';         // RepairCard, MaintenanceCard, SearchAndFilterBar, StatusTagSelector, EmptyState
import 'package:facilityfix/widgets/helper_models.dart'; // WorkOrder, UiDateParser, TabItem
import 'package:facilityfix/widgets/modals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // tenant-style date formatting

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  // ========= Top-bar UI state =========
  final TextEditingController _searchController = TextEditingController();
  String _selectedTabLabel = 'Repair'; // "Repair" | "Maintenance"
  String _selectedStatus = 'All';      // Status chip (All by default)

  // ===== Classification = Department =====
  // This drives the Classification dropdown in the top bar.
  String _selectedClassification = 'All';
  final List<String> _classificationOptions = const <String>[
    'All',
    'Plumbing',
    'Carpentry',
    'Electrical',
    'Masonry',
    'Maintenance',
  ];

  // ========= Routing / type helpers =========
  /// Maps IDs to a detail label (used for routing / display).
  /// We still auto-detect maintenance by "MT-" prefix even without an entry here.
  final Map<String, String> _taskTypeById = {
    'CS-2025-001': 'repair detail',
    'CS-2025-002': 'repair detail',
    'CS-2025-003': 'repair detail',
    'JS-2025-031': 'repair detail',
    'JS-2025-032': 'repair detail',
    'JS-2025-033': 'repair detail',
    'JS-2025-034': 'repair detail',
    'WO-2025-014': 'repair detail',
    'WO-2025-015': 'repair detail',
    'MT-P-2025-011': 'maintenance detail',
    'MT-P-2025-012': 'maintenance detail',
  };

  // ========= Sample Data (replace with API) =========
  final List<WorkOrder> _all = [
    // Concern Slip ----------------------------
    // Concern Slip (Default)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'CS-2025-001',
      date: 'Aug 22',
      status: 'Pending',
      department: 'Plumbing',
      requestType: 'Concern Slip',
      unit: 'A 1001',
      priority: 'High',
    ),
    // Concern Slip (Assigned)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'CS-2025-001',
      date: 'Aug 22',
      status: 'Assigned',
      department: 'Plumbing',
      requestType: 'Concern Slip',
      unit: 'A 1001',
      priority: 'High',
      assignedTo: 'Juan Dela Cruz',
      assignedDepartment: 'Plumbing',
      assignedPhotoUrl: 'assets/images/avatar.png',
    ),
    // Concern Slip (assessed)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'CS-2025-003',
      date: 'Aug 23',
      status: 'Done',
      department: 'Plumbing',
      requestType: 'Concern Slip',
      unit: 'A 1001',
      priority: 'High',
      hasInitialAssessment: true,
      initialAssigneeName: 'Juan Dela Cruz',
      initialAssigneeDepartment: 'Plumbing',
    ),
    // Job Service --------------------------------
    // Job Service (Default)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-031',
      date: 'Aug 22',
      status: 'Pending',
      department: 'Plumbing',
      requestType: 'Job Service',
      unit: 'A 1001',
      priority: 'High',
    ),
    // Job Service (Assigned)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-032',
      date: 'Aug 22',
      status: 'Assigned',
      department: 'Plumbing',
      requestType: 'Job Service',
      unit: 'A 1001',
      priority: 'High',
      assignedTo: 'Juan Dela Cruz',
      assignedDepartment: 'Plumbing',
      assignedPhotoUrl: 'assets/images/avatar.png',
    ),
    // Job Service (Assessed)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-033',
      date: 'Aug 23',
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
    // Job Service (On Hold)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'JS-2025-034',
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
    // Work Order ----------------------------
    // Work Order Permit (Pending)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'WO-2025-014',
      date: 'Aug 20',
      status: 'Pending',
      department: 'Plumbing',
      requestType: 'Work Order',
      unit: 'A 1001',
      priority: 'High',
    ),
    // Work Order Permit (Approved)
    WorkOrder(
      title: 'Leaking faucet',
      requestId: 'WO-2025-015',
      date: 'Aug 20',
      status: 'Approved',
      department: 'Plumbing',
      requestType: 'Work Order',
      unit: 'A 1001',
      priority: 'High',
    ),
    // Maintenance Task -------------------------
    // Maintenance Task (Scheduled)
    WorkOrder(
      title: 'Quarterly Pipe Inspection',
      requestId: 'MT-P-2025-011',
      date: 'Aug 30',
      status: 'Scheduled',
      department: 'Plumbing',
      unit: 'Tower A - 5th Floor',
      priority: 'High',
      assignedTo: 'Juan Dela Cruz',
      assignedDepartment: 'Plumbing',
      assignedPhotoUrl: 'assets/images/avatar.png',
    ),
    // Maintenance Task (Assessed)
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
    ),
  ];

  // Allows you to override the displayed status per ID (e.g., local transitions).
  final Map<String, String> _statusOverrideById = {};
  String _statusOf(WorkOrder w) => _statusOverrideById[w.requestId] ?? w.status;

  // Pull-to-refresh stub (replace with API call)
  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {});
  }

  // ========= Bottom Nav =========
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
    if (index != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  // ========= Helpers: task type / routing =========
  bool _isMaintenanceTask(WorkOrder w) {
    final id = (w.requestId).toUpperCase();
    final tag = (_taskTypeById[w.requestId] ?? '').toLowerCase();
    // Treat anything starting with MT- as maintenance OR anything tagged with 'maintenance'
    return id.startsWith('MT-') || tag.contains('maintenance');
  }

  bool _isRepairTask(WorkOrder w) => !_isMaintenanceTask(w);

  bool _tabMatches(WorkOrder w) {
    final tab = _selectedTabLabel.toLowerCase();
    if (tab == 'repair') return _isRepairTask(w);
    return _isMaintenanceTask(w);
  }

  /// Map a WorkOrder to the label that WorkOrderDetailsPage expects.
  /// (THIS MUST ONLY RETURN LABELS SUPPORTED BY THE DETAILS PAGE)
  String _detailsLabelFor(WorkOrder w) {
    final type   = (w.requestType ?? '').toLowerCase().trim();
    final status = _statusOf(w).toLowerCase().trim();

    bool inSet(Set<String> s) => s.contains(status);

    const doneLike = {
      'done', 'assessed', 'closed', 'approved', 'completed', 'finished'
    };
    const assignedLike = {
      'assigned', 'in progress', 'on hold', 'scheduled'
    };
    const pendingLike = {'pending'};

    // ── Maintenance Task (you map MT-* to Job Service screens) ────────────────
    if (_isMaintenanceTask(w)) {
      if (inSet(doneLike)) return 'job service assessed';
      if (inSet(assignedLike)) return 'job service assigned';
      if (inSet(pendingLike)) return 'job service';
      // Fallback for unknown MT status
      return 'job service assigned';
    }

    // ── Work Order (permit) ───────────────────────────────────────────────────
    if (type.contains('work order')) {
      return 'work order';
    }

    // ── Job Service: three-branch mapping ─────────────────────────────────────
    if (type.contains('job service')) {
      if (inSet(doneLike)) return 'job service assessed';
      if (inSet(assignedLike)) return 'job service assigned';
      if (inSet(pendingLike)) return 'job service';
      // Fallback
      return 'job service assigned';
    }

    // ── Concern Slip: three-branch mapping ────────────────────────────────────
    if (type.contains('concern slip')) {
      if (inSet(doneLike)) return 'concern slip assessed';
      if (inSet(assignedLike)) return 'concern slip assigned';
      // default pending → plain "concern slip"
      return 'concern slip';
    }

    // ── Fallback: safe operational view ───────────────────────────────────────
    return 'job service assigned';
  }

  String _selectedLabelFor(WorkOrder w) {
    // Keep backward compatibility with mapping but DO NOT pass unsupported labels.
    // We resolve to the safe routing label above.
    final mapped = _taskTypeById[w.requestId];
    final fallback = _detailsLabelFor(w);
    if (mapped == null || mapped.trim().isEmpty) return fallback;

    // If someone mapped to "maintenance detail", we still return the safe label to the details page.
    if (mapped.toLowerCase().contains('maintenance')) return fallback;

    return fallback; // prefer deterministic routing
  }

  // ========= Dynamic options for status =========
  /// Status options depend on what's visible after applying tab + search + classification.
  List<String> get _statusOptions {
    final base = _all
        .where(_tabMatches)
        .where(_searchMatches)
        .where(_classificationMatches);
    final set = <String>{};
    for (final w in base) {
      final s = _statusOf(w).trim();
      if (s.isNotEmpty) set.add(s);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  // ========= Filters =========
  bool _searchMatches(WorkOrder w) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [w.title, w.requestId, w.department ?? '', w.unit ?? '', w.status]
        .any((s) => s.toLowerCase().contains(q));
  }

  /// Classification is simply the work order's department (normalized).
  String _classificationOf(WorkOrder w) {
    final dept = (w.department ?? '').trim();
    if (dept.isEmpty) return 'Maintenance'; // sensible default bucket
    switch (dept.toLowerCase()) {
      case 'plumbing':
        return 'Plumbing';
      case 'carpentry':
        return 'Carpentry';
      case 'electrical':
        return 'Electrical';
      case 'masonry':
        return 'Masonry';
      case 'maintenance':
        return 'Maintenance';
      default:
        return dept; // will still appear if you add to dropdown
    }
  }

  bool _classificationMatches(WorkOrder w) {
    if (_selectedClassification == 'All') return true;
    return _classificationOf(w) == _selectedClassification;
  }

  bool _statusMatches(WorkOrder w) {
    if (_selectedStatus == 'All') return true;
    return _statusOf(w).toLowerCase() == _selectedStatus.toLowerCase();
  }

  // Final filtered set used by UI list
  List<WorkOrder> get _filtered => _all
      .where(_tabMatches)
      .where(_searchMatches)
      .where(_classificationMatches)
      .where(_statusMatches)
      .toList();

  // Sort by date (newest first) using your UiDateParser
  List<WorkOrder> get _filteredSorted {
    final list = List<WorkOrder>.from(_filtered);
    list.sort((a, b) => UiDateParser.parse(b.date).compareTo(UiDateParser.parse(a.date)));
    return list;
  }

  // Tabs: counts reflect the current search (not classification/status).
  // If you want tabs to honor classification/status too, apply those filters here as well.
  List<TabItem> get _tabs {
    final visible = _all.where(_searchMatches).toList();
    return [
      TabItem(label: 'Repair',      count: visible.where(_isRepairTask).length),
      TabItem(label: 'Maintenance', count: visible.where(_isMaintenanceTask).length),
    ];
  }

  // ---- tenant-style list date (e.g., "Aug 22") ----
  String _fmtListDate(String s) {
    // Try UiDateParser first (your helper), then fall back to DateTime.tryParse, then leave as-is.
    try {
      final parsed = UiDateParser.parse(s); // returns DateTime from "Aug 22" etc.
      return DateFormat('MMM d').format(parsed);
    } catch (_) {
      final dt = DateTime.tryParse(s);
      if (dt != null) return DateFormat('MMM d').format(dt);
      // If the input is already like "Aug 22", just normalize spaces
      final m = RegExp(r'^\s*[A-Za-z]{3,}\s+\d{1,2}\s*$');
      if (m.hasMatch(s)) return s.trim();
      return s;
    }
  }

  // ========= Card builder =========
  Widget _buildCard(WorkOrder w) {
    final dept = w.department ?? 'Maintenance';
    final prio = w.priority ?? 'Medium';

    if (_isMaintenanceTask(w)) {
      // Maintenance card → details label mapped to a supported case via _detailsLabelFor()
      final routeLabel = _detailsLabelFor(w);
      return MaintenanceCard(
        title: w.title,
        requestId: w.requestId,
        unit: w.unit ?? '-',
        date: _fmtListDate(w.date),     // <<< tenant-style date
        status: _statusOf(w),
        priority: prio,
        department: dept,
        avatarUrl: w.avatarUrl,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkOrderDetailsPage(
                selectedTabLabel: routeLabel, // e.g., 'job service assigned'
              ),
            ),
          );
        },
        onChatTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
      );
    }

    // Repair-type cards (Concern Slip, Job Service, Work Order)
    final routeLabel = _detailsLabelFor(w);
    return RepairCard(
      title: w.title,
      requestId: w.requestId,
      reqDate: _fmtListDate(w.date),     // <<< tenant-style date
      statusTag: _statusOf(w),           // use effective status
      unit: w.unit,
      priority: w.priority ?? 'Medium',
      departmentTag: w.department,
      hasInitialAssessment: w.hasInitialAssessment,
      initialAssigneeName: w.initialAssigneeName,
      initialAssigneeDepartment: w.initialAssigneeDepartment,
      hasCompletionAssessment: w.hasCompletionAssessment,
      completionAssigneeName: w.completionAssigneeName,
      completionAssigneeDepartment: w.completionAssigneeDepartment,
      assignedTo: w.assignedTo,
      assignedDepartment: w.assignedDepartment,
      // If your RepairCard expects `avatarUrl`, pass assignedPhotoUrl here:
      avatarUrl: w.assignedPhotoUrl,
      requestType: w.requestType,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkOrderDetailsPage(
              selectedTabLabel: routeLabel, // only supported strings
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

  // ========= New Maintenance FAB flow =========
  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Create Maintenance',
        message: 'Would you like to create a new maintenance?',
        primaryText: 'Yes',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MaintenanceForm(requestType: 'Basic Information'),
            ),
          );
        },
        secondaryText: 'Cancel',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {})); // live search
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== TOP BAR: Search + Classification(Department) + Status ==========
                    // NOTE: SearchAndFilterBar should render the “Classification” control
                    //       when these props are provided.
                    SearchAndFilterBar(
                      searchController: _searchController,

                      // Classification == Department
                      selectedClassification: _selectedClassification,
                      classifications: _classificationOptions,
                      onClassificationChanged: (v) =>
                          setState(() => _selectedClassification = (v ?? 'All')),

                      // Status filter (chips / dropdown)
                      selectedStatus: _selectedStatus,
                      statuses: _statusOptions,
                      onStatusChanged: (status) {
                        setState(() {
                          final v = (status ?? '').trim();
                          _selectedStatus = v.isEmpty ? 'All' : v;
                        });
                      },

                      // Live search
                      onSearchChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Tabs: Repair / Maintenance
                    StatusTabSelector(
                      tabs: _tabs,
                      selectedLabel: _selectedTabLabel,
                      onTabSelected: (label) => setState(() => _selectedTabLabel = label),
                    ),
                    const SizedBox(height: 20),

                    // Header count
                    Row(
                      children: [
                        const Text(
                          'Recent Requests',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${items.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475467),
                              fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // List of items
                    Expanded(
                      child: items.isEmpty
                          ? const EmptyState()
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _buildCard(items[i]),
                            ),
                    ),
                  ],
                ),
              ),

              // FAB only for Maintenance tab
              if (_selectedTabLabel.toLowerCase() == 'maintenance')
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: AddButton(onPressed: () => _showRequestDialog(context)),
                ),
            ],
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
