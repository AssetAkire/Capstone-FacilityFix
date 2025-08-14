import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/profile.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/admin/view_details/announcement_details.dart';
import 'package:facilityfix/widgets/announcement_cards.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/statcard.dart';
import 'package:facilityfix/widgets/workOrder_cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;

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

    if (index != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: IconButton(
        icon: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile.jpg'), // Replace with your profile image asset or use Icon()
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Cards
              Row(
                children: const [
                  Expanded(
                    child: StatusCard(
                      title: 'Pending Request',
                      count: '1',
                      icon: Icons.settings,
                      iconColor: Color(0xFF005CE8),
                      backgroundColor: Color(0xFFFF0F6FF),
                      borderColor: Color(0xFF005CE8),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatusCard(
                      title: 'Maintenance Due',
                      count: '0',
                      icon: Icons.check_circle_rounded,
                      iconColor: Color(0xFF24D164),
                      backgroundColor: Color(0xFFF0FDF4),
                      borderColor: Color(0xFF24D164),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Recent Repair Task Section
              const Text('Recent Repair Task', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              RequestRepairCard(
                title: "Leaking Faucet",
                requestId: "REQ-2025-009",
                date: "27 Sept",
                classification: "In Progress",
                onTap: () {
                  // Navigate to request details
                },
                onChatTap: () {
                  // Open chat
                },
              ),
              const SizedBox(height: 18),

              // Maintenance Task Section
              const Text('Latest Announcement', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              
              AnnouncementCard(
                title: 'Utility Interruption',
                datePosted: '3 hours ago',
                details: 'Temporary shutdown in pipelines for maintenance cleaning.',
                classification: 'Utility Interruption',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementDetails()),
                    );
                  }
              ),
              const SizedBox(height: 18),
              const Text('Analytics', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),

      // Bottom NavBar
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
