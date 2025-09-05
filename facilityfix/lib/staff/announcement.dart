import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/notification.dart';
import 'package:facilityfix/staff/view_details/announcement_details.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/announcement_cards.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:flutter/material.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<AnnouncementPage> {
  int _selectedIndex = 2;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: const Text('Announcement'),
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
          children: [
            
            // Latest Announcement Section
            AnnouncementCard(
              title: 'Utility Interruption',
              datePosted: '3 hours ago',
              details: 'Temporary shutdown in pipelines for maintenance cleaning.',
              classification: 'utility', 
              onTap: () {  
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementDetails(),
                  ),
                );
              },
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
