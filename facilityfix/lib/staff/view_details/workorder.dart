import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/form/assessment_form.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart'; // WorkOrderPage
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/helper_models.dart'; // WorkOrder, formatDateTime
import 'package:facilityfix/widgets/view_details.dart'; // RepairDetailsScreen, MaintenanceDetailsScreen
import 'package:facilityfix/widgets/buttons.dart' as custom_buttons;
import 'package:flutter/material.dart';


class WorkOrderDetails extends StatefulWidget {
  final String selectedTabLabel;
  final bool startInAssessment; // (no longer used, kept for constructor compatibility)
  final WorkOrder? workOrder; // store the passed item

  const WorkOrderDetails({
    super.key,
    required this.selectedTabLabel,
    this.startInAssessment = false,
    required this.workOrder,
  });

  @override
  State<WorkOrderDetails> createState() => _WorkOrderDetailsState();
}

class _WorkOrderDetailsState extends State<WorkOrderDetails> {
  int _selectedIndex = 1;

  late String _detailsLabel;

  // Hold metadata
  HoldResult? holdMeta;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

  @override
  void initState() {
    super.initState();
    _detailsLabel = widget.selectedTabLabel.toLowerCase().trim();

    // Remap generic labels using actual data
    if (widget.workOrder != null &&
        (_detailsLabel == 'repair detail' || _detailsLabel == 'maintenance detail')) {
      _detailsLabel = _autoLabelFromWorkOrder(widget.workOrder!);
      debugPrint('[Details] remapped to: $_detailsLabel');
    }

    debugPrint('DETAILS label="${widget.selectedTabLabel}" '
        'stored="$_detailsLabel" hasWorkOrder=${widget.workOrder != null}');
  }

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(), // list page
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

  String get _assessedFullDetailsLabel {
    if (_detailsLabel.contains('maintenance')) return 'assessed maintenance detail';
    return 'assessed repair detail';
  }

