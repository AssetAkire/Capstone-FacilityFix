import 'package:flutter/material.dart';

class RepairDetailsScreen extends StatelessWidget {
  final String title;
  final String requestId;
  final String classification;
  final String date;
  final String requestType;
  final String unit;
  final String description;
  final String priority;
  final String assigneeName;
  final String assigneeRole;
  final List<String> attachments;
  final String? assessment;
  final String? recommendation;

  const RepairDetailsScreen({
    super.key,
    required this.title,
    required this.requestId,
    required this.classification,
    required this.date,
    required this.requestType,
    required this.unit,
    required this.description,
    required this.priority,
    required this.assigneeName,
    required this.assigneeRole,
    required this.attachments,
    this.assessment,
    this.recommendation,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFF04438);
      case 'medium':
        return const Color(0xFFF79009);
      case 'low':
        return const Color(0xFF12B76A);
      default:
        return const Color(0xFF667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Title + Classification)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEAECF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    classification,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475467),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              requestId,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475467),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Basic Info
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLabelValue("Submitted On", date),
                _buildLabelValue("Request Type", requestType),
                _buildLabelValue("Unit", unit),
              ],
            ),

            // Description (with card border)
            _buildSectionCard(title: "Description", content: description),

            // Priority
            _buildSection(
              title: "Priority",
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(priority,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),

            // Assignee
            _buildSection(
              title: "Assignee",
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFD9D9D9),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assigneeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        assigneeRole,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A5AF8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Assessment (optional, with card border)
            if (assessment != null && assessment!.isNotEmpty)
              _buildSectionCard(title: "Assessment", content: assessment!),

            // Recommendation (optional, with card border)
            if (recommendation != null && recommendation!.isNotEmpty)
              _buildSectionCard(title: "Recommendation", content: recommendation!),

            // Attachments
            _buildSection(
              title: "Attachments",
              child: Wrap(
                spacing: 8,
                children: attachments.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      url,
                      height: 80,
                      width: 140,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
            )),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF344054),
            )),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              )),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEAECF0), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.54,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}

// Maintenance Task 
class MaintenanceDetailsScreen extends StatefulWidget {
  final String title;
  final String status;
  final String maintenanceId;
  final String dateCreated;
  final String location;
  final String description;
  final String priority;
  final String recurrence;
  final String startDate;
  final String nextDate;
  final List<String> checklist;
  final List<String> attachments;
  final String adminNote;
  final String? assessment;
  final String? recommendation;

  const MaintenanceDetailsScreen({
    super.key,
    required this.title,
    required this.status,
    required this.maintenanceId,
    required this.dateCreated,
    required this.location,
    required this.description,
    required this.priority,
    required this.recurrence,
    required this.startDate,
    required this.nextDate,
    required this.checklist,
    required this.attachments,
    required this.adminNote,
    this.assessment,
    this.recommendation,
  });

  @override
  State<MaintenanceDetailsScreen> createState() =>
      _MaintenanceDetailsScreenState();
}

class _MaintenanceDetailsScreenState extends State<MaintenanceDetailsScreen> {
  late List<Map<String, dynamic>> checklistState;

  @override
  void initState() {
    super.initState();
    checklistState = widget.checklist
        .map((item) => {"text": item, "checked": false})
        .toList();
  }

