import 'package:facilityfix/widgets/buttons.dart' as custom_buttons;
import 'package:facilityfix/widgets/buttons.dart' as fx;
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/tag.dart'; // StatusTag, PriorityTag, RequestTypeTag, DepartmentTag
import 'package:intl/intl.dart';

// REPAIR DETAILS
class RepairDetailsScreen extends StatelessWidget {
  //  Basic Information
  final String? title;
  final String requestId;
  final String reqDate; // will display as: Aug 12, 2025
  final String requestType; // Concern Slip | Job Service | Work Order / Work Order Permit
  final String statusTag; // Pending | Scheduled | Assigned | In Progress | On Hold | Done
  final String? priority; // High | Medium | Low

  //  Tenant / Requester
  final String requestedBy;
  final String unit;
  final String? scheduleAvailability; // will display as: Aug 12, 1:30 PM (if time exists)

  //  Request Details
  final String? description;
  final List<String>? attachments;

  final String? jobServiceNotes; // For Job Service; falls back to description if null/empty

  // Initial Assessment
  final String? initialAssigneeName;
  final String? initialAssigneeDepartment;
  final String? initialDateAssessed;
  final String? initialAssessment;
  final String? initialRecommendation;
  final List<String>? initialAssessedAttachments;

  // Completion Assessment
  final String? completionAssigneeName;
  final String? completionAssigneeDepartment;
  final String? completionDateAssessed;
  final String? completionAssessment;
  final String? completionRecommendation;
  final List<String>? completionAssessedAttachments;

  //  Assigned To
  final String? assignedTo;
  final String? assignedDepartment;
  final String? assignedSchedule;

  //  Work Order Permit Validation
  final String? permitId;
  final String? reqType;
  final String? workScheduleFrom;
  final String? workScheduleTo;

  //  Contractor Profile
  final String? contractorName;
  final String? contractorCompany;
  final String? contractorNumber;

  // WO additional Notes
  final String? workOrderNotes;

  // CTA
  final String? actionLabel;
  final VoidCallback? onAction;

  const RepairDetailsScreen({
    super.key,
    // Basic
    this.title,
    required this.requestId,
    required this.reqDate,
    required this.requestType,
    required this.statusTag,
    this.priority,

    // Tenant
    required this.requestedBy,
    required this.unit,
    this.scheduleAvailability,

    // Request
    this.description,
    this.attachments,

    // Additional notes on Job Service
    this.jobServiceNotes,

    // Initial Assessment
    this.initialAssigneeName,
    this.initialAssigneeDepartment,
    this.initialDateAssessed,
    this.initialAssessment,
    this.initialRecommendation,
    this.initialAssessedAttachments,

    // Completion Assessment
    this.completionAssigneeName,
    this.completionAssigneeDepartment,
    this.completionDateAssessed,
    this.completionAssessment,
    this.completionRecommendation,
    this.completionAssessedAttachments,

    // Assigned
    this.assignedTo,
    this.assignedDepartment,
    this.assignedSchedule,

    // Permit
    this.permitId,
    this.reqType,
    this.workScheduleFrom,
    this.workScheduleTo,

    // Contractor
    this.contractorName,
    this.contractorCompany,
    this.contractorNumber,

    // WO additional Notes
    this.workOrderNotes,

    // CTA
    this.actionLabel,
    this.onAction,
  });

