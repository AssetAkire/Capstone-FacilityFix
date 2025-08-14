import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class ViewDetailsPage extends StatefulWidget {
  final String selectedTabLabel;

  const ViewDetailsPage({
    super.key,
    required this.selectedTabLabel,
  });

  @override
  State<ViewDetailsPage> createState() => _ViewDetailsPageState();
}

class _ViewDetailsPageState extends State<ViewDetailsPage> {
  int _selectedIndex = 1;

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

    if (index != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  Widget _buildTabContent() {
    switch (widget.selectedTabLabel.toLowerCase()) {
      case 'repair detail':
        _selectedIndex = 1;
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "REQ-2025-00123",
          classification: "Plumbing",
          date: "August 2, 2025",
          requestType: "Repair",
          unit: "A 1001",
          description:
              "Hi, I’d like to report a clogged drainage issue in the bathroom of my unit. The water is draining very slowly, and it’s starting to back up onto the floor. I’ve already tried using a plunger but it didn’t help. It’s been like this since yesterday and is getting worse. Please send someone to check and fix it as soon as possible. Thank you!",
          priority: "High",
          assigneeName: "Juan Dela Cruz",
          assigneeRole: "Plumber",
          attachments: [
            "https://via.placeholder.com/140x80.png?text=Leak+1",
            "https://via.placeholder.com/140x80.png?text=Leak+2",
          ],
        );

      case 'announcement detail':
        _selectedIndex = 2;
        return AnnouncementDetailScreen(
          title: 'Water Interruption Notice',
          datePosted: 'August 6, 2025',
          classification: 'Utility Interruption',
          description: 'Water supply will be interrupted due to mainline repair.',
          locationAffected: 'Building A & B',
          scheduleStart: 'August 7, 2025 - 8:00 AM',
          scheduleEnd: 'August 7, 2025 - 5:00 PM',
          contactNumber: '0917 123 4567',
          contactEmail: 'support@condoadmin.ph',
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
          child: _buildTabContent(),
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
