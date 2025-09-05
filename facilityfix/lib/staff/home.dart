import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/notification.dart' show NotificationPage;
import 'package:facilityfix/staff/profile.dart';
import 'package:facilityfix/staff/workorder.dart';
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
      appBar: CustomAppBar(
        leading: IconButton(
        icon: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile.jpg'), 
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
                      title: 'Active Request',
                      count: '1',
                      icon: Icons.settings,
                      iconColor: Color(0xFFF79009),
                      backgroundColor: Color(0xFFFFFAEB),
                      borderColor: Color(0xFFF79009),
                    ),
                  ),
                  SizedBox(width: 10),
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
              const SizedBox(height: 18),

              // Recent Request Section
              const Text('Recent Request', style: TextStyle(fontSize: 16)),
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

              // Latest Announcement Section
              const Text('Latest Announcement', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              AnnouncementCard(
                title: 'Utility Interruption',
                datePosted: '3 hours ago',
                details: 'Temporary shutdown in pipelines for maintenance cleaning.',
                classification: 'utility',
                onTap: () {
                  // Navigate to announcement details
                }, 
              ),
              const SizedBox(height: 24),
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
