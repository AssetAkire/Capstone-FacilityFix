import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';

class InternalTaskViewPage extends StatefulWidget {
  /// Deep-linkable view with optional edit mode.
  final String taskId;
  final Map<String, dynamic>? initialTask;
  final bool startInEditMode;

  const InternalTaskViewPage({
    super.key,
    required this.taskId,
    this.initialTask,
    this.startInEditMode = false,
  });

  @override
  State<InternalTaskViewPage> createState() => _InternalTaskViewPageState();
}

class _InternalTaskViewPageState extends State<InternalTaskViewPage> {
  // ------------------------ Navigation helpers ------------------------
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_items': '/inventory/items',
      'inventory_request': '/inventory/request',
      'analytics': '/analytics',
      'announcement': '/announcement',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

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

  // ------------------------ Edit mode + form state ------------------------
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;

  // Basic Information controllers
  final _departmentCtrl = TextEditingController();
  final _createdByCtrl = TextEditingController();
  final _estimatedDurationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Schedule controllers
  final _recurrenceCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _nextDueCtrl = TextEditingController();

  // Assignment controllers
  final _assigneeNameCtrl = TextEditingController();
  final _assigneeDeptCtrl = TextEditingController();

  // Notifications controllers (NOW EDITABLE)
  final _adminNotifyCtrl = TextEditingController();
  final _staffNotifyCtrl = TextEditingController();

  // Header chips (view-only)
  List<String> _tags = const [];

  // Snapshot used for Cancel
  late Map<String, String> _original;

  // Sample checklist (view-only for now)
  final List<Map<String, dynamic>> _checklistItems = [];

  // ------------------------ Init/Dispose ------------------------
  @override
  void initState() {
    super.initState();

    final Map<String, dynamic> seed = widget.initialTask ?? {};

    // Safe setter
    void setText(TextEditingController c, String key) {
      c.text = (seed[key]?.toString() ?? '');
    }

    // Assign from incoming data
    setText(_departmentCtrl, 'assigneeDept');
    setText(_createdByCtrl, 'assigneeName');
    setText(_estimatedDurationCtrl, 'estimatedDuration');
    setText(_locationCtrl, 'location');
    setText(_descriptionCtrl, 'description');
    setText(_recurrenceCtrl, 'recurrence');
    setText(_startDateCtrl, 'startDate');
    setText(_nextDueCtrl, 'nextDueDate');
    setText(_assigneeNameCtrl, 'assigneeName');
    setText(_assigneeDeptCtrl, 'assigneeDept');
    setText(_adminNotifyCtrl, 'adminNotify');
    setText(_staffNotifyCtrl, 'staffNotify');

    if (seed['checklistItems'] != null && seed['checklistItems'] is List) {
      _checklistItems.clear();
      for (var item in seed['checklistItems']) {
        _checklistItems.add({
          'text': item['task'] ?? '',
          'completed': item['completed'] ?? false,
        });
      }
    }

    // Tags
    final dynamic t = seed['tags'];
    _tags =
        (t is List)
            ? t.map((e) => e.toString()).toList()
            : <String>['High-Turnover', 'Repair-Prone'];

    _original = _takeSnapshot();
    _isEditMode = widget.startInEditMode;
  }

  @override
  void dispose() {
    _departmentCtrl.dispose();
    _createdByCtrl.dispose();
    _estimatedDurationCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _recurrenceCtrl.dispose();
    _startDateCtrl.dispose();
    _nextDueCtrl.dispose();
    _assigneeNameCtrl.dispose();
    _assigneeDeptCtrl.dispose();
    _adminNotifyCtrl.dispose();
    _staffNotifyCtrl.dispose();
    super.dispose();
  }

  // ------------------------ Snapshot & Handlers ------------------------
  Map<String, String> _takeSnapshot() => {
    'department': _departmentCtrl.text,
    'createdBy': _createdByCtrl.text,
    'estimatedDuration': _estimatedDurationCtrl.text,
    'location': _locationCtrl.text,
    'description': _descriptionCtrl.text,
    'recurrence': _recurrenceCtrl.text,
    'startDate': _startDateCtrl.text,
    'nextDueDate': _nextDueCtrl.text,
    'assigneeName': _assigneeNameCtrl.text,
    'assigneeDept': _assigneeDeptCtrl.text,
    'adminNotify': _adminNotifyCtrl.text,
    'staffNotify': _staffNotifyCtrl.text,
  };