  Future<void> _onHoldPressed() async {
    final res = await showHoldSheet(context, initial: holdMeta);
    if (!mounted || res == null) return;
    setState(() => holdMeta = res);

    final until =
        res.resumeAt != null ? ' — until ${formatDateTime(res.resumeAt!)}' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set to On Hold: ${res.reason}$until'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------- Helpers to build dynamic from WorkOrder ----------
  Widget _buildRepairDetailsFrom(WorkOrder w, {required bool assessed}) {
    final requester = '—';
    final rt = (w.requestType ?? '').isNotEmpty
        ? w.requestType!
        : (w.requestId.toUpperCase().startsWith('JS') ? 'Job Service' : 'Concern Slip');

    return RepairDetailsScreen(
      // Basic
      title: w.title,
      requestId: w.requestId,
      reqDate: w.date,
      requestType: rt,
      statusTag: w.status,
      priority: w.priority,

      // Requester
      requestedBy: requester,
      unit: w.unit ?? '—',

      // Assigned (current)
      assignedTo: w.assignedTo,
      assignedDepartment: w.assignedDepartment,
      assignedSchedule: null,

      // Initial Assessment
      initialAssigneeName: w.hasInitialAssessment == true ? w.initialAssigneeName : null,
      initialAssigneeDepartment: w.hasInitialAssessment == true ? w.initialAssigneeDepartment : null,

      // Completion Assessment
      completionAssigneeName: w.hasCompletionAssessment == true ? w.completionAssigneeName : null,
      completionAssigneeDepartment: w.hasCompletionAssessment == true ? w.completionAssigneeDepartment : null,

      // CTA
      actionLabel: null,
      onAction: null,
    );
  }

  Widget _buildMaintenanceDetailsFrom(WorkOrder w, {required bool assessed}) {
    return MaintenanceDetailsScreen(
      title: w.title,
      requestId: w.requestId,
      reqDate: w.date,
      requestType: 'Preventive Maintenance',
      statusTag: w.status,
      location: w.unit,
      description: assessed
          ? 'Scheduled maintenance underway; findings documented below.'
          : 'Scheduled maintenance task.',
      assignedTo: w.assignedTo ?? w.initialAssigneeName,
      assignedDepartment: w.assignedDepartment ?? w.initialAssigneeDepartment,
      assignedSchedule: null,
      completionAssigneeName: w.hasCompletionAssessment == true ? w.completionAssigneeName : null,
      completionAssigneeDepartment: w.hasCompletionAssessment == true ? w.completionAssigneeDepartment : null,
      attachments: const [],
      adminNote: null,
    );
  }

  String _autoLabelFromWorkOrder(WorkOrder w) {
    final id = w.requestId.toUpperCase();
    final rt = (w.requestType ?? '').toLowerCase().trim();
    final s  = (w.status).toLowerCase().trim();

    if (rt.contains('maintenance') || id.startsWith('MT')) {
      return (s == 'scheduled' || s == 'assigned' || s == 'in progress')
          ? 'maintenance task scheduled'
          : 'maintenance task assessed';
    }
    if (rt == 'concern slip' || id.startsWith('CS')) {
      return (s == 'assigned' || s == 'on hold')
          ? 'concern slip assigned'
          : 'concern slip assessed';
    }
    if (rt == 'job service' || id.startsWith('JS')) {
      return (s == 'assigned' || s == 'on hold' || s == 'scheduled')
          ? 'job service assigned'
          : 'job service assessed';
    }
    return 'concern slip assigned';
  }

  Widget _buildTabContent() {
    final w = widget.workOrder;
    final children = <Widget>[];

    if (holdMeta != null) {
      children.add(const SizedBox(height: 8));
      children.add(OnHoldBanner(hold: holdMeta!));
      children.add(const SizedBox(height: 12));
    }

    // No more in-page assessment form—only details:
    switch (_detailsLabel) {
      // ---------------- Concern Slip (assigned) ----------------
      case 'concern slip assigned':
        if (w != null) {
          children.add(_buildRepairDetailsFrom(w, assessed: false));
        } else {
          // SAMPLE CASE
          children.add(
            RepairDetailsScreen(
              // Basic Information
              title: "Leaking Faucet",
              requestId: "CS-2025-001",
              reqDate: "August 2, 2025",
              requestType: "Concern Slip",
              statusTag: 'Assigned',
              priority: 'High',

              // Requestor Details
              requestedBy: 'Erika De Guzman',
              unit: "A 1001",
              scheduleAvailability: "August 19, 2025 2:30 PM",

              // Request Details (description is required)
              description:
                  "I’d like to report a clogged drainage issue in the bathroom.",
              attachments: const [
                "assets/images/upload1.png",
                "assets/images/upload2.png",
              ],

              // Assignment
              assignedTo: 'Juan Dela Cruz',
              assignedDepartment: 'Plumbing',
              assignedSchedule: 'August 20, 2025 9:00 AM',

              actionLabel: null,
              onAction: null,
            ),
          );
        }
        break;

      // ---------------- Concern Slip (assessed) ----------------
      case 'concern slip assessed':
        if (w != null) {
          children.add(_buildRepairDetailsFrom(w, assessed: true));
        } else {
          // SAMPLE CASE
          children.add(
            RepairDetailsScreen(
              // Basic Information
              title: "Leaking Faucet",
              requestId: "CS-2025-002",
              reqDate: "August 2, 2025",
              requestType: "Concern Slip",
              statusTag: 'Done',
              priority: 'High',

              // Requestor Details
              requestedBy: 'Erika De Guzman',
              unit: "A 1001",
              scheduleAvailability: "August 19, 2025 2:30 PM",

              // Request Details
              description:
                  "I’d like to report a clogged drainage issue in the bathroom.",
              attachments: const [
                "assets/images/upload1.png",
                "assets/images/upload2.png",
              ],

              // Assessed By
              initialAssigneeName: 'Juan Dela Cruz',
              initialAssigneeDepartment: 'Plumbing',
              initialDateAssessed: 'August 20, 2025',

              // Assessment and Recommendation
              initialAssessment:
                  'Drainage is clogged due to accumulated debris.',
              initialRecommendation:
                  'Perform professional cleaning; consider replacing the drainage cover.',
              initialAssessedAttachments: const ["assets/images/upload2.png"],

              actionLabel: null,
              onAction: null,
            ),
          );
        }
        break;

      // ---------------- Job Service (assigned) ----------------
      case 'job service assigned':
        if (w != null) {
          children.add(_buildRepairDetailsFrom(w, assessed: false));
        } else {
          // SAMPLE CASE
          children.add(
            RepairDetailsScreen(
              // Basic Information
              title: "Leaking Faucet",
              requestId: "JS-2025-031",
              reqDate: "August 2, 2025",
              requestType: "Job Service",
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
        }
        break;

      // ---------------- Job Service (assessed) ----------------
      case 'job service assessed':
        if (w != null) {
          children.add(_buildRepairDetailsFrom(w, assessed: true));
        } else {
          // SAMPLE CASE
          children.add(
            RepairDetailsScreen(
              // Basic Information
              title: "Leaking Faucet",
              requestId: "JS-2025-032",
              reqDate: "August 2, 2025",
              requestType: "Job Service",
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

              completionAssessment:
                  'Drainage is clogged due to accumulated debris.',
              completionRecommendation:
                  'Perform professional cleaning; consider replacing the drainage cover.',
              completionAssessedAttachments: const [
                "assets/images/upload2.png",
              ],

              actionLabel: null,
              onAction: null,
            ),
          );
        }
        break;

      // ---------------- Maintenance Task (scheduled) ----------------
      case 'maintenance task scheduled':
        if (w != null) {
          children.add(_buildMaintenanceDetailsFrom(w, assessed: false));
        } else {
          // SAMPLE CASE
          children.add(
            MaintenanceDetailsScreen(
              title: 'Quarterly Pipe Inspection',
              requestId: 'MT-P-2025-011',
              reqDate: 'Aug 30, 2025',
              requestType: 'Preventive Maintenance',
              statusTag: 'Scheduled',

              // Task Information
              location: 'Tower A - 5th Floor',
              description:
                  'Quarterly check of main and branch lines for leaks, corrosion, and pressure stability.',

              // Assigned To
              assignedTo: 'Juan Dela Cruz',
              assignedDepartment: 'Plumbing',
              assignedSchedule: 'Aug 30, 2025 9:00 AM',

              // Checklist
              checklist: const [
                'Notify tenants on the affected floor',
                'Shut off water supply safely',
                'Inspect risers and branch lines for leaks/corrosion',
                'Check pressure and flow at endpoints',
                'Restore supply and monitor for 15 minutes',
                'Log findings and anomalies',
              ],

              // Media + note
              attachments: const ['assets/images/upload3.png'],
              adminNote:
                  'Priority: High. Coordinate with security for access; water shutdown window must be posted 24h before.',
            ),
          );
        }
        break;

      // ---------------- Maintenance Task (assessed) ----------------
      case 'maintenance task assessed':
        if (w != null) {
          children.add(_buildMaintenanceDetailsFrom(w, assessed: true));
        } else {
          // SAMPLE CASE
          children.add(
            MaintenanceDetailsScreen(
              title: 'Light Inspection',
              requestId: 'MT-P-2025-011',
              reqDate: 'Aug 30, 2025',
              requestType: 'Work Order',
              statusTag: 'In Progress',

              // Task Information
              location: 'Tower A - 5th Floor',
              description:
                  'Scheduled maintenance underway; initial findings documented below.',

              // Assessment
              completionAssigneeName: 'Juan Dela Cruz',
              completionAssigneeDepartment: 'Plumbing',
              completionDateAssessed: 'Sep 1, 2025 10:30 AM',
              completionAssessment:
                  'Minor seepage detected at the riser valve near unit A-5-07. No major corrosion. '
                  'Pressure drop of ~5% during peak flow; within acceptable range.',
              completionRecommendation:
                  'Replace two worn gaskets, re-wrap threads with PTFE, tighten joints to spec, and monitor for 48 hours.',

              // Photos of the assessed area
              completionAssessedAttachments: const ['assets/images/upload2.png'],

              // Original task references (optional)
              attachments: const ['assets/images/upload3.png'],
              adminNote:
                  'If shutdown is needed, post a 2-hour advisory with security and concierge.',
            ),
          );
        }
        break;

      // ---------------- Generic labels (map using data) -------------
      case 'repair detail':
      case 'maintenance detail':
        if (w != null) {
          final mapped = _autoLabelFromWorkOrder(w);
          if (mapped.contains('maintenance')) {
            children.add(_buildMaintenanceDetailsFrom(w, assessed: mapped.contains('assessed')));
          } else {
            children.add(_buildRepairDetailsFrom(w, assessed: mapped.contains('assessed')));
          }
        } else {
          children.add(const Center(child: Text('No requests found.')));
        }
        break;

      default:
        // Fallback: if we have data show dynamic repair; else show nothing.
        if (w != null) {
          children.add(_buildRepairDetailsFrom(w, assessed: false));
        } else {
          children.add(const Center(child: Text('No requests found.')));
        }
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...children, const SizedBox(height: 8)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workOrder;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'View Details',
        leading: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: BackButton(),
        ),
        // keep these if your CustomAppBar supports them
        showMore: true,
        showHistory: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: _buildTabContent(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hide sticky bar if already in an assessed details view
          if (_detailsLabel != 'assessed repair detail' &&
              _detailsLabel != 'assessed maintenance detail')
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    // On Hold / Resume
                    Expanded(
                      child: custom_buttons.OutlinedPillButton(
                        icon: holdMeta != null
                            ? Icons.play_circle_outline
                            : Icons.pause_circle_outline,
                        label: holdMeta != null ? 'Resume Task' : 'On Hold',
                        onPressed: () {
                          if (holdMeta != null) {
                            setState(() => holdMeta = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task resumed'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            _onHoldPressed();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Create Assessment -> navigate to AssessmentForm
                    Expanded(
                      child: custom_buttons.FilledButton(
                        label: 'Create Assessment',
                        withOuterBorder: false,
                        backgroundColor: const Color(0xFF005CE7), // primary blue
                        onPressed: () {
                          // Push to standalone AssessmentForm
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssessmentForm(
                                // Pass any context you like (title/id/type)
                                requestType: w?.title ?? w?.requestId ?? 'Work Order',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
