import 'package:facilityfix/tenant/chat.dart';
import 'package:facilityfix/tenant/request_forms.dart';
import 'package:facilityfix/tenant/view_details.dart';

import 'package:facilityfix/widgets/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/buttons.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/workOrder_cards.dart';
import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';

class WorkOrderPage extends StatefulWidget {
  const WorkOrderPage({super.key});

  @override
  State<WorkOrderPage> createState() => _WorkOrderPageState();
}

class _WorkOrderPageState extends State<WorkOrderPage> {
  String selectedTabLabel = "All";
  String _selectedClassification = "All";
  final TextEditingController _searchController = TextEditingController();

  final tabs = [
    TabItem(label: 'All', count: 5),
    TabItem(label: 'In Progress', count: 2),
    TabItem(label: 'Done', count: 3),
  ];

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

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Create a Request',
        message: 'Would you like to create a new request?',
        primaryText: 'Yes, Continue',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'What type of request would you like to create?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.assignment),
                      title: const Text('Concern Slip'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestForm(requestType: 'Concern Slip'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.build),
                      title: const Text('Work Order Request'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestForm(requestType: 'Work Order Permit'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
      case 'all':
        return ListView(
          children: [
            RequestRepairCard(
              title: "Clogged Drainage",
              requestId: "CS-2025-00321",
              date: "12 July",
              classification: "In Progress",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewDetailsPage(selectedTabLabel: 'repair detail',)),
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

      case 'in progress':
        return ListView(
          children: [
            RequestRepairCard(
              title: "Broken Light",
              requestId: "REQ-2025-010",
              date: "28 Sept",
              classification: "In Progress",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewDetailsPage(selectedTabLabel: 'repair',)),
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

      case 'done':
        return ListView(
          children: [
            RequestRepairCard(
              title: "Fixed Door Lock",
              requestId: "REQ-2025-005",
              date: "26 Sept",
              classification: "Completed",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewDetailsPage(selectedTabLabel: 'repair',)),
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
        leading: const Text('Repair Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
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
                  // Search + Filter
                  SearchAndFilterBar(
                    searchController: _searchController,
                    selectedClassification: _selectedClassification,
                    classifications: ['All', 'Electrical', 'Plumbing', 'Carpentry'],
                    onSearchChanged: (query) {
                      // Optional: filter logic
                    },
                    onFilterChanged: (classification) {
                      setState(() {
                        _selectedClassification = classification;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status Tabs
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

                  // Content
                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),
            // Add Button
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
