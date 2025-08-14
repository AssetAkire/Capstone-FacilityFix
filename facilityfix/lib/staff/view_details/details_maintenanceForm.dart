import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/view_details/full_details.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/forms.dart';
import 'package:facilityfix/widgets/pop_up.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:facilityfix/widgets/buttons.dart' as custom_buttons; 
import 'package:flutter/material.dart';

class MaintenanceDetails extends StatefulWidget {
  final String viewMode; // 'view detail' or 'add assessment'

  const MaintenanceDetails({super.key, this.viewMode = 'view detail'});

  @override
  State<MaintenanceDetails> createState() => _MaintenanceDetailsState();
}

class _MaintenanceDetailsState extends State<MaintenanceDetails> {
  int _selectedIndex = 1;
  String selectedTabLabel = "view detail";

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController recommendationController = TextEditingController();

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

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Assessment Completed',
        message:
            'You’ve successfully completed the assessment for this request.\nA notification has been sent to the tenant for further action.',
        primaryText: 'View Assessment',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const FullDetails(selectedTabLabel: 'maintenance detail',),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabLabel.toLowerCase()) {
      case 'view detail':
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
          attachments: [
            'https://placehold.co/147x80',
            'https://placehold.co/147x80'
          ],
          adminNote:
              'Emergency lights in basement often have moisture issues - check battery backups.',
        );

      case 'add assessment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assessment and Recommendation',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InputField(
              label: 'Assessment',
              controller: descriptionController,
              hintText: 'Enter task assessment',
              isRequired: true,
            ),
            const SizedBox(height: 8),
            InputField(
              label: 'Recommendation',
              controller: recommendationController,
              hintText: 'Enter recommendation',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            const Text('Attachment',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FileAttachmentPicker(label: 'Upload Attachment'),
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
        leading: Row(
          children: const [
            BackButton(),
            SizedBox(width: 8),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: custom_buttons.FilledButton(
              label: selectedTabLabel == 'view detail'
                  ? "Create Assessment"
                  : "Submit Assessment",
              onPressed: () {
                if (selectedTabLabel == 'add assessment') {
                  _showRequestDialog(context);
                  setState(() {
                    selectedTabLabel = 'view detail';
                  });
                } else {
                  setState(() {
                    selectedTabLabel = 'add assessment';
                  });
                }
              },
            ),
          ),
          NavBar(
            items: _navItems,
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
          ),
        ],
      ),
    );
  }
}