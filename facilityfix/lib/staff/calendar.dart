import 'package:facilityfix/admin/chat.dart';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/notification.dart';
import 'package:facilityfix/staff/view_details/workorder.dart'; // WorkOrderDetails
import 'package:facilityfix/staff/workorder.dart'; // WorkOrderPage
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/calendar.dart'; // CalendarPane
import 'package:facilityfix/widgets/helper_models.dart'; // WorkOrder, UiDateParser

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
      setState(() => _selectedIndex = index);
    }
  }

  // ====== Demo data with MT (maintenance) and CS/JS (repairs) ======
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
    ),
  ];

  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  Map<DateTime, List<WorkOrder>> _groupByDayForMonth(
    List<WorkOrder> list,
    DateTime month,
  ) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    final map = <DateTime, List<WorkOrder>>{};
    for (final w in list) {
      final dt = UiDateParser.parse(w.date);
      if (dt.isBefore(first) || dt.isAfter(last)) continue;

      final key = DateTime(dt.year, dt.month, dt.day);
      map.putIfAbsent(key, () => <WorkOrder>[]).add(w);
    }
    return map;
  }

  // === Label mapping used by WorkOrderDetails (kept same as your logic) ===
  String _routeLabelFor(WorkOrder w) {
    final id = (w.requestId).toUpperCase();
    final rt = (w.requestType ?? '').toLowerCase().trim();
    final s  = (w.status).toLowerCase().trim();

    if (rt == 'concern slip' || id.startsWith('CS')) {
      return (s == 'assigned' || s == 'on hold')
          ? 'concern slip assigned'
          : 'concern slip assessed';
    }
    if (rt == 'job service' || id.startsWith('JS')) {
      return (s == 'assigned' || s == 'on hold' || s == 'scheduled')
          ? 'job service assigned'
          : 'job service assessed';
    }
    if (rt.contains('maintenance') || id.startsWith('MT')) {
      return (s == 'scheduled' || s == 'assigned' || s == 'in progress')
          ? 'maintenance task scheduled'
          : 'maintenance task assessed';
    }
    return s == 'done' ? 'concern slip assessed' : 'concern slip assigned';
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
                  initialSelected: DateTime.now(),
                  onMonthChanged: (m) => setState(() => _currentMonth = m),
                  onDaySelected: (d) => debugPrint('Selected day: $d'),

                  // === Your required callbacks applied to the task cards ===
                  onTaskTap: (w) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkOrderDetails(
                          selectedTabLabel: _routeLabelFor(w),
                          workOrder: null,
                        ),
                      ),
                    );
                  },
                  onTaskChatTap: (w) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    );
                  },
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

