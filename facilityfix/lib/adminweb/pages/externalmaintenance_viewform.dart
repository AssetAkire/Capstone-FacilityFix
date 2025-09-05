import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';

class ExternalViewTaskPage extends StatefulWidget {
  const ExternalViewTaskPage({super.key});

  @override
  State<ExternalViewTaskPage> createState() => _ExternalViewTaskPageState();
}

class _ExternalViewTaskPageState extends State<ExternalViewTaskPage> {
  // Route mapping helper function
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_view': '/inventory/view',
      'inventory_add': '/inventory/add',
      'analytics': '/analytics',
      'notice': '/notice',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

  // Logout handler
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Edit task handler
  void _handleEditTask() {
    context.go('/adminweb/pages/externalmaintenance_edit_form');
  }

  // Assessment dropdown handler
  void _handleAssessmentChange(String? value) {
    setState(() {
      // TODO: Update assessment status
    });
  }

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'work_maintenance',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },

      // IMPORTANT: FacilityFixLayout already scrolls the body,
      // so do NOT add Expanded/SingleChildScrollView here.
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // shrink-wrap vertically
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work Orders Title
            const Text(
              "Work Orders",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildBreadcrumb(),
            const SizedBox(height: 24),

            // Main content container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationBanner(),
                  const SizedBox(height: 32),

                  // Task header
                  _buildTaskHeader(),
                  const SizedBox(height: 32),

                  // Two-column content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBasicInformationCard(),
                            const SizedBox(height: 24),
                            _buildTaskScopeCard(),
                            const SizedBox(height: 24),
                            _buildContractorInformationCard(),
                            const SizedBox(height: 24),
                            _buildAttachmentsCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRecurrenceScheduleCard(),
                            const SizedBox(height: 24),
                            _buildAssessmentTrackingCard(),
                            const SizedBox(height: 24),
                            _buildNotificationsCard(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Edit Task button (positioned to the right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleEditTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text("Edit Task", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Breadcrumb navigation (separated from container)
  Widget _buildBreadcrumb() {
    return Row(
      children: [
        Text(
          "Main",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          "Work Orders",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        const Text(
          "Maintenance Tasks",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Notification banner (now inside container)
  Widget _buildNotificationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF1976D2),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            "Tasks Scheduled",
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Next Service: January 20, 2025",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Task title and status badges
  Widget _buildTaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Elevator Maintenance",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "PM-3RD-ELEV-002",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Assigned To: External / 3rd-Party",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        // Status badges
        Row(
          children: [
            _buildStatusBadge("High Priority", const Color(0xFFFFEBEE), const Color(0xFFD32F2F)),
            const SizedBox(width: 12),
            _buildStatusBadge("Repair-Prone", Colors.grey[200]!, Colors.grey[700]!),
            const SizedBox(width: 12),
            _buildStatusBadge("In Stock", const Color(0xFFE8F5E8), const Color(0xFF2E7D32)),
          ],
        ),
      ],
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Basic Information card
  Widget _buildBasicInformationCard() {
    return _buildCard(
      icon: Icons.info_outline,
      iconColor: const Color(0xFF1976D2),
      title: "Basic Information",
      child: Column(
        children: [
          _buildInfoRow("Maintenance Type", "External / 3rd-Party"),
          _buildInfoRow("Service Category", "Elevator"),
          _buildInfoRow("Created By", "Michelle Reyes"),
          _buildInfoRow("Date Created", "June 15, 2025"),
        ],
      ),
    );
  }

  // Recurrence & Schedule card
  Widget _buildRecurrenceScheduleCard() {
    return _buildCard(
      icon: Icons.calendar_today_outlined,
      iconColor: const Color(0xFF1976D2),
      title: "Recurrence & Schedule",
      child: Column(
        children: [
          _buildInfoRow("Recurrence", "Every 6 Months"),
          _buildInfoRow("Start Date", "2025-07-20"),
          _buildInfoRow("Next Due Date", "2026-01-20"),
          _buildInfoRow("Service Window", "2026-01-20 to 2026-01-23"),
        ],
      ),
    );
  }

  // Task Scope & Description card
  Widget _buildTaskScopeCard() {
    return _buildCard(
      icon: Icons.location_on_outlined,
      iconColor: Colors.grey[600]!,
      title: "Task Scope & Description",
      child: Column(
        children: [
          _buildInfoRow("Location / Area", "Building A"),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Task Description",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Perform safety inspection, control panel diagnostics, cable tension check, lubrication, and door sensor calibration. Includes load test simulation and emergency stop function test.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Assessment Tracking card
  Widget _buildAssessmentTrackingCard() {
    return Column(
      children: [
        _buildCard(
          icon: Icons.person_outline,
          iconColor: const Color(0xFF1976D2),
          title: "Assessment Tracking",
          child: Column(
            children: [
              // Service Date with calendar icon
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Service Date (Actual)",
                        style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          const Text(
                            "2025-07-02",
                            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_outlined,
                            color: const Color(0xFF1976D2),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Assessment Received with smaller dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Assessment Received",
                        style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: "Yes",
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            items: const [
                              DropdownMenuItem(value: "Yes", child: Text("Yes")),
                              DropdownMenuItem(value: "No", child: Text("No")),
                            ],
                            onChanged: _handleAssessmentChange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInfoRow("Logged By", "David Bautista"),
              _buildInfoRow("Logged Date", "2025-07-03"),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Assessment section (outside the card)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assessment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text(
                  "Elevator cables passed inspection; slight vibration in motor.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recommend section (outside the card)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recommend",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text(
                  "Recommend motor re-alignment in next quarter; monitor panel errors.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contractor Information card
  Widget _buildContractorInformationCard() {
    return _buildCard(
      icon: Icons.person_outline,
      iconColor: const Color(0xFF1976D2),
      title: "Contractor Information",
      child: Column(
        children: [
          _buildInfoRow("Contractor Name", "SkyLift Elevator Services, Inc."),
          _buildInfoRow("Contact Person", "Engr. David Ramirez"),
          _buildInfoRow("Phone Number", "0917-888-1111"),
          _buildInfoRow("Email", "david.r@skylift.com.ph"),
        ],
      ),
    );
  }

  // Notifications card
  Widget _buildNotificationsCard() {
    return _buildCard(
      icon: Icons.notifications_outlined,
      iconColor: const Color(0xFF1976D2),
      title: "Notifications",
      child: Column(
        children: [
          _buildInfoRow("Admin", "1 week before, 3 days before, 1 day before"),
        ],
      ),
    );
  }

  // Attachments card
  Widget _buildAttachmentsCard() {
    return _buildCard(
      icon: Icons.attach_file_outlined,
      iconColor: Colors.orange,
      title: "Attachments",
      child: Column(
        children: [
          _buildAttachmentItem(
            "towerA_elevator_check_july2025.pdf",
            Icons.picture_as_pdf,
            Colors.red,
            "PDF",
          ),
          const SizedBox(height: 12),
          _buildAttachmentItem(
            "door-sensor-before.jpg",
            Icons.image,
            Colors.green,
            "IMG",
          ),
        ],
      ),
    );
  }

  // Attachment item widget
  Widget _buildAttachmentItem(String filename, IconData icon, Color iconColor, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Image File",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Handle file preview/download
            },
            icon: Icon(Icons.visibility_outlined, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  // Generic card builder
  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Info row builder with reduced spacing
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Reduced from 16 to 12
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}