import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/profile.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/analytics.dart';
import 'package:facilityfix/widgets/cards.dart';
import 'package:facilityfix/widgets/helper_models.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;

  // Fake admin display
  static const String _userName = 'Admin';
  static const String _roleLabel = 'Property Management';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Home',
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.png'),
            radius: 16,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Hello, ',
                      style: const TextStyle(
                        color: Color(0xFF1B1D21),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: _userName,
                          style: const TextStyle(
                            color: Color(0xFF101828),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _roleLabel,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick status cards
              Row(
                children: const [
                  Expanded(
                    child: StatusCard(
                      title: 'Repair\tRequest',
                      count: '1',
                      icon: Icons.settings_outlined,
                      iconColor: Color(0xFF005CE8),
                      backgroundColor: Color(0xFFEFF4FF),
                      borderColor: Color(0xFF005CE8),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatusCard(
                      title: 'Maintenance\tDue',
                      count: '0',
                      icon: Icons.check_circle_rounded,
                      iconColor: Color(0xFF24D164),
                      backgroundColor: Color(0xFFF0FDF4),
                      borderColor: Color(0xFF24D164),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Repair Tasks
              SectionHeader(
                title: 'Recent Repair Request',
                actionLabel: 'View all',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkOrderPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  RepairCard(
                    title: 'Leaking faucet',
                    requestId: 'CS-2025-031',
                    reqDate: 'Aug 23',
                    statusTag: 'Done',
                    departmentTag: 'Plumbing',
                    requestType: 'Concern Slip',
                    unit: 'A 1001',
                    priority: 'High',

                    // Avatar
                    hasCompletionAssessment: true,
                    completionAssigneeName: 'Juan Dela Cruz',
                    completionAssigneeDepartment: 'Plumbing',
                    completionAssigneePhotoUrl: 'assets/images/avatar.png',
                    onTap: () {},
                    onChatTap: () {},
                  ),
                  const SizedBox(height: 12),
                  RepairCard(
                    title: 'Leaking faucet',
                    requestId: 'JS-2025-031',
                    reqDate: 'Aug 23',
                    statusTag: 'Done',
                    departmentTag: 'Plumbing',
                    requestType: 'Job Service',
                    unit: 'A 1001',
                    priority: 'High',

                    // Avatar
                    hasCompletionAssessment: true,
                    completionAssigneeName: 'Juan Dela Cruz',
                    completionAssigneeDepartment: 'Plumbing',
                    // completionAssigneePhotoUrl: 'assets/images/avatar.png',
                    onTap: () {},
                    onChatTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Maintenance Tasks
              SectionHeader(
                title: 'Recent Maintenance',
                actionLabel: 'View all',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkOrderPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  MaintenanceCard(
                    title: 'Quarterly Pipe Inspection',
                    requestId: 'MT-P-2025-011',
                    date: 'Aug 28',
                    status: 'In Progress',
                    department: 'Plumbing',
                    unit: 'Tower A - 5th Floor',
                    priority: 'High',

                    // Avatar
                    hasInitialAssessment: true,
                    initialAssigneeName: 'Juan Dela Cruz',
                    initialAssigneeDepartment: 'Plumbing',
                    initialAssigneePhotoUrl: 'assets/images/avatar.png',

                    onTap: () {},
                    onChatTap: () {},
                  ),
                  const SizedBox(height: 12),
                  MaintenanceCard(
                    title: 'Quarterly Pipe Inspection',
                    requestId: 'MT-P-2025-011',
                    date: 'Aug 28',
                    status: 'Done',
                    department: 'Plumbing',
                    unit: 'Tower A - 5th Floor',
                    priority: 'High',

                    // Avatar
                    hasInitialAssessment: true,
                    initialAssigneeName: 'Juan Dela Cruz',
                    initialAssigneeDepartment: 'Plumbing',
                    initialAssigneePhotoUrl: 'assets/images/avatar.png',

                    onTap: () {},
                    onChatTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Announcements
              SectionHeader(
                title: 'Latest Announcement',
                actionLabel: 'View all',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnnouncementPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              AnnouncementCard(
                title: 'Utility Interruption',
                datePosted: '3 hours ago',
                details:
                    'Temporary shutdown in pipelines for maintenance cleaning.',
                classification: 'utility interruption',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Analytics
              const _SectionHeader(title: 'Analytics'),
              const SizedBox(height: 12),
              WeeklyAnalyticsChartCard(
                xLabels: const [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                ],
                repairCounts: const [4, 6, 3, 10, 2, 5, 1],
                maintenanceCounts: const [2, 1, 6, 7, 3, 2, 8],
                highlightIndex: DateTime.now().weekday % 7, // optional
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

/// Simple “section header + View all” row to match tenant side
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel});
  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
