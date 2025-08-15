import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/view_details.dart';

class FullDetails extends StatefulWidget {
  final String selectedTabLabel; 

  const FullDetails({
    super.key,
    required this.selectedTabLabel,
  });

  @override
  State<FullDetails> createState() => _FullDetailsState();
}

class _FullDetailsState extends State<FullDetails> {
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

  Widget _buildTabContent() {
    switch (widget.selectedTabLabel.toLowerCase()) {
      case 'repair detail':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "REQ-2025-00123",
          classification: "Plumbing",
          date: "August 2, 2025",
          requestType: "Repair",
          unit: "A 1001",
          description:
              "Hi, I’d like to report a clogged drainage issue in the bathroom...",
          priority: "High",
          assigneeName: "Juan Dela Cruz",
          assigneeRole: "Plumber",
          assessment:
              'Inspecting all ceilings lights and emergency lighting. Check for flickering, burnt bulbs, and exposed wiring.',
          recommendation: 'Clear clogged drainage pipe.',
          attachments: [
            "https://via.placeholder.com/140x80.png?text=Leak+1",
            "https://via.placeholder.com/140x80.png?text=Leak+2",
          ],
        );

      case 'maintenance detail':
        return MaintenanceDetailsScreen(
          title: 'Light Inspection',
          maintenanceId: 'PM-GEN-LIGHT-001',
          status: 'In Progress',
          description:
              'Inspecting all ceilings lights and emergency lighting. Check for flickering, burnt bulbs, and exposed wiring.',
          priority: 'High',
          location: 'Basement',
          dateCreated: 'June 15, 2025',
          recurrence: 'Every 1 month',
          startDate: 'July 30, 2025',
          nextDate: 'August 30, 2025',
          checklist: [
            'Visually inspect light conditions',
            'Test switch function',
            'Check emergency lights',
            'Replace burnt-out bulbs',
            'Log condition and report anomalies'
          ],
          assessment:
              'Inspecting all ceilings lights and emergency lighting. Check for flickering, burnt bulbs, and exposed wiring.',
          recommendation: 'Clear clogged drainage pipe.',
          attachments: [
            'https://placehold.co/147x80',
            'https://placehold.co/147x80'
          ],
          adminNote:
              'Emergency lights in basement often have moisture issues - check battery backups.',
        );
      default:
        return const Center(child: Text("No requests found."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: BackButton(),
            ),
            Text('View Details'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildTabContent(), // Display selected tab content
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
