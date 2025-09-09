import 'package:facilityfix/admin/notification.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/calendar.dart'; // CalendarPane
import 'package:facilityfix/widgets/helper_models.dart'; // WorkOrder, UiDateParser
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/view_details/workorder_details.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 3;

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
    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

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

  /// Keep the calendar's current month in state
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    // ⬇️ Always open at today's month
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  // ========= Status helpers for de-dupe preference & routing =========
  int _statusRank(String s) {
    final x = s.toLowerCase().trim();
    if (x == 'pending') return 1;
    if (x == 'assigned' || x == 'in progress') return 2;
    if (x == 'on hold' || x == 'scheduled') return 3;
    if (x == 'approved') return 4;
    if (x == 'done' || x == 'assessed' || x == 'closed' || x == 'completed' || x == 'finished') return 5;
    return 0; // unknown
  }

  List<WorkOrder> _dedupeByRequestIdPreferHigherStatus(List<WorkOrder> list) {
    final byId = <String, WorkOrder>{};
    for (final w in list) {
      final cur = byId[w.requestId];
      if (cur == null) {
        byId[w.requestId] = w;
      } else {
        if (_statusRank(w.status) >= _statusRank(cur.status)) {
          byId[w.requestId] = w; // keep the “stronger” status
        }
      }
    }
    return byId.values.toList();
  }

  bool _isMaintenanceTask(WorkOrder w) {
    final id = (w.requestId).toUpperCase();
    // Treat anything starting with PM- or MT- as maintenance (calendar context).
    return id.startsWith('PM') || id.startsWith('MT');
  }

  /// 3-branch label mapper aligned with WorkOrderDetailsPage supported labels.
  /// Job Service: pending → 'job service', assigned/in progress/on hold/scheduled → 'job service assigned',
  /// done/assessed/closed/approved → 'job service assessed'
  /// Concern Slip mirrors that 3-branch style.
  /// Maintenance (MT/PM) is mapped to Job Service branches.
  String _detailsLabelFor(WorkOrder w) {
    final type = (w.requestType ?? '').toLowerCase().trim();
    final status = (w.status).toLowerCase().trim();

    bool inSet(Set<String> s) => s.contains(status);

    const doneLike = {
      'done', 'assessed', 'closed', 'approved', 'completed', 'finished'
    };
    const assignedLike = {
      'assigned', 'in progress', 'on hold', 'scheduled'
    };
    const pendingLike = {'pending'};

    // Maintenance task → map to Job Service screens (3-branch)
    if (_isMaintenanceTask(w)) {
      if (inSet(doneLike)) return 'job service assessed';
      if (inSet(assignedLike)) return 'job service assigned';
      if (inSet(pendingLike)) return 'job service';
      return 'job service assigned';
    }

    // Work Order (permit)
    if (type.contains('work order')) {
      return 'work order';
    }

    // Job Service → 3-branch
    if (type.contains('job service')) {
      if (inSet(doneLike)) return 'job service assessed';
      if (inSet(assignedLike)) return 'job service assigned';
      if (inSet(pendingLike)) return 'job service';
      return 'job service assigned';
    }

    // Concern Slip → 3-branch
    if (type.contains('concern slip')) {
      if (inSet(doneLike)) return 'concern slip assessed';
      if (inSet(assignedLike)) return 'concern slip assigned';
      // default pending
      return 'concern slip';
    }

    // Fallback
    return 'job service assigned';
  }

  /// Group work orders into a Map<DateTime, List<WorkOrder>> **for a given month**,
  /// and de-duplicate per day by requestId to avoid duplicate widget keys in the calendar list.
  Map<DateTime, List<WorkOrder>> _groupByDayForMonth(
    List<WorkOrder> list,
    DateTime month,
  ) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    final tmp = <DateTime, List<WorkOrder>>{};
    for (final w in list) {
      final dt = UiDateParser.parse(w.date);
      if (dt.isBefore(first) || dt.isAfter(last)) continue;

      final key = DateTime(dt.year, dt.month, dt.day);
      tmp.putIfAbsent(key, () => <WorkOrder>[]).add(w);
    }

    // ✅ De-dup per day by requestId, keep “stronger” status to represent that task
    final deduped = <DateTime, List<WorkOrder>>{};
    for (final key in tmp.keys) {
      deduped[key] = _dedupeByRequestIdPreferHigherStatus(tmp[key]!);
    }
    return deduped;
  }

  void _openDetailsForTask(WorkOrder t) {
    final label = _detailsLabelFor(t); // reuse our 3-branch logic
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkOrderDetailsPage(selectedTabLabel: label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksByDate = _groupByDayForMonth(_all, _currentMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Calendar',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: CalendarPane(
                  month: _currentMonth,
                  tasksByDate: tasksByDate,
                  // ⬇️ Preselect *today* if we're on the current month
                  initialSelected: DateTime.now(),
                  onMonthChanged: (m) {
                    // Update the displayed month when user taps the arrows
                    setState(() => _currentMonth = m);
                  },
                  onDaySelected: (d) => debugPrint('Selected day: $d'),
                  onTaskTap: _openDetailsForTask,
                  onTaskChatTap: (t) => debugPrint('Chat tapped: ${t.requestId}'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
