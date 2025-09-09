import 'package:facilityfix/widgets/helper_models.dart';
import 'package:facilityfix/widgets/modals.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/view_details.dart'; // RepairDetailsScreen, MaintenanceDetailsScreen
import 'package:facilityfix/widgets/buttons.dart' as custom_buttons;
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/inventory.dart';

class WorkOrderDetailsPage extends StatefulWidget {
  final String selectedTabLabel;

  const WorkOrderDetailsPage({super.key, required this.selectedTabLabel});

  @override
  State<WorkOrderDetailsPage> createState() => _WorkOrderDetailsPageState();
}

class _WorkOrderDetailsPageState extends State<WorkOrderDetailsPage> {
  int _selectedIndex = 1;

  // ---- Full-details route labels (keep these consistent app-wide) ----
  static const String kJobServiceFull = 'job service full details';
  static const String kWorkPermitFull = 'work order permit full details';
  static const String kConcernAssignStaff = 'concern slip assign staff';

  // ---- Kind helpers ----
  String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  String get _kind {
    final s = _normalize(widget.selectedTabLabel);
    // Slight alias for safety
    return (s == 'job service request') ? 'job service' : s;
  }

  // Base type flags
  bool get _isConcernSlip => _kind.startsWith('concern slip');
  bool get _isJobService  => _kind.startsWith('job service');
  bool get _isWorkPermit  => _kind.startsWith('work order');
  bool get _isMaintenance => _kind == 'maintenance';

  // --- Granular status flags (used ONLY to decide if sticky actions show) ---
  // Concern Slip
  bool get _isConcernSlipPending  => _kind == 'concern slip';
  bool get _isConcernSlipAssigned => _kind == 'concern slip assigned';
  bool get _isConcernSlipDone     => _kind == 'concern slip assessed' || _kind == 'assessed concern slip';

  // Job Service
  bool get _isJobServicePending  => _kind == 'job service';
  bool get _isJobServiceAssigned => _kind == 'job service assigned';
  bool get _isJobServiceDone     => _kind == 'job service assessed';

  // Work Order
  bool get _isWorkOrderPending  => _kind == 'work order';
  bool get _isWorkOrderApproved => _kind == 'work order approved';

