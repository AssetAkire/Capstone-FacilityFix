import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class MaintenanceDetails extends StatefulWidget {
  const  MaintenanceDetails({super.key});

  @override
  State<MaintenanceDetails> createState() => _MaintenanceDetailsState();
}

class _MaintenanceDetailsState extends State<MaintenanceDetails> {
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

    if (index != 1) {
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
              MaintenanceDetailsScreen(
                title: 'Light Inspection',
                maintenanceId: 'PM-GEN-LIGHT-001',
                status: 'In Progress',
                description: 'Inspecting all ceilings lights and emergency lighting. Check for flickering, burnt bulbs, and exposed wiring.',
                priority: 'High',
                location: 'Basement',
                dateCreated: 'June 15, 2025',
                recurrence: 'Every 1 a month',
                startDate: 'July 30, 2025',
                nextDate: 'August 30, 2025',
                checklist: ['Visually inspect light conditions', 'Tech Switch Function', 'Check emergency Lights', 'Replace burn-out burns', 'Log condition and report anomalies'],
                attachments: ['https://placehold.co/147x80','https://placehold.co/147x80'], 
                adminNote: 'Emergency lights in basement often have moisture issues - check battery backups.', 
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