  static String _n(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  bool get _isJobService => _n(requestType).startsWith('job service'); // tolerant
  bool get _isPermit =>
      _n(requestType) == 'work order permit' || _n(requestType) == 'work order';

  bool get _hasAnyPermitData =>
      (reqType?.trim().isNotEmpty ?? false) ||
      (permitId?.trim().isNotEmpty ?? false) ||
      (workScheduleFrom?.trim().isNotEmpty ?? false) ||
      (workScheduleTo?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    // Which body to show in the main Request Details card
    final bool showJobNotes =
        _isJobService && (jobServiceNotes?.trim().isNotEmpty ?? false);
    final String? detailsBody =
        (showJobNotes ? jobServiceNotes : description)?.trim();
    final bool showDetailsCard = detailsBody?.isNotEmpty ?? false;

    // Work Order extra notes
    final bool showWoNotes = workOrderNotes?.trim().isNotEmpty ?? false;

    // Initial assessment presence
    final bool hasInitialAssessment =
        (initialAssigneeName?.trim().isNotEmpty ?? false) ||
        (initialAssigneeDepartment?.trim().isNotEmpty ?? false) ||
        (initialDateAssessed?.trim().isNotEmpty ?? false) ||
        (initialAssessment?.trim().isNotEmpty ?? false) ||
        (initialRecommendation?.trim().isNotEmpty ?? false) ||
        ((initialAssessedAttachments ?? const []).isNotEmpty);

    // Completion assessment presence
    final bool hasCompletionAssessment =
        (completionAssigneeName?.trim().isNotEmpty ?? false) ||
        (completionAssigneeDepartment?.trim().isNotEmpty ?? false) ||
        (completionDateAssessed?.trim().isNotEmpty ?? false) ||
        (completionAssessment?.trim().isNotEmpty ?? false) ||
        (completionRecommendation?.trim().isNotEmpty ?? false) ||
        ((completionAssessedAttachments ?? const []).isNotEmpty);

    final bool hasAssessmentBits = hasInitialAssessment || hasCompletionAssessment;

    final String headerTitle =
        (title?.trim().isNotEmpty ?? false) ? title!.trim() : requestType;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Row(
            children: [
              Expanded(
                child: Text(
                  headerTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (statusTag.isNotEmpty) StatusTag(status: statusTag),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            requestId,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF475467),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // ===== Basic info =====
          KeyValueRow.text(
            label: 'Date Requested',
            valueText: formatDateRequested(reqDate), // "Aug 12, 2025"
          ),
          const SizedBox(height: 8),
          KeyValueRow(
            label: 'Request Type',
            value: RequestTypeTag(requestType, width: 140),
          ),
          if ((priority ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            KeyValueRow(
              label: 'Priority',
              value: PriorityTag(priority: priority!, width: 100),
            ),
          ],

          // ----- Divider -----
          const SizedBox(height: 16),
          ffDivider(),
          const SizedBox(height: 14),

          // ===== Requester Details =====
          const _SectionTitle('Requester Details'),
          const SizedBox(height: 8),
          KeyValueRow.text(label: 'Requested By', valueText: requestedBy),
          const SizedBox(height: 8),
          KeyValueRow.text(label: 'Unit', valueText: unit),

          const SizedBox(height: 14),
          ffDivider(),
          const SizedBox(height: 14),

          // ===== Request Details =====
          _Section(
            title: "Request Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if ((scheduleAvailability?.trim().isNotEmpty ?? false)) ...[
                  KeyValueRow.text(
                    label: 'Schedule Availability',
                    valueText: formatSchedule(scheduleAvailability!.trim()),
                    labelWidth: 160,
                  ),
                  const SizedBox(height: 8),
                ],

                if (showDetailsCard)
                  _SectionCard(
                    title: showJobNotes ? 'Notes' : 'Description',
                    content: detailsBody!,
                  ),

                if ((attachments?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  const _SectionTitle('Attachments'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: attachments!.map((u) => _thumb(u, h: 80, w: 140)).toList(),
                  ),
                ],
              ],
            ),
          ),

          // ===== Assigned To =====
          if ((assignedTo ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            ffDivider(),
            const SizedBox(height: 14),
            _Section(
              title: "Assigned To",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarNameBlock(
                    name: assignedTo!,
                    department: assignedDepartment, // chip below the name
                  ),
                  if ((assignedSchedule ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    KeyValueRow.text(
                      label: 'Schedule',
                      valueText: formatSchedule(assignedSchedule!),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ===== Assessment =====
          if (hasAssessmentBits) ...[
            const SizedBox(height: 14),
            ffDivider(),
            const SizedBox(height: 14),

            _Section(
              title: 'Assessment and Recommendation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- Initial Assessment ----------------
                  if (hasInitialAssessment) ...[
                    if ((initialAssigneeName?.trim().isNotEmpty ?? false)) ...[
                      _AvatarNameBlock(
                        name: initialAssigneeName!.trim(),
                        department: initialAssigneeDepartment?.trim(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if ((initialDateAssessed?.trim().isNotEmpty ?? false)) ...[
                      KeyValueRow.text(
                        label: 'Date Assessed',
                        valueText: formatDateRequested(initialDateAssessed!.trim()),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((initialAssessment?.trim().isNotEmpty ?? false)) ...[
                      _SectionCard(
                        title: "Assessment",
                        content: initialAssessment!.trim(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((initialRecommendation?.trim().isNotEmpty ?? false)) ...[
                      _SectionCard(
                        title: "Recommendation",
                        content: initialRecommendation!.trim(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((initialAssessedAttachments?.isNotEmpty ?? false)) ...[
                      const _SectionTitle('Attachments'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: initialAssessedAttachments!
                            .map((u) => _thumb(u, h: 80, w: 140))
                            .toList(),
                      ),
                    ],
                  ],

                  // ---------------- Completion Assessment ----------------
                  if (hasCompletionAssessment) ...[
                    if ((completionAssigneeName?.trim().isNotEmpty ?? false)) ...[
                      _AvatarNameBlock(
                        name: completionAssigneeName!.trim(),
                        department: completionAssigneeDepartment?.trim(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if ((completionDateAssessed?.trim().isNotEmpty ?? false)) ...[
                      KeyValueRow.text(
                        label: 'Date Assessed',
                        valueText: formatDateRequested(completionDateAssessed!.trim()),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((completionAssessment?.trim().isNotEmpty ?? false)) ...[
                      _SectionCard(
                        title: "Assessment",
                        content: completionAssessment!.trim(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((completionRecommendation?.trim().isNotEmpty ?? false)) ...[
                      _SectionCard(
                        title: "Recommendation",
                        content: completionRecommendation!.trim(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if ((completionAssessedAttachments?.isNotEmpty ?? false)) ...[
                      const _SectionTitle('Attachments'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: completionAssessedAttachments!
                            .map((u) => _thumb(u, h: 80, w: 140))
                            .toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],

          // ===== Permit Details =====
          if (_isPermit || _hasAnyPermitData) ...[
            const SizedBox(height: 14),
            ffDivider(),
            const SizedBox(height: 14),
            _Section(
              title: "Permit Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((reqType ?? '').isNotEmpty)
                    KeyValueRow.text(label: 'Request Type', valueText: reqType!),
                  if ((permitId ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    KeyValueRow.text(label: 'Permit ID', valueText: permitId!),
                  ],
                  if ((workScheduleFrom ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SectionTitle('Work Schedule'),
                    const SizedBox(height: 8),
                    KeyValueRow.text(
                      label: 'From',
                      valueText: formatDateRequested(workScheduleFrom!),
                    ),
                  ],
                  if ((workScheduleTo ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    KeyValueRow.text(
                      label: 'To',
                      valueText: formatDateRequested(workScheduleTo!),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ===== Additional Notes (WO) =====
          if (showWoNotes) ...[
            const SizedBox(height: 8),
            _Section(
              title: "Notes",
              child: _SectionCard(content: workOrderNotes!.trim()),
            ),
          ],

          // ===== Contractor Profile =====
          if ((contractorName?.isNotEmpty ?? false) ||
              (contractorCompany?.isNotEmpty ?? false) ||
              (contractorNumber?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 14),
            ffDivider(),
            const SizedBox(height: 14),
            _Section(
              title: "Contractor Profile",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((contractorName ?? '').isNotEmpty)
                    KeyValueRow.text(label: 'Name', valueText: contractorName!),
                  if ((contractorCompany ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    KeyValueRow.text(label: 'Company', valueText: contractorCompany!),
                  ],
                  if ((contractorNumber ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    KeyValueRow.text(label: 'Phone', valueText: contractorNumber!),
                  ],
                ],
              ),
            ),
          ],

          // ===== CTA =====
          if (onAction != null) ...[
            const SizedBox(height: 16),
            custom_buttons.FilledButton(
              label: actionLabel ?? 'Next',
              onPressed: onAction!,
              backgroundColor: const Color(0xFF1F2937),
              textColor: Colors.white,
              height: 48,
              borderRadius: 10,
              withOuterBorder: false,
              width: double.infinity,
              isLoading: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar + Name with DepartmentTag below (left aligned)
class _AvatarNameBlock extends StatelessWidget {
  final String name;
  final String? department;
  const _AvatarNameBlock({required this.name, this.department});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: const ShapeDecoration(
            color: Color(0xFFD9D9D9),
            shape: OvalBorder(
              side: BorderSide(width: 1.68, color: Colors.white),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(name),
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Name + DepartmentTag (below)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF101828),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
              if ((department ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                DepartmentTag(department!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _initials(String fullName) {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

// MAINTENANCE DETAILS
class MaintenanceDetailsScreen extends StatefulWidget {
  //
  final String? title;
  final String requestId;
  final String reqDate; // Displays as: Aug 12, 2025
  final String requestType; // Concern Slip | Job Service | Work Order / Work Order Permit
  final String statusTag; // Pending | Scheduled | Assigned | In Progress | On Hold | Done

  // ── Assigned To ────────────────────────────────────────────────────────────
  final String? assignedTo;
  final String? assignedDepartment;
  final String? assignedSchedule; // formatted via formatSchedule if date-like

  // ── Optional content blocks ────────────────────────────────────────────────
  final String? location;
  final String? description;
  final List<String>? checklist;
  final List<String>? attachments;
  final String? adminNote;

  // ── Final / assessed info (optional) ───────────────────────────────────────
  final String? completionAssigneeName;
  final String? completionAssigneeDepartment;
  final String? completionDateAssessed; // formatted via formatSchedule
  final String? completionAssessment; // "Assessment:"
  final String? completionRecommendation; // "Recommendation:"
  final List<String>? completionAssessedAttachments; // "AssessedAttachments:"

  const MaintenanceDetailsScreen({
    super.key,
    // required header
    required this.title,
    required this.requestId,
    required this.reqDate,
    required this.requestType,
    required this.statusTag,

    // assigned to
    this.assignedTo,
    this.assignedDepartment,
    this.assignedSchedule,

    // optionals
    this.location,
    this.description,
    this.checklist,
    this.attachments,
    this.adminNote,

    // completion/assessed
    this.completionAssigneeName,
    this.completionAssigneeDepartment,
    this.completionDateAssessed,
    this.completionAssessment,
    this.completionRecommendation,
    this.completionAssessedAttachments,
  });

  @override
  State<MaintenanceDetailsScreen> createState() => _MaintenanceDetailsScreenState();
}

class _MaintenanceDetailsScreenState extends State<MaintenanceDetailsScreen> {
  late final List<Map<String, dynamic>> _checklistState;

  @override
  void initState() {
    super.initState();
    _checklistState = (widget.checklist ?? const <String>[])
        .map((item) => {"text": item, "checked": false})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasAssigned =
        (widget.assignedTo ?? '').trim().isNotEmpty ||
        (widget.assignedDepartment ?? '').trim().isNotEmpty ||
        (widget.assignedSchedule ?? '').trim().isNotEmpty;

    // Final/assessed block
    final assessedBy = (widget.completionAssigneeName ?? '').trim();
    final assessedDept = (widget.completionAssigneeDepartment ?? '').trim();
    final assessedDate = (widget.completionDateAssessed ?? '').trim();
    final assessedText = (widget.completionAssessment ?? '').trim();
    final recommendationText = (widget.completionRecommendation ?? '').trim();
    final assessedAttachments = widget.completionAssessedAttachments ?? const <String>[];
    final hasAssessmentBlock = assessedBy.isNotEmpty ||
        assessedDept.isNotEmpty ||
        assessedDate.isNotEmpty ||
        assessedText.isNotEmpty ||
        recommendationText.isNotEmpty ||
        assessedAttachments.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  (widget.title ?? '').trim().isEmpty ? 'Maintenance Task' : widget.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusTag(status: widget.statusTag),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.requestId,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Basic info (aligned rows)
          _Section(
            child: Column(
              children: [
                KeyValueRow.text(
                  label: 'Request Date',
                  valueText: formatDateRequested(widget.reqDate),
                ),
                const SizedBox(height: 8),
                KeyValueRow.text(
                  label: 'Request Type',
                  valueText: widget.requestType,
                ),
                if ((widget.location ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  KeyValueRow.text(
                    label: 'Location',
                    valueText: widget.location!.trim(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Description (optional)
          if ((widget.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _SectionCard(
              title: "Task Description",
              content: widget.description!.trim(),
            ),
          ],

          // Assigned To (optional)
          if (hasAssigned)
            _Section(
              title: "Assigned To",
              child: Column(
                children: [
                  if ((widget.assignedTo ?? '').trim().isNotEmpty)
                    KeyValueRow.text(label: 'Name', valueText: widget.assignedTo!.trim()),
                  if ((widget.assignedDepartment ?? '').trim().isNotEmpty) const SizedBox(height: 8),
                  if ((widget.assignedDepartment ?? '').trim().isNotEmpty)
                    KeyValueRow.text(label: 'Department', valueText: widget.assignedDepartment!.trim()),
                  if ((widget.assignedSchedule ?? '').trim().isNotEmpty) const SizedBox(height: 8),
                  if ((widget.assignedSchedule ?? '').trim().isNotEmpty)
                    KeyValueRow.text(
                      label: 'Schedule',
                      valueText: formatSchedule(widget.assignedSchedule!.trim()),
                    ),
                ],
              ),
            ),

          // Checklist (optional + interactive)
          if ((widget.checklist ?? const <String>[]).isNotEmpty)
            _Section(
              title: "Checklist / Task Steps",
              child: Column(
                children: _checklistState.map((step) {
                  final checked = step["checked"] as bool;
                  return InkWell(
                    onTap: () => setState(() => step["checked"] = !checked),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            checked ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 20,
                            color: const Color(0xFF111827),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step["text"] as String,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Final / assessed block (optional)
          if (hasAssessmentBlock)
            _Section(
              title: "Assessment and Recommendation",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assessed By (only if any field is present)
                  if (assessedBy.isNotEmpty || assessedDept.isNotEmpty || assessedDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assessed By',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (assessedBy.isNotEmpty)
                            KeyValueRow.text(label: 'Name', valueText: assessedBy),

                          if (assessedDept.isNotEmpty) const SizedBox(height: 8),
                          if (assessedDept.isNotEmpty)
                            KeyValueRow.text(label: 'Department', valueText: assessedDept),

                          if (assessedDate.isNotEmpty) const SizedBox(height: 8),
                          if (assessedDate.isNotEmpty)
                            KeyValueRow.text(label: 'Date', valueText: formatSchedule(assessedDate)),
                        ],
                      ),
                    ),

                  // Assessment card
                  if (assessedText.isNotEmpty) const SizedBox(height: 12),
                  if (assessedText.isNotEmpty)
                    _SectionCard(title: "Assessment", content: assessedText),

                  // Recommendation card
                  if (recommendationText.isNotEmpty) const SizedBox(height: 12),
                  if (recommendationText.isNotEmpty)
                    _SectionCard(title: "Recommendation", content: recommendationText),

                  // Attachments
                  if (assessedAttachments.isNotEmpty) const SizedBox(height: 12),
                  if (assessedAttachments.isNotEmpty)
                    _Section(
                      title: "Assessed Attachments",
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: assessedAttachments
                            .map((u) => _thumb(u, h: 80, w: 140))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),

          // Attachments (optional)
          if ((widget.attachments ?? const <String>[]).isNotEmpty)
            _Section(
              title: "Attachments",
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.attachments ?? const <String>[])
                    .map((u) => _thumb(u, h: 80, w: 140))
                    .toList(),
              ),
            ),

          // Admin Notes (optional)
          if ((widget.adminNote ?? '').trim().isNotEmpty)
            _Section(
              title: "Admin Notes",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Color(0xFF005CE7), size: 22),
                    const SizedBox(width: 10),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.adminNote!.trim(),
                        style: const TextStyle(
                          color: Color(0xFF005CE7),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Announcement Details Screen ------------------------------------------
class AnnouncementDetailScreen extends StatelessWidget {
  final String title;
  final String datePosted;
  final String classification;
  final String description;
  final String locationAffected;
  final String scheduleStart;
  final String scheduleEnd;
  final String contactNumber;
  final String contactEmail;

  const AnnouncementDetailScreen({
    super.key,
    required this.title,
    required this.datePosted,
    required this.classification,
    required this.description,
    required this.locationAffected,
    required this.scheduleStart,
    required this.scheduleEnd,
    required this.contactNumber,
    required this.contactEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header (title + date) =====
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              datePosted,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF475467),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 16),

            // ===== Classification Tag =====
            AnnouncementClassificationTag(classification),
            const SizedBox(height: 16),

            // ===== Content Sections =====
            _buildSectionCard(title: 'Description', content: description),
            _buildSectionCard(
              title: 'Location Affected',
              content: locationAffected,
            ),
            _buildSectionCard(
              title: 'Schedule',
              content: 'Start: $scheduleStart\nEnd: $scheduleEnd',
            ),
            _buildSectionCard(
              title: 'Need Help?',
              content: '📱 $contactNumber\n📧 $contactEmail',
              backgroundColor: const Color(0xFFEFF5FF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    Color backgroundColor = Colors.transparent,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEAECF0), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryDetailsScreen extends StatelessWidget {
  // ----- Item Details -----
  // Basic Information
  final String itemName;            // Item name or Requested item name
  final String itemId;              // Item ID (show in header if not empty)
  final String? dateAdded;          // e.g., 'Automated'
  final String? classification;     // reused by request item details if you like
  final String? department;         // e.g., 'Civil/Carpentry' (for item details only)
  final String? status;             // Inventory Request e.g., Pending or Approved

  // divider

  // Stock and Supplier Details
  // Stock (Item)
  final String? stockStatus;        // 'In Stock' | 'Out of Stock' | 'Critical'
  final String? quantity;           // '150 pcs'
  final String? reorderLevel;       // '50 pcs'
  final String? unit;               // 'pcs'

  // divider
  // Supplier (Information) (optional)
  final String? supplierName;
  final String? supplierNumber;
  final String? warrantyUntil;      // 'DD / MM / YY'

  // divider
  // Item details (Request)
  final String? requestId;
  final String? requestQuantity;
  final String? dateNeeded;
  final String? reqLocation;
  final String? requestUnit;

  // Requestor Details
  final String? staffName;
  final String? staffDepartment;

  // divider
  // Notes
  final String? notes;

  const InventoryDetailsScreen({
    super.key,

    // header
    required this.itemName,
    required this.itemId,
    this.status,

    // item
    this.dateAdded,
    this.classification,
    this.department,

    // stock
    this.stockStatus,
    this.quantity,
    this.reorderLevel,
    this.unit,

    // supplier
    this.supplierName,
    this.supplierNumber,
    this.warrantyUntil,

    // request
    this.requestId,
    this.requestQuantity,
    this.dateNeeded,
    this.reqLocation,
    this.requestUnit,

    // requestor
    this.staffName,
    this.staffDepartment,

    // notes
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      color: Color(0xFF101828),
      fontSize: 20,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
    );

    const idStyle = TextStyle(
      color: Color(0xFF475467),
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      height: 1.14,
      letterSpacing: -0.5,
    );

    // Prefer itemId; if empty, fall back to requestId
    final String headerId = _firstNonEmpty([itemId, requestId]) ?? '-';

    final List<Widget> sections = [];

    // ===== Basic Information =====
    final bool showBasicInfo = _any([dateAdded, classification, department]);
    if (showBasicInfo) {
      sections.add(
        _Section(
          title: 'Item Details',
          child: Column(
            children: [
              if (_isNotEmpty(dateAdded))
                KeyValueRow(label: 'Date Added', value: _kvText(dateAdded!)),
              if (_isNotEmpty(classification)) const SizedBox(height: 8),
              if (_isNotEmpty(classification))
                KeyValueRow(label: 'Classification', value: _kvText(classification!)),
              if (_isNotEmpty(department)) const SizedBox(height: 8),
              if (_isNotEmpty(department))
                KeyValueRow(label: 'Department', value: DepartmentTag(department!)),
            ],
          ),
        ),
      );
    }

    // ===== Stock =====
    final bool showStock = _any([stockStatus, quantity, reorderLevel, unit]);
    if (showStock) {
      sections.add(
        _Section(
          title: 'Stock Details',
          child: Column(
            children: [
              if (_isNotEmpty(stockStatus)) const SizedBox(height: 8),
              if (_isNotEmpty(stockStatus))
                KeyValueRow(
                  label: 'Stock Status',
                  value: StockStatusTag(stockStatus!),
                ),
              if (_isNotEmpty(quantity)) const SizedBox(height: 8),
              if (_isNotEmpty(quantity))
                KeyValueRow(label: 'Quantity', value: _kvText(quantity!)),
              if (_isNotEmpty(reorderLevel)) const SizedBox(height: 8),
              if (_isNotEmpty(reorderLevel))
                KeyValueRow(label: 'Reorder Level', value: _kvText(reorderLevel!)),
              if (_isNotEmpty(unit)) const SizedBox(height: 8),
              if (_isNotEmpty(unit))
                KeyValueRow(label: 'Unit', value: _kvText(unit!)),
            ],
          ),
        ),
      );
    }

    // ===== Supplier =====
    final bool showSupplier = _any([supplierName, supplierNumber, warrantyUntil]);
    if (showSupplier) {
      sections.add(
        _Section(
          title: 'Supplier Information',
          child: Column(
            children: [
              if (_isNotEmpty(supplierName))
                KeyValueRow(label: 'Supplier Name', value: _kvText(supplierName!)),
              if (_isNotEmpty(supplierNumber)) const SizedBox(height: 8),
              if (_isNotEmpty(supplierNumber))
                KeyValueRow(label: 'Supplier Number', value: _kvText(supplierNumber!)),
              if (_isNotEmpty(warrantyUntil)) const SizedBox(height: 8),
              if (_isNotEmpty(warrantyUntil))
                KeyValueRow(label: 'Warranty Until', value: _kvText(warrantyUntil!)),
            ],
          ),
        ),
      );
    }

    // ===== Request Item Details =====
    final bool showRequestItem = _any([requestId, requestQuantity, dateNeeded, reqLocation, requestUnit]);
    if (showRequestItem) {
      sections.add(
        _Section(
          title: 'Request Item Details',
          child: Column(
            children: [
              if (_isNotEmpty(requestId))
                KeyValueRow(label: 'Request ID', value: _kvText(requestId!)),
              if (_isNotEmpty(requestQuantity)) const SizedBox(height: 8),
              if (_isNotEmpty(requestQuantity))
                KeyValueRow(label: 'Quantity', value: _kvText(requestQuantity!)),
              if (_isNotEmpty(requestUnit)) const SizedBox(height: 8),
              if (_isNotEmpty(requestUnit))
                KeyValueRow(label: 'Unit', value: _kvText(requestUnit!)),
              if (_isNotEmpty(dateNeeded)) const SizedBox(height: 8),
              if (_isNotEmpty(dateNeeded))
                KeyValueRow(label: 'Date Needed', value: _kvText(dateNeeded!)),
              if (_isNotEmpty(reqLocation)) const SizedBox(height: 8),
              if (_isNotEmpty(reqLocation))
                KeyValueRow(label: 'Location / Unit', value: _kvText(reqLocation!)),
            ],
          ),
        ),
      );
    }

    // ===== Requestor Details =====
    final bool showRequestor = _any([staffName, staffDepartment]);
    if (showRequestor) {
      sections.add(
        _Section(
          title: 'Requestor Details',
          child: Column(
            children: [
              if (_isNotEmpty(staffName))
                KeyValueRow(label: 'Staff Name', value: _kvText(staffName!)),
              if (_isNotEmpty(staffDepartment)) const SizedBox(height: 8),
              if (_isNotEmpty(staffDepartment))
                KeyValueRow(label: 'Department', value: DepartmentTag(staffDepartment!)),
            ],
          ),
        ),
      );
    }

    // ===== Notes =====
    if (_isNotEmpty(notes)) {
      sections.add(_SectionCard(title: 'Notes / Purpose', content: notes!));
    }

    // Interleave with dividers
    final List<Widget> interspersed = [];
    for (int i = 0; i < sections.length; i++) {
      interspersed.add(sections[i]);
      if (i < sections.length - 1) interspersed.add(_divider());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(itemName, style: titleStyle)),
              if (_isNotEmpty(status)) ...[
                const SizedBox(width: 8),
                StatusTag(status: status!.trim()),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(headerId, style: idStyle),
          _divider(),
          // Body
          ...interspersed,
        ],
      ),
    );
  }

  // ---------- Helpers ----------
  static bool _isNotEmpty(String? s) => (s ?? '').trim().isNotEmpty;

  static bool _any(List<String?> vals) {
    for (final v in vals) {
      if (_isNotEmpty(v)) return true;
    }
    return false;
  }

  static String? _firstNonEmpty(List<String?> vals) {
    for (final v in vals) {
      if (_isNotEmpty(v)) return v!.trim();
    }
    return null;
  }

  static Widget _kvText(String text) => Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFF475467),
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.85,
        ),
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(thickness: 1, color: Color(0xFFE4E7EC)),
      );
}

// UI HELPERS -------------------------------

// Section shells
class _Section extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Section({this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      );
}


// "Aug 12, 2025"
String formatDateRequested(String input) {
  final s = input.trim();
  if (s.isEmpty) return s;

  DateTime? dt = DateTime.tryParse(s);

  // Try common incoming patterns if ISO parse failed.
  const patterns = <String>[
    'MMMM d, yyyy',
    'MMM d, yyyy',
    'M/d/yyyy',
    'M/d/yy',
    'MM-dd-yyyy',
    'yyyy-MM-dd',
    'yyyy-MM-dd HH:mm',
    'yyyy-MM-dd h:mm a',
  ];
  for (final p in patterns) {
    if (dt != null) break;
    try {
      dt = DateFormat(p).parseStrict(s);
    } catch (_) {}
  }
  if (dt == null) return input;

  return DateFormat('MMM d, yyyy').format(dt);
}

// "Aug 12, 1:30 PM" if time exists; otherwise "Aug 12"
String formatSchedule(String input) {
  final s = input.trim();
  if (s.isEmpty) return s;

  DateTime? dt = DateTime.tryParse(s);

  const patterns = <String>[
    'MMMM d, yyyy h:mm a',
    'MMM d, yyyy h:mm a',
    'M/d/yyyy h:mm a',
    'MM/dd/yyyy h:mm a',
    'yyyy-MM-dd HH:mm',
    'yyyy-MM-dd h:mm a',
    'MMM d, h:mm a',
    'MMMM d, h:mm a',
    'M/d h:mm a',
  ];
  for (final p in patterns) {
    if (dt != null) break;
    try {
      dt = DateFormat(p).parseStrict(s);
    } catch (_) {}
  }

  // If still not parseable, normalize dash/spacing and return.
  if (dt == null) {
    final cleaned = s
        .replaceAll(RegExp(r'\s*-\s*'), ' – ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
  }

  // Include time if present.
  final hasTimeInText =
      RegExp(r'\d{1,2}[:.]\d{2}').hasMatch(s) ||
      RegExp(r'\b(am|pm)\b', caseSensitive: false).hasMatch(s);
  final hasTimeInDt = dt.hour != 0 || dt.minute != 0 || dt.second != 0;

  final fmt = (hasTimeInText || hasTimeInDt)
      ? DateFormat('MMM d, h:mm a')
      : DateFormat('MMM d');
  return fmt.format(dt);
}

// ---- Small UI helpers ----
Widget ffDivider() => const Divider(height: 1, thickness: 1, color: Color(0xFFEAECF0));

Widget brokenThumb({double h = 80, double w = 140}) => Container(
      height: h,
      width: w,
      color: const Color(0xFFEAECF0),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Color(0xFF98A2B3)),
    );

Widget _thumb(String url, {double h = 80, double w = 140}) {
  final isNetwork = url.startsWith('http');
  final img = isNetwork
      ? Image.network(
          url,
          height: h,
          width: w,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => brokenThumb(h: h, w: w),
        )
      : Image.asset(
          url,
          height: h,
          width: w,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => brokenThumb(h: h, w: w),
        );
  return ClipRRect(borderRadius: BorderRadius.circular(4), child: img);
}

/// One unified row for label/value lines
class KeyValueRow extends StatelessWidget {
  final String label;
  final Widget value;
  final double labelWidth;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 120,
  });

  /// Convenience: plain text value
  factory KeyValueRow.text({
    Key? key,
    required String label,
    required String valueText,
    double labelWidth = 120,
    TextStyle? valueStyle,
  }) {
    return KeyValueRow(
      key: key,
      label: label,
      labelWidth: labelWidth,
      value: Text(
        valueText,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: (valueStyle ??
            const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF344054),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontFamily: 'Inter',
      color: Color(0xFF475467),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: labelWidth, child: Text(label, style: labelStyle)),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              child: value,
            ),
          ),
        ),
      ],
    );
  }
}

/// Section Title
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF344054),
      ),
    );
  }
}

/// Generic bordered card
class _SectionCard extends StatelessWidget {
  final String? title; // optional heading
  final String? content; // optional body text
  final Widget? child; // optional custom body
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final bool hideIfEmpty;

  const _SectionCard({
    super.key,
    this.title,
    this.content,
    this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.hideIfEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = (content ?? '').trim();
    final shouldHide = hideIfEmpty && child == null && trimmed.isEmpty;
    if (shouldHide) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: double.infinity),
      child: Container(
        margin: margin,
        padding: padding,
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEAECF0)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((title ?? '').trim().isNotEmpty) ...[
              Text(
                title!.trim(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF101828),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (trimmed.isNotEmpty) ...[
              Text(
                trimmed,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF475467),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.54,
                  letterSpacing: 0.25,
                ),
              ),
            ],
            if (child != null) ...[
              if (trimmed.isNotEmpty) const SizedBox(height: 8),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

// simple initials helper used by avatar
String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

// Details Permit
class DetailsPermit extends StatelessWidget {
  const DetailsPermit({
    super.key,
    this.title = 'Job Service Request',
    this.sectionTitle = 'Notes and Instructions',
    required this.notes,
    this.instructions = const [],
    this.notesHeading = 'Notes:',
    this.subHeading = 'Instructions:',
    this.onNext,
    this.maxWidth, // optional: cap overall width
    this.panelMaxWidth = 480, // optional: cap inner panel width
    this.primaryColor = const Color(0xFF005CE7),
    this.borderColor = const Color(0xFF818181),
  });

  final String title;
  final String sectionTitle;
  final String notes;
  final List<String> instructions;
  final String notesHeading;
  final String subHeading;

  final VoidCallback? onNext;

  final double? maxWidth;
  final double panelMaxWidth;

  final Color primaryColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? screenW),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF005CE7),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Main card area, expands to fill the remaining height
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: panelMaxWidth),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: borderColor),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Blue header
                            Container(
                              width: double.infinity,
                              height: 42,
                              padding: const EdgeInsets.all(10),
                              color: primaryColor,
                              child: Center(
                                child: Text(
                                  sectionTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Scrollable content area
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  12,
                                ),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: _Body(
                                      notes: notes,
                                      instructions: instructions,
                                      notesHeading: notesHeading,
                                      subHeading: subHeading,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Next Button
                            SafeArea(
                              top: false,
                              child: fx.FilledButton(
                                label: "Next",
                                onPressed: onNext ?? () {},
                                width: double.infinity,
                                height: 80,
                                backgroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.notes,
    required this.instructions,
    required this.notesHeading,
    required this.subHeading,
  });

  final String notes;
  final List<String> instructions;
  final String notesHeading;
  final String subHeading;

  @override
  Widget build(BuildContext context) {
    const headingStyle = TextStyle(
      color: Color(0xFF1D1D1F),
      fontSize: 12,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
    );

    const textStyle = TextStyle(
      color: Color(0xFF1D1D1F),
      fontSize: 12,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(notesHeading, style: headingStyle),
        const SizedBox(height: 6),
        Text(notes, style: textStyle),

        if (instructions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(subHeading, style: headingStyle),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(instructions.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: [
                      TextSpan(
                        text: '${i + 1}. ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: instructions[i]),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