  // ---------------- Bottom Nav ----------------
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
      setState(() => _selectedIndex = index);
    }
  }

  // ---------------- Builder for detail body ----------------
  Widget _buildDetails() {
    switch (_kind) {
      // ---------- Concern Slip ----------
      // Concern Slip (Default)
      case 'concern slip':
        return RepairDetailsScreen(
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
          attachments: const ["assets/images/upload1.png", "assets/images/upload2.png"],
        );

      // Concern Slip (Assigned)
      case 'concern slip assigned':
        return RepairDetailsScreen(
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

          // Request Details
          description: "I’d like to report a clogged drainage issue in the bathroom.",
          attachments: const ["assets/images/upload1.png", "assets/images/upload2.png"],

          // Assignment
          assignedTo: 'Juan Dela Cruz',
          assignedDepartment: 'Plumbing',
          assignedSchedule: 'August 20, 2025 9:00 AM',
        );

      // Concern Slip (Assessed)
      case 'concern slip assessed':
        return RepairDetailsScreen(
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
          attachments: const ["assets/images/upload1.png", "assets/images/upload2.png"],

          // Assessed By
          initialAssigneeName: 'Juan Dela Cruz',
          initialAssigneeDepartment: 'Plumbing',
          initialDateAssessed: 'August 20, 2025',

          // Assessment and Recommendation
          initialAssessment: 'Drainage is clogged due to accumulated debris.',
          initialRecommendation: 'Perform professional cleaning; consider replacing the drainage cover.',
          initialAssessedAttachments: const ["assets/images/upload2.png"],
        );

      // ---------- Job Service ----------
      // Job Service (Default)
      case 'job service':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "JS-2025-031",
          reqDate: "August 2, 2025",
          requestType: "Job Service",
          statusTag: 'Pending',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          jobServiceNotes: "Please expedite; recurring issue.",
        );

      // Job Service (Assigned)
      case 'job service assigned':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "JS-2025-031",
          reqDate: "August 2, 2025",
          requestType: "Job Service",
          statusTag: 'Assigned',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          jobServiceNotes: "Please expedite; recurring issue.",

          assignedTo: 'Juan Dela Cruz',
          assignedDepartment: 'Plumbing',
          assignedSchedule: 'August 20, 2025 9:00 AM',
        );

      // Job Service (On Hold)
      case 'job service on hold':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "JS-2025-034",
          reqDate: "August 2, 2025",
          requestType: "Job Service",
          statusTag: 'On Hold',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          jobServiceNotes: "Please expedite; recurring issue.",

          assignedTo: 'Juan Dela Cruz',
          assignedDepartment: 'Plumbing',
          assignedSchedule: 'August 20, 2025 9:00 AM',
        );

      // Job Service (Assessed)
      case 'job service assessed':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "JS-2025-032",
          reqDate: "August 2, 2025",
          requestType: "Job Service",
          statusTag: 'Done',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          jobServiceNotes: "Please expedite; recurring issue.",

          completionAssigneeName: 'Juan Dela Cruz',
          completionAssigneeDepartment: 'Plumbing',
          completionDateAssessed: 'August 20, 2025 9:00 AM',

          completionAssessment: 'Drainage is clogged due to accumulated debris.',
          completionRecommendation: 'Perform professional cleaning; consider replacing the drainage cover.',
          completionAssessedAttachments: const ["assets/images/upload2.png"],
        );

      // ---------- Work Order Permit ----------
      // Work Order (Pending/Approved) — sample detail blocks preserved
      case 'work order':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "WO-2025-014",
          reqDate: "August 2, 2025",
          requestType: "Work Order",
          statusTag: 'Pending',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          reqType: 'Plumbing',
          permitId: 'WO-P-77821',
          workScheduleFrom: 'August 31, 2025 | 2 pm',
          workScheduleTo: 'August 31, 2025 | 4 pm',

          contractorName: 'CoolAir Services PH',
          contractorCompany: 'CoolAir Services PH',
          contractorNumber: '+63 917 555 1234',

          workOrderNotes: "AC unit is not cooling effectively; inspection requested.",
        );

      case 'work order approved':
        return RepairDetailsScreen(
          title: "Leaking Faucet",
          requestId: "WO-2025-014",
          reqDate: "August 2, 2025",
          requestType: "Work Order",
          statusTag: 'Approved',
          priority: 'High',

          requestedBy: 'Erika De Guzman',
          unit: "A 1001",
          scheduleAvailability: "August 19, 2025 2:30 PM",

          reqType: 'Plumbing',
          permitId: 'WO-P-77821',
          workScheduleFrom: 'August 31, 2025 | 2 pm',
          workScheduleTo: 'August 31, 2025 | 4 pm',

          contractorName: 'CoolAir Services PH',
          contractorCompany: 'CoolAir Services PH',
          contractorNumber: '+63 917 555 1234',

          workOrderNotes: "AC unit is not cooling effectively; inspection requested.",
        );

      // ---------- Maintenance ----------
      case 'maintenance detail':
        return MaintenanceDetailsScreen(
          title: 'Quarterly Pipe Inspection',
          requestId: 'MT-P-2025-011',
          reqDate: 'August 30, 2025',
          requestType: 'Maintenance Task',
          statusTag: 'Scheduled',

          // optional blocks
          location: 'Tower A - 5th Floor',
          description: 'Routine quarterly inspection of the main water lines on 5F.',
          checklist: const ['Shut off main valve', 'Inspect joints', 'Check for leaks'],
          attachments: const ['assets/images/upload1.png'],

          // assigned
          assignedTo: 'Juan Dela Cruz',
          assignedDepartment: 'Plumbing',
          assignedSchedule: 'August 30, 2025 10:00 AM',
        );

      case 'maintenance assessed':
        return MaintenanceDetailsScreen(
          title: 'Quarterly Pipe Inspection',
          requestId: 'MT-P-2025-011',
          reqDate: 'August 30, 2025',
          requestType: 'Maintenance Task',
          statusTag: 'Done',

          // optional blocks
          location: 'Tower A - 5th Floor',
          description: 'Routine quarterly inspection of the main water lines on 5F.',
          checklist: const ['Shut off main valve', 'Inspect joints', 'Check for leaks'],
          attachments: const ['assets/images/upload1.png'],

          // completion summary
          completionAssigneeName: 'Juan Dela Cruz',
          completionAssigneeDepartment: 'Plumbing',
          completionDateAssessed: 'August 20, 2025 9:00 AM',

          completionAssessment: 'Drainage is clogged due to accumulated debris.',
          completionRecommendation: 'Perform professional cleaning; consider replacing the drainage cover.',
          completionAssessedAttachments: const ["assets/images/upload2.png"],
        );

      // ---------- Fallback ----------
      default:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Unsupported details type.'),
          ),
        );
    }
  }

  // ------------- Shared helpers (routing to FullDetails, etc.) -------------
  void _goToKind(String kind) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkOrderDetailsPage(selectedTabLabel: kind),
      ),
    );
  }

  Future<void> _showFullDetailsPopup({
    required String fullDetailsLabel,
    String title = 'Success',
    String message =
        'The action has been completed.\nTap below to open the full details.',
    String primaryText = 'Open Full Details',
  }) async {
    return showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: title,
        message: message,
        primaryText: primaryText,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkOrderPage(),
            ),
          );
        },
      ),
    );
  }

  // ------------ Scenario actions (Reject / Assign / Accept) ------------
  Future<void> _openReject() async {
    final result = await showModalBottomSheet<RejectResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const RejectBottomSheet(),
    );
    if (!mounted || result == null) return;

    await showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Request Rejected',
        message:
            'Reason: ${result.reason}${(result.note?.isNotEmpty ?? false) ? "\n\nNote: ${result.note}" : ""}',
        primaryText: 'OK',
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _openAssign() async {
    final result = await showModalBottomSheet<AssignResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AssignStaffBottomSheet(),
    );
    if (!mounted || result == null) return;

    late final String fullDetailsLabel;
    if (_isConcernSlip || _isConcernSlipAssigned || _isConcernSlipDone) {
      fullDetailsLabel = kConcernAssignStaff;
    } else if (_isWorkPermit) {
      fullDetailsLabel = kWorkPermitFull;
    } else {
      fullDetailsLabel = kJobServiceFull;
    }

    await _showFullDetailsPopup(
      fullDetailsLabel: fullDetailsLabel,
      title: 'Assigned Successfully',
      message:
          'You’ve successfully assigned this request.\nTap below to view the full details.',
      primaryText: 'View Full Details',
    );
  }

  Future<void> _approvePermit() async {
    if (!mounted) return;
    await _showFullDetailsPopup(
      fullDetailsLabel: kWorkPermitFull,
      title: 'Permit Approved',
      message:
          'The Work Order Permit has been approved.\nTap below to view the full permit details.',
      primaryText: 'View Work Permit',
    );
  }

  // ------------- Sticky bars -------------
  Widget? _buildStickyBar() {
    // Concern Slip → show actions only on pending
    if (_isConcernSlip && _isConcernSlipPending) {
      return _barTwoButtons(
        left: custom_buttons.OutlinedPillButton(
          icon: Icons.delete_outline,
          label: 'Reject',
          onPressed: _openReject,
          height: 44,
          borderRadius: 24,
          foregroundColor: Colors.red,
          borderColor: Colors.red,
          backgroundColor: Colors.white,
          tooltip: 'Reject this request',
        ),
        right: custom_buttons.FilledButton(
          label: 'Assign Staff',
          icon: Icons.person_add_alt,
          onPressed: _openAssign,
          withOuterBorder: false,
          backgroundColor: const Color(0xFF005CE7),
        ),
      );
    }

    // Job Service → show actions only on pending
    if (_isJobService && _isJobServicePending) {
      return _barTwoButtons(
        left: custom_buttons.OutlinedPillButton(
          icon: Icons.delete_outline,
          label: 'Reject',
          onPressed: _openReject,
          height: 44,
          borderRadius: 24,
          foregroundColor: Colors.red,
          borderColor: Colors.red,
          backgroundColor: Colors.white,
          tooltip: 'Reject this job service',
        ),
        right: custom_buttons.FilledButton(
          label: 'Assign Staff',
          icon: Icons.person_add_alt,
          onPressed: _openAssign,
          withOuterBorder: false,
          backgroundColor: const Color(0xFF005CE7),
        ),
      );
    }

    // Work Order → show actions only when pending (hide on approved)
    if (_isWorkPermit && _isWorkOrderPending) {
      return _barTwoButtons(
        left: custom_buttons.OutlinedPillButton(
          icon: Icons.delete_outline,
          label: 'Reject',
          onPressed: _openReject,
          height: 44,
          borderRadius: 24,
          foregroundColor: Colors.red,
          borderColor: Colors.red,
          backgroundColor: Colors.white,
          tooltip: 'Reject this permit',
        ),
        right: custom_buttons.FilledButton(
          label: 'Accept', 
          icon: Icons.check_circle_outline,
          onPressed: _approvePermit,
          withOuterBorder: false,
          backgroundColor: const Color(0xFF005CE7),
        ),
      );
    }

    // Maintenance: no sticky bar by default (read-only), customize if needed.
    if (_isMaintenance) return null;

    // All other cases: no sticky bar
    return null;
  }

  // NOTE: SafeArea(bottom:false) so we don't double-apply system inset.
  Widget _barSingleButton(Widget button) {
    return SafeArea(
      top: false,
      bottom: false, // <-- important to prevent extra white band
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), // exact 8px bottom
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(children: [Expanded(child: button)]),
      ),
    );
  }

  // NOTE: SafeArea(bottom:false) so we don't double-apply system inset.
  Widget _barTwoButtons({required Widget left, required Widget right}) {
    return SafeArea(
      top: false,
      bottom: false, 
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), 
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sticky = _buildStickyBar();
    final bodyPadding = MediaQuery.of(context).padding;

    // Give the scroll body room so it's not hidden behind the sticky bar + navbar.
    // Tweak these if your sticky bar height changes.
    final extraBottom = sticky == null ? 24.0 : 120.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'View Details',
        leading: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: BackButton(),
        ),
        showMore: true,
        showHistory: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            extraBottom + bodyPadding.bottom,
          ),
          child: _buildDetails(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sticky != null) sticky,
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
