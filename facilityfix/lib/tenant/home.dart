import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/notification.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
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

  // Demo user display (replace with real user data)
  static const String _userName = 'Erika';
  static const String _unitLabel = 'Building A • Unit 1001';

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.person),
  ];

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const ProfilePage(),
    ];
    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: CustomAppBar(
        title: 'Home',
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting (avatar removed)
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
                      _unitLabel,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Cards
                Row(
                  children: const [
                    Expanded(
                      child: StatusCard(
                        title: 'Active Request',
                        count: '1',
                        icon: Icons.settings_outlined,
                        iconColor: Color(0xFFF79009),
                        backgroundColor: Color(0xFFFFFAEB),
                        borderColor: Color(0xFFF79009),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatusCard(
                        title: 'Done',
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

                // Recent Requests
                SectionHeader(
                  title: 'Recent Requests',
                  actionLabel: 'View all',
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkOrderPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
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
                      completionAssigneePhotoUrl: 'assets/images/avatar.png',
                      onTap: () {},
                      onChatTap: () {}, 
                    ),
                    const SizedBox(height: 12),
                    RepairCard(
                      title: 'Leaking faucet',
                      requestId: 'CS-2025-005',
                      reqDate: 'Aug 22',
                      statusTag: 'Pending',
                      departmentTag: 'Plumbing',
                      requestType: 'Concern Slip',
                      unit: 'A 1001',
                      priority: null,
                      onTap: () {},
                      onChatTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Latest Announcement
                SectionHeader(
                  title: 'Latest Announcement',
                  actionLabel: 'View all',
                  onActionTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AnnouncementPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                AnnouncementCard(
                  title: 'Utility Interruption',
                  datePosted: '3 hours ago',
                  details: 'Temporary shutdown in pipelines for maintenance cleaning.',
                  classification: 'utility interruption', 
                  onTap: () {
                    // navigate to details if needed
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
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

