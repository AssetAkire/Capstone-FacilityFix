import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/chat.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/forms/maintenance_task.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/view_details/maintenance_details.dart';
import 'package:facilityfix/admin/view_details/repair_details.dart';
import 'package:facilityfix/widgets/pop_up.dart';
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
  String selectedTabLabel = "Repair";
  String _selectedClassification = "Repair";
  final TextEditingController _searchController = TextEditingController();
  

  final tabs = [
    TabItem(label: 'Repair', count: 5),
    TabItem(label: 'Maintenance', count: 2),
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

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Create Maintenance',
        message: 'Would you like to create a new maintenance?',
        primaryText: 'Yes',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
          MaterialPageRoute(
              builder: (_) => MaintenanceForm(requestType: 'Basic Information',),
            ),
          );
        },
        secondaryText: 'Cancel',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabLabel.toLowerCase()) {
      case 'repair':
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

      case 'maintenance':
        return ListView(
          children: [
            MaintenanceTaskCard(
              title: 'Pest Control',
              requestId: 'MT-5356',
              unit: 'Lobby',
              date: '27 July', 
              classification: 'Scheduled',
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

            if (selectedTabLabel.toLowerCase() == 'maintenance')
              Positioned(
                bottom: 24,
                right: 24,
                child: AddButton(onPressed: () => _showRequestDialog(context)),
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
