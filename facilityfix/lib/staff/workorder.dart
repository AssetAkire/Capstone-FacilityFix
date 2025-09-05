import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/chat.dart';
import 'package:facilityfix/staff/notification.dart';
import 'package:facilityfix/staff/view_details/details_maintenanceForm.dart';
import 'package:facilityfix/staff/view_details/details_repairForm.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/widgets/workorder_cards.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});
  

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  String selectedTabLabel = "Repair Task";
  String _selectedClassification = "Repair Task";
  final TextEditingController _searchController = TextEditingController();
  

  final tabs = [
    TabItem(label: 'Repair Task', count: 5),
    TabItem(label: 'Maintenance Task', count: 2),
  ];

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

  Widget _buildTabContent() {
    switch (selectedTabLabel.toLowerCase()) {
      case 'repair task':
        return ListView(
          children: [
            RepairTaskCard(
              title: 'Fix Sink',
              requestId: 'REQ-001',
              date: '26 Sept',
              classification: 'In Progress',
              unit: 'Unit 203',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RepairDetails()),
                );
              },
            ),
          ],
        );

      case 'maintenance task':
        return ListView(
          children: [
            MaintenanceTaskCard(
              title: 'Light Inspection',
              requestId: 'PM-GEN-LIGHT-001',
              unit: 'Lobby',
              date: '30 July', 
              classification: 'High',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MaintenanceDetails()),
                );
              },
              onChatTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                );
              },
            ),
          ],
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
        leading: const Text('Work Order Management'),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchAndFilterBar(
                    searchController: _searchController,
                    selectedClassification: _selectedClassification,
                    classifications: ['All', 'Electrical', 'Plumbing', 'Carpentry'],
                    onSearchChanged: (query) {},
                    onFilterChanged: (classification) {
                      setState(() {
                        _selectedClassification = classification;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  StatusTabSelector(
                    tabs: tabs,
                    selectedLabel: selectedTabLabel,
                    onTabSelected: (label) {
                      setState(() {
                        selectedTabLabel = label;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Recent Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: 1,
        onTap: _onTabTapped,
      ),
    );
  }
}
