import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class RepairDetails extends StatefulWidget {
  const RepairDetails({super.key});

  @override
  State<RepairDetails> createState() => _RepairDetailsState();
}

class _RepairDetailsState extends State<RepairDetails> {
  int _selectedIndex = 1;

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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: const BackButton(),
            ),
            Text('View Details'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              RepairDetailsScreen(
                title: "Leaking Faucet",
                requestId: "REQ-2025-00123",
                classification: "Plumbing",
                date: "August 2, 2025",
                requestType: "Repair",
                unit: "A 1001",
                description: "Hi, I’d like to report a clogged drainage issue in the bathroom of my unit. The water is draining very slowly, and it’s starting to back up onto the floor. I’ve already tried using a plunger but it didn’t help. It’s been like this since yesterday and is getting worse. Please send someone to check and fix it as soon as possible. Thank you!",
                priority: "High",
                assigneeName: "Juan Dela Cruz",
                assigneeRole: "Plumber",
                attachments: [
                  "https://via.placeholder.com/140x80.png?text=Leak+1",
                  "https://via.placeholder.com/140x80.png?text=Leak+2",
                ],
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