  Color getPriorityColor() {
    switch (widget.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFF04438);
      case 'medium':
        return const Color(0xFFF79009);
      case 'low':
        return const Color(0xFF12B76A);
      default:
        return const Color(0xFF667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEAECF0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(widget.status,
                    style: const TextStyle(
                        color: Color(0xFF475467),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.maintenanceId,
              style: const TextStyle(
                  color: Color(0xFF475467),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),

          // Date & Location
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(width: 120, child: Text("Date Created", style: labelTextStyle)),
              Text(widget.dateCreated, style: valueTextStyle),
              SizedBox(width: 120, child: Text("Location", style: labelTextStyle)),
              Text(widget.location, style: valueTextStyle),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          _buildSectionCard(
            title: "Task Description",
            content: widget.description,
          ),
          const SizedBox(height: 16),

          // Priority
          buildSectionTitle("Priority"),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: getPriorityColor(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(widget.priority,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 16),

          // Schedule
          buildSectionTitle("Schedule"),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(width: 120, child: Text("Recurrence", style: labelTextStyle)),
              Text(widget.recurrence, style: valueTextStyle),
              SizedBox(width: 120, child: Text("Start Date", style: labelTextStyle)),
              Text(widget.startDate, style: valueTextStyle),
              SizedBox(width: 120, child: Text("Next Date", style: labelTextStyle)),
              Text(widget.nextDate, style: valueTextStyle),
            ],
          ),
          const SizedBox(height: 16),

          // Checklist
          buildSectionTitle("Checklist / Task Steps"),
          const SizedBox(height: 4),
          ...checklistState.asMap().entries.map((entry) {
            var step = entry.value;
            return InkWell(
              onTap: () {
                setState(() {
                  step["checked"] = !step["checked"];
                });
              },
              child: Row(
                children: [
                  Icon(
                    step["checked"]
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step["text"],
                      style: TextStyle(
                        fontSize: 14,
                        decoration: step["checked"]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),

          // Recommendation
          if (widget.recommendation != null && widget.recommendation!.isNotEmpty) ...[
            _buildSectionCard(
              title: "Recommendation",
              content: widget.recommendation!,
            ),
            const SizedBox(height: 16),
          ],

          // Assessment
          if (widget.assessment != null && widget.assessment!.isNotEmpty) ...[
            _buildSectionCard(
              title: "Assessment",
              content: widget.assessment!,
            ),
            const SizedBox(height: 16),
          ],

          // Attachments
          buildSectionTitle("Attachments"),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: widget.attachments.map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  url,
                  height: 80,
                  width: 140,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Admin Notes
          buildSectionTitle("Admin Notes"),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning,
                    color: Color(0xFF005CE7), size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.adminNote,
                    style: const TextStyle(
                      color: Color(0xFF005CE7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.14,
      ),
    );
  }

  TextStyle get labelTextStyle => const TextStyle(
        color: Color(0xFF475467),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  TextStyle get valueTextStyle => const TextStyle(
        color: Color(0xFF475467),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      );

  Widget _buildSectionCard({
    required String title,
    required String content,
    Color backgroundColor = Colors.transparent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEAECF0), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.54,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}


// Announcement Viewimport 
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

  Color _getBackgroundColor(String classification) {
    switch (classification.toLowerCase()) {
      case 'utility interruption':
        return const Color(0xFFEFF5FF); // blue background
      case 'power outage':
        return const Color(0xFFFDF6A3); // yellow background
      case 'pest control':
        return const Color(0xFF91E5B0); // green background
      case 'maintenance':
        return const Color(0xFFFFD4B1); // Orange-ish
      default:
        return const Color(0xFFF5F5F7); // gray background for others
    }
  }

  Color _getTextColor(String classification) {
    switch (classification.toLowerCase()) {
      case 'utility interruption':
        return const Color(0xFF005CE7); // blue text
      case 'power outage':
        return const Color(0xFFF3B40D); // yellow text
      case 'pest control':
        return const Color(0xFF00A651); // green text
      case 'maintenance':
        return const Color(0xFFF97316); // Orange-ish
      default:
        return const Color(0xFF7D7D7D); // gray text
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(classification);
    final txtColor = _getTextColor(classification);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (title + date)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: OvalBorder(
                      side: BorderSide(width: 1.68, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                      Text(
                        datePosted,
                        style: const TextStyle(
                          color: Color(0xFF005CE7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Classification Tag 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(130),
                ),
              ),
              child: Text(
                classification,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Section
            _buildSectionCard(
              title: 'Description',
              content: description,
            ),

            // Location Section
            _buildSectionCard(
              title: 'Location Affected',
              content: locationAffected,
            ),

            // Schedule Section
            _buildSectionCard(
              title: 'Schedule',
              content: 'Start: $scheduleStart\nEnd: $scheduleEnd',
            ),

            // Contact Section
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
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFEAECF0), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.54,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
