import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:facilityfix/widgets/view_details.dart'; // RepairDetailsScreen, AnnouncementDetailScreen
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/buttons.dart' as fx;

class ViewDetailsPage extends StatefulWidget {
  final String? selectedTabLabel;
  final String? requestType;

  const ViewDetailsPage({
    super.key,
    this.selectedTabLabel,
    this.requestType,
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
    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  _DetailsPayload _buildPayload(BuildContext context) {
    String normalize(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    final raw = (widget.selectedTabLabel?.trim().isNotEmpty ?? false)
        ? widget.selectedTabLabel!
        : (widget.requestType ?? '');
    final label = normalize(raw);

    switch (label) {
      // ---------------- Concern Slip  ----------------
      // Default Concern Slip
      case 'concern slip':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information (ALL required fields provided)
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Pending',

            // Requester
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Request Details (description is required)
            description: "I’d like to report a clogged drainage issue in the bathroom.",
            attachments: const ["assets/images/upload1.png","assets/images/upload2.png"],

            // Optional CTA
            actionLabel: null,
            onAction: null,
          ),
        );

      // ---------------- Concern Slip (assigned) ----------------
      case 'concern slip assigned':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Assigned',
            priority: 'High',

            // Requestor Details
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Request Details (description is required)
            description: "I’d like to report a clogged drainage issue in the bathroom.",
            attachments: const ["assets/images/upload1.png","assets/images/upload2.png"],

            // Assignment
            assignedTo: 'Juan Dela Cruz',
            assignedDepartment: 'Plumbing',
            assignedSchedule: 'August 20, 2025 9:00 AM',

            actionLabel: null,
            onAction: null,
          ),
        );

      // ---------------- Concern Slip (assessed) ----------------
      case 'concern slip assessed':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Done',
            priority: 'High',

            // Requestor Details
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Request Details
            description: "I’d like to report a clogged drainage issue in the bathroom.",
            attachments: const ["assets/images/upload1.png","assets/images/upload2.png"],

            // Assessed By
            initialAssigneeName: 'Juan Dela Cruz',
            initialAssigneeDepartment: 'Plumbing',
            initialDateAssessed: 'August 20, 2025',

            // Assessment and Recommendation
            initialAssessment: 'Drainage is clogged due to accumulated debris.',
            initialRecommendation: 'Perform professional cleaning; consider replacing the drainage cover.',
            initialAssessedAttachments: const ["assets/images/upload2.png"],

            actionLabel: null,
            onAction: null,
          ),
        );

      // ---------------- Job Service ----------------
      // Job Service (assigned)
      case 'job service assigned':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Assigned',
            priority: 'High',

            // Requestor Details
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Notes are used if the tenant has additional notes
            jobServiceNotes: "Please expedite; recurring issue.",

            // Assigned Job Service only
            assignedTo: 'Juan Dela Cruz',
            assignedDepartment: 'Plumbing',
            assignedSchedule: 'August 20, 2025 9:00 AM',

            actionLabel: null,
            onAction: null,
          ),
        );

      // Job Service (assessed)
      case 'job service assessed':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Done',
            priority: 'High',

            // Requestor Details
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Notes are used if the tenant has additional notes
            jobServiceNotes: "Please expedite; recurring issue.",

            // Assigned Job Service only
            completionAssigneeName: 'Juan Dela Cruz',
            completionAssigneeDepartment: 'Plumbing',
            completionDateAssessed: 'August 20, 2025 9:00 AM',

            completionAssessment: 'Drainage is clogged due to accumulated debris.',
            completionRecommendation: 'Perform professional cleaning; consider replacing the drainage cover.',
            completionAssessedAttachments: const ["assets/images/upload2.png"],

            actionLabel: null,
            onAction: null,
          ),
        );

      // ---------------- Work Order Permit ----------------
      // Work Order Permit (Approved)
      case 'work order':
        _selectedIndex = 1;
        return _DetailsPayload(
          child: RepairDetailsScreen(
            // Basic Information
            title: "Leaking Faucet",
            requestId: "CS-2025-00123",
            reqDate: "August 2, 2025",
            requestType: "Concern Slip",
            statusTag: 'Approved',
            priority: 'High',

            // Requestor Details
            requestedBy: 'Erika De Guzman',
            unit: "A 1001",
            scheduleAvailability: "August 19, 2025 2:30 PM",

            // Permit-related data (all optional in your widget)
            reqType: 'Plumbing',
            permitId: 'WO-P-77821',
            workScheduleFrom: 'August 31, 2025 | 2 pm',
            workScheduleTo: 'August 31, 2025 | 4 pm',

            // Contractors (optional)
            contractorName: 'CoolAir Services PH',
            contractorCompany: 'CoolAir Services PH',
            contractorNumber: '+63 917 555 1234',

            // Additional Notes
            workOrderNotes: "AC unit is not cooling effectively; inspection requested.",

            actionLabel: null,
            onAction: null,
          ),
        );

      // ---------------- Announcement Detail ----------------
      case 'announcement detail':
        _selectedIndex = 2;
        return _DetailsPayload(
          child: AnnouncementDetailScreen(
            // Basic Information
            title: 'Water Interruption Notice',
            datePosted: 'August 6, 2025',
            classification: 'Utility Interruption',

            // AAnnouncement Details
            description: 'Water supply will be interrupted due to mainline repair.',
            locationAffected: 'Building A & B',

            // Schedule Information
            scheduleStart: 'August 7, 2025 - 8:00 AM',
            scheduleEnd: 'August 7, 2025 - 5:00 PM',

            // Contact Information
            contactNumber: '0917 123 4567',
            contactEmail: 'support@condoadmin.ph',
          ),
        );

      default:
        _selectedIndex = 1;
        return const _DetailsPayload(
          child: Center(child: Text("No requests found.")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = _buildPayload(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'View Details',
        leading: const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: BackButton(),
            ),
          ],
        ),
        showMore: true,
        showHistory: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, payload.hasCta ? 120 : 24),
              child: payload.child,
            ),
            if (payload.hasCta)
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: fx.FilledButton(
                    label: payload.ctaLabel!,
                    onPressed: payload.onCtaPressed!,
                  ),
                ),
              ),
          ],
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

class _DetailsPayload {
  final Widget child;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const _DetailsPayload({
    required this.child,
    this.ctaLabel,
    this.onCtaPressed,
  });

  bool get hasCta => ctaLabel != null && onCtaPressed != null;
}