  void _enterEditMode() => setState(() => _isEditMode = true);

  void _cancelEdit() {
    // Revert to snapshot
    _departmentCtrl.text = _original['department']!;
    _createdByCtrl.text = _original['createdBy']!;
    _estimatedDurationCtrl.text = _original['estimatedDuration']!;
    _locationCtrl.text = _original['location']!;
    _descriptionCtrl.text = _original['description']!;
    _recurrenceCtrl.text = _original['recurrence']!;
    _startDateCtrl.text = _original['startDate']!;
    _nextDueCtrl.text = _original['nextDueDate']!;
    _assigneeNameCtrl.text = _original['assigneeName']!;
    _assigneeDeptCtrl.text = _original['assigneeDept']!;
    _adminNotifyCtrl.text = _original['adminNotify']!;
    _staffNotifyCtrl.text = _original['staffNotify']!;
    setState(() => _isEditMode = false);
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors.')),
      );
      return;
    }

    try {
      final updateData = _takeSnapshot();
      print('[v0] Updating maintenance task: ${widget.taskId}');

      // TODO: Call API to update the task
      // await _apiService.updateMaintenanceTask(widget.taskId, updateData);

      _original = _takeSnapshot(); // update baseline
      setState(() => _isEditMode = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[v0] Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
      }
    }
  }

  // ------------------------ Validators (real-time) ------------------------
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _durationValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final ok = RegExp(
      r'^\d+\s*(hr|hrs|hour|hours|min|mins|minutes)$',
      caseSensitive: false,
    ).hasMatch(v.trim());
    return ok ? null : 'Use formats like "3 hrs" or "45 mins"';
  }

  String? _dateValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v.trim());
    return ok ? null : 'Use YYYY-MM-DD';
  }

  /// Accept strings like: "1 week before, 3 days before, 1 day before"
  String? _notifyValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final parts = v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final re = RegExp(
      r'^\d+\s*(day|days|week|weeks)\s+before$',
      caseSensitive: false,
    );
    for (final p in parts) {
      if (!re.hasMatch(p)) {
        return 'Use entries like "1 week before" or "3 days before", comma-separated';
      }
    }
    return null;
  }

  // ------------------------ UI ------------------------
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(), // Breadcrumbs/title
              const SizedBox(height: 32),

              // ---------------- Main content container ----------------
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Notification banner (top of container) ---
                    _buildNotificationBanner(),
                    const SizedBox(height: 24),

                    // --- Task header + chips + edit toolbar ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: title + id + assignee
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.initialTask?['taskTitle'] ??
                                  "Light Inspection",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.taskId,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Assigned To: ${_assigneeNameCtrl.text}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Right: chips then toolbar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTaskTags(),
                            const SizedBox(height: 8),
                            _buildBottomActionBar(),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- Two-column layout ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildBasicInformationCard(),
                              const SizedBox(height: 24),
                              _buildChecklistCard(),
                              const SizedBox(height: 24),
                              _buildAdminNotesCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right column
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildScheduleCard(),
                              const SizedBox(height: 24),
                              _buildAssignmentCard(),
                              const SizedBox(height: 24),
                              _buildAttachmentsCard(),
                              const SizedBox(height: 24),
                              _buildNotificationsCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ Header (breadcrumbs only) ------------------------
  Widget _buildHeaderSection() {
    final taskTitle = widget.initialTask?['taskTitle'] ?? 'Light Inspection';
    final assignedTo =
        _assigneeNameCtrl.text.isNotEmpty
            ? _assigneeNameCtrl.text
            : 'Unassigned';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Work Orders",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () => context.go('/dashboard'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Dashboard'),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            TextButton(
              onPressed: () => context.go('/work/maintenance'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Work Orders'),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Maintenance Tasks'),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------ Header Chips ------------------------
  Widget _buildTaskTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _tags.map((t) {
            final isPrimary = t.toLowerCase().contains('high');
            final bg = isPrimary ? const Color(0xFFE8F5E8) : Colors.grey[100]!;
            final fg = isPrimary ? const Color(0xFF2E7D2E) : Colors.grey[700]!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                t,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
    );
  }

  // ------------------------ Notification Banner (top of container) ------------------------
  Widget _buildNotificationBanner() {
    final nextDue = _nextDueCtrl.text.trim();
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
            nextDue.isEmpty
                ? "Next service date not set"
                : "Next Service: $nextDue",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Bottom actions: Edit (view mode) OR Cancel/Save (edit mode)
  Widget _buildBottomActionBar() {
    if (!_isEditMode) {
      // VIEW MODE: single Edit button
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: _enterEditMode,
            icon: const Icon(Icons.edit, size: 20),
            label: const Text("Edit Task"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      );
    }

    // EDIT MODE: Cancel + Save (right aligned)
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _cancelEdit,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _saveEdit,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ],
    );
  }

  // ------------------------ Cards (some editable) ------------------------
  Widget _buildBasicInformationCard() {
    return _card(
      icon: Icons.info,
      iconBg: const Color(0xFF1976D2),
      title: 'Basic Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editableRow('Department', _departmentCtrl, validator: _req),
          _editableRow('Created By', _createdByCtrl, validator: _req),
          _editableRow(
            'Estimated Duration',
            _estimatedDurationCtrl,
            validator: _durationValidator,
            hint: 'e.g., 3 hrs, 45 mins',
          ),
          _editableRow('Location / Area', _locationCtrl, validator: _req),
          const SizedBox(height: 16),
          Text(
            'Task Description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _isEditMode
              ? TextFormField(
                controller: _descriptionCtrl,
                minLines: 3,
                maxLines: 6,
                validator: _req,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  hintText: 'Describe the work to be done...',
                ),
              )
              : Text(
                _descriptionCtrl.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _card(
      icon: Icons.calendar_today,
      iconBg: const Color(0xFFE8F5E8),
      title: 'Schedule',
      child: Column(
        children: [
          _editableRow(
            'Recurrence',
            _recurrenceCtrl,
            validator: _req,
            hint: 'e.g., Every 1 month',
          ),
          _editableRow(
            'Start Date',
            _startDateCtrl,
            validator: _dateValidator,
            hint: 'YYYY-MM-DD',
          ),
          _editableRow(
            'Next Due Date',
            _nextDueCtrl,
            validator: _dateValidator,
            hint: 'YYYY-MM-DD',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    return _card(
      icon: Icons.person,
      iconBg: Colors.grey[200]!,
      title: 'Assignment',
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _editableRow(
                  'Assignee Name',
                  _assigneeNameCtrl,
                  validator: _req,
                  compact: true,
                ),
                _editableRow(
                  'Department',
                  _assigneeDeptCtrl,
                  validator: _req,
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF9800)),
                ),
                child: const Icon(
                  Icons.checklist,
                  color: Color(0xFFFF9800),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Checklist / Task Steps",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...(_checklistItems.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        entry.value['completed']
                            ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.green,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value['text'],
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            entry.value['completed']
                                ? Colors.grey[500]
                                : Colors.black87,
                        decoration:
                            entry.value['completed']
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.comment,
                  color: Color(0xFF2E7D2E),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Admin Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1976D2), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning, color: Color(0xFF1976D2), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Emergency lights in basement often have moisture issues - check battery backups.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      height: 1.4,
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

  Widget _buildAttachmentsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: Color(0xFF1976D2),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Attachments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.image, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "basement-lights-before.jpg",
                        style: TextStyle(
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
                Icon(Icons.visibility, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// NEW: Notifications card (editable in edit mode)
  Widget _buildNotificationsCard() {
    return _card(
      icon: Icons.notifications,
      iconBg: Colors.grey[200]!,
      title: 'Notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editableRow(
            'Admin',
            _adminNotifyCtrl,
            validator: _notifyValidator,
            hint: 'e.g., 1 week before, 3 days before, 1 day before',
          ),
          _editableRow(
            'Assigned Staff',
            _staffNotifyCtrl,
            validator: _notifyValidator,
            hint: 'e.g., 3 days before, 1 day before',
          ),
        ],
      ),
    );
  }

  // ------------------------ Small card wrapper ------------------------
  Widget _card({
    required IconData icon,
    required Color iconBg,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      iconBg.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ------------------------ Core editable row ------------------------
  Widget _editableRow(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    String? hint,
    bool highlight = false,
    bool compact = false,
  }) {
    final labelStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
    final valueStyle = TextStyle(
      fontSize: 14,
      color: highlight ? Colors.red[600] : Colors.black87,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: labelStyle)),
          Expanded(
            child:
                _isEditMode
                    ? TextFormField(
                      controller: controller,
                      validator: validator,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hint,
                        border: const OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                    )
                    : Text(controller.text, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
