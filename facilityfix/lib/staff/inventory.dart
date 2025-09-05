
import 'package:facilityfix/admin/forms/maintenance_task.dart';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/notification.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/announcement_cards.dart';
import 'package:facilityfix/widgets/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String selectedTabLabel = "Items";
  String _selectedClassification = "Items";
  final TextEditingController _searchController = TextEditingController();
  

  final tabs = [
    TabItem(label: 'Items', count: 1),
    TabItem(label: 'Requests', count: 1),
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

    if (index != 4) {
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
        title: 'Create Inventory Item',
        message: 'Would you like to create a new inventory item?',
        primaryText: 'Yes',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
          MaterialPageRoute(
              builder: (_) => MaintenanceForm(requestType: 'Inventory From',),
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
      case 'items':
        return ListView(
          children: [
            InventoryCard(
              itemName: 'Galvanized Screw 3mm',
              priority: 'Maintenance',
              itemId: 'MAT-CIV-003',
              categoryLabel: 'Civil/Carpentry',
              quantity: '150 pcs',
            ),
          ],
        );

      case 'requests':
        return ListView(
          children: [
            InventoryRequestCard(
              itemName: 'Galvanized Screw 3mm',
              requestId: 'REQ-2025-001',
              itemType: 'Civil/Carpentry',
              status: 'Pending',
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
        leading: const Text('Inventory Management'),
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
                    classifications: ['All', 'Maintenance', 'Electrical', 'Plumbing', 'Carpentry'],
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

            if (selectedTabLabel.toLowerCase() == 'requests')
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
        currentIndex: 4,
        onTap: _onTabTapped,
      ),
    );
  }
}
