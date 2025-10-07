import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../services/api_service.dart';
import '../../services/auth_storage.dart';

class InternalMaintenanceFormPage extends StatefulWidget {
  const InternalMaintenanceFormPage({super.key});

  @override
  State<InternalMaintenanceFormPage> createState() =>
      _InternalMaintenanceFormPageState();
}

class _InternalMaintenanceFormPageState
    extends State<InternalMaintenanceFormPage> {
  // -------------------- FORM & VALIDATION --------------------
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoMode =
      AutovalidateMode.disabled; // turn on after first submit

  // For consistent field heights
  static const double _kFieldHeight = 56;

  // -------------------- CONTROLLERS --------------------
  final _taskTitleController = TextEditingController();
  final _codeIdController =
      TextEditingController(); // Auto-generated, read-only
  final _assignedStaffController = TextEditingController(); // Now editable
  final _dateCreatedController = TextEditingController(); // read-only display
  final _descriptionController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _remarksController = TextEditingController();

  final _startDateController = TextEditingController(); // read-only
  final _nextDueDateController = TextEditingController(); // read-only
  final _checklistItemController =
      TextEditingController(); // For checklist input

  // -------------------- STATE --------------------
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedLocation;
  String? _selectedRecurrence;
  String? _selectedDepartment;
  String? _selectedAdminNotification;
  String? _selectedStaffNotification;

  DateTime? _dateCreated;
  DateTime? _startDate;
  DateTime? _nextDueDate;

  final List<Map<String, dynamic>> _checklistItems = [];

  List<Map<String, dynamic>> _staffMembers = [];
  final _apiService = ApiService();

  // -------------------- NAV --------------------
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

  // -------------------- HELPERS --------------------
  // TODO: Replace with your auth/current user provider
  // String _getCurrentUserName() => 'Michelle Reyes'; // REMOVED

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPick,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onPick(picked);
  }

  Future<void> _initAutoFields() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }

    final profile = await AuthStorage.getProfile();
    if (profile != null) {
      final firstName = profile['first_name'] ?? '';
      final lastName = profile['last_name'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        _assignedStaffController.text = fullName;
      }
    }

    try {
      final codeId = await _apiService.getNextIPMCode();
      _codeIdController.text = codeId;
      print('[v0] Generated IPM code: $codeId');
    } catch (e) {
      print('[v0] Error fetching IPM code: $e');
      // Fallback to timestamp-based code if backend fails
      final year = DateTime.now().year;
      final number = DateTime.now().millisecondsSinceEpoch % 100000;
      _codeIdController.text = 'IPM-$year-${number.toString().padLeft(5, '0')}';
    }

    // Date Created (default to now)
    _dateCreated = DateTime.now();
    _dateCreatedController.text = _fmtDate(_dateCreated!);

    // Load staff members
    await _loadStaffMembers();
  }

  Future<void> _loadStaffMembers() async {
    setState(() => _staffMembers.clear());
    try {
      final staffData = await _apiService.getStaffMembers();
      setState(() {
        _staffMembers = List<Map<String, dynamic>>.from(staffData);
      });
    } catch (e) {
      print('[v0] Error loading staff members: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load staff members: $e')),
        );
      }
    }
  }

  void _addChecklistItem() {
    final itemText = _checklistItemController.text.trim();
    if (itemText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task item')));
      return;
    }

    setState(() {
      _checklistItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'task': itemText,
        'completed': false,
      });
      _checklistItemController.clear(); // Reset input field
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task item added successfully!')),
    );
  }

  void _removeChecklistItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item['id'] == id);
    });
  }

  // -------------------- VALIDATORS --------------------
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _reqDropdown<T>(T? v) => (v == null) ? 'Required' : null;

  String? _durationValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(
      r'^\d+\s*(min|mins|minutes|hr|hrs|hour|hours)$',
      caseSensitive: false,
    );
    return re.hasMatch(v.trim())
        ? null
        : 'Use formats like "45 mins" or "3 hrs"';
  }

  // -------------------- INIT/DISPOSE --------------------
  @override
  void initState() {
    super.initState();
    _initAutoFields();
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _codeIdController.dispose(); // Dispose new controller
    _assignedStaffController.dispose();
    _dateCreatedController.dispose();
    _descriptionController.dispose();
    _estimatedDurationController.dispose();
    _remarksController.dispose();
    _startDateController.dispose();
    _nextDueDateController.dispose();
    _checklistItemController.dispose(); // Dispose new controller
    super.dispose();
  }

  // -------------------- ACTIONS --------------------
  void _saveDraft() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft saved successfully!')));
  }

  Future<void> _onNext() async {
    // turn on real-time validation *after* first press
    setState(() => _autoMode = AutovalidateMode.onUserInteraction);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors.')),
      );
      return;
    }

    final id = _codeIdController.text;
    final maintenance = <String, dynamic>{
      'id': id,
      'maintenanceType': 'Internal',
      'taskTitle': _taskTitleController.text.trim(),
      'taskCode': id,
      'dateCreated': _dateCreatedController.text,
      'priority': _selectedPriority,
      'status': _selectedStatus,
      'location': _selectedLocation,
      'description': _descriptionController.text.trim(),
      'recurrence': _selectedRecurrence,
      'estimatedDuration': _estimatedDurationController.text.trim(),
      'startDate': _startDateController.text,
      'nextDueDate': _nextDueDateController.text,
      'assigneeName': _assignedStaffController.text.trim(),
      'assigneeDept': _selectedDepartment,
      'checklistItems': _checklistItems,
      'adminNotify':
          _selectedAdminNotification ??
          '1 week before, 3 days before, 1 day before',
      'staffNotify':
          _selectedStaffNotification ?? '3 days before, 1 day before',
      'remarks': _remarksController.text.trim(),
      'tags': ['High-Turnover', 'Repair-Prone'],
    };

    try {
      print('[v0] Saving maintenance task to backend...');
      await _apiService.createMaintenanceTask(maintenance);
      print('[v0] Maintenance task saved successfully');

      // Navigate to view page with the data
      if (mounted) {
        context.push(
          '/work/maintenance/$id/internal?edit=1',
          extra: maintenance,
        );
      }
    } catch (e) {
      print('[v0] Error saving maintenance task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save maintenance task: $e')),
        );
      }
    }
  }

  // -------------------- UI --------------------
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
          autovalidateMode: _autoMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Column(
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
                  //breadcrumb
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
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 16,
                      ),
                      TextButton(
                        onPressed: () => context.go('/work/maintenance'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Work Orders'),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 16,
                      ),
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
              ),
              const SizedBox(height: 32),

              // ---------- FORM ----------
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Basic Information =====
                      const Text(
                        "Basic Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Task Title
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _taskTitleController,
                                validator: _req,
                                decoration: _decoration('Enter Task Title'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _codeIdController,
                                enabled: false,
                                decoration: _decoration('Code Id').copyWith(
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  filled: true, // Added for background color
                                  fillColor:
                                      Colors.grey[50], // Light gray background
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Created By (auto, read-only) - REMOVED AS IT'S NOW DONE VIA AUTH TOKEN
                          // Expanded(
                          //   child: _fieldBox(
                          //     child: TextFormField(
                          //       controller: _createdByController,
                          //       enabled: false, // not editable
                          //       decoration: _decoration('Automated Name').copyWith(
                          //         disabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //           borderSide: BorderSide(color: Colors.grey[300]!),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 24),
                          Expanded(
                            child: _fieldBox(
                              child: Autocomplete<Map<String, dynamic>>(
                                optionsBuilder: (textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _staffMembers;
                                  }
                                  return _staffMembers.where((staff) {
                                    final name =
                                        '${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}'
                                            .toLowerCase();
                                    return name.contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                                displayStringForOption:
                                    (staff) =>
                                        '${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}'
                                            .trim(),
                                onSelected: (staff) {
                                  // Directly update the controller text for consistency
                                  _assignedStaffController.text =
                                      '${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}'
                                          .trim();
                                },
                                fieldViewBuilder: (
                                  context,
                                  controller,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  return TextFormField(
                                    controller:
                                        controller, // Use the controller passed to fieldViewBuilder
                                    focusNode: focusNode,
                                    validator: _req,
                                    decoration: _decoration('Assign Staff...'),
                                    // onChanged is crucial to update the _assignedStaffController if Autocomplete's controller is used directly
                                    onChanged: (value) {
                                      _assignedStaffController.text = value;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Date Created (editable with picker + validation)
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _dateCreatedController,
                                readOnly:
                                    true, // prevent typing, open picker instead
                                validator: _req,
                                onTap:
                                    () => _pickDate(
                                      initial: _dateCreated ?? DateTime.now(),
                                      onPick: (d) {
                                        setState(() {
                                          _dateCreated = d;
                                          _dateCreatedController
                                              .text = _fmtDate(d);
                                        });
                                      },
                                    ),
                                decoration: _decoration('YYYY-MM-DD').copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Priority
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedPriority,
                                validator: _reqDropdown,
                                decoration: _decoration('Select Priority...'),
                                items:
                                    const ['High', 'Medium', 'Low']
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) =>
                                        setState(() => _selectedPriority = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Status
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                validator: _reqDropdown,
                                decoration: _decoration('Select Status...'),
                                items:
                                    const [
                                          'New',
                                          'In Progress',
                                          'Completed',
                                          'On Hold',
                                        ]
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(() => _selectedStatus = v),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // ===== Task Scope & Description =====
                      const Text(
                        "Task Scope & Description",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location
                      _fieldLabel('Location / Area'),
                      _fieldBox(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLocation,
                          validator: _reqDropdown,
                          decoration: _decoration('Select Location...'),
                          items:
                              const [
                                    'Swimming pool',
                                    'Basketball Court',
                                    'Gym',
                                    'Parking area',
                                    'Lobby',
                                    'Elevators',
                                    'Halls',
                                    'Garden',
                                    'Corridors',
                                  ]
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() {
                                _selectedLocation = v;
                              }),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _fieldLabel('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        validator: _req,
                        maxLines: 5,
                        decoration: _decoration('Enter Description....'),
                      ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Checklist / Task Steps",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _addChecklistItem, // Use the new handler
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Add List"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Checklist input field
                      _fieldBox(
                        child: TextFormField(
                          controller:
                              _checklistItemController, // Use new controller
                          decoration: _decoration('Add List'),
                          onFieldSubmitted:
                              (_) => _addChecklistItem(), // Add on submit
                        ),
                      ),

                      // Display added checklist items
                      if (_checklistItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _checklistItems.length,
                            separatorBuilder:
                                (context, index) =>
                                    Divider(height: 1, color: Colors.grey[300]),
                            itemBuilder: (context, index) {
                              final item = _checklistItems[index];
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons
                                      .check_circle_outline, // Use a consistent icon
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                title: Text(
                                  item['task'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: Colors.red[400],
                                  onPressed:
                                      () => _removeChecklistItem(
                                        item['id'],
                                      ), // Use handler
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // ===== Recurrence & Schedule =====
                      const Text(
                        "Recurrence & Schedule",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Recurrence
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedRecurrence,
                                validator: _reqDropdown,
                                decoration: _decoration('Input'),
                                items:
                                    const [
                                          'Daily',
                                          'Weekly',
                                          'Monthly',
                                          'Quarterly',
                                          'Annually',
                                        ]
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) =>
                                        setState(() => _selectedRecurrence = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Estimated Duration
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _estimatedDurationController,
                                validator: _durationValidator,
                                decoration: _decoration(
                                  'e.g., 3 hrs / 45 mins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _startDateController,
                                validator: _req,
                                readOnly: true,
                                onTap:
                                    () => _pickDate(
                                      initial: _startDate ?? DateTime.now(),
                                      onPick: (d) {
                                        setState(() {
                                          _startDate = d;
                                          _startDateController.text = _fmtDate(
                                            d,
                                          );
                                        });
                                      },
                                    ),
                                decoration: _decoration('YYYY-MM-DD').copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Next Due Date
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                controller: _nextDueDateController,
                                validator: _req,
                                readOnly: true,
                                onTap:
                                    () => _pickDate(
                                      initial: _nextDueDate ?? DateTime.now(),
                                      onPick: (d) {
                                        setState(() {
                                          _nextDueDate = d;
                                          _nextDueDateController
                                              .text = _fmtDate(d);
                                        });
                                      },
                                    ),
                                decoration: _decoration('YYYY-MM-DD').copyWith(
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "Assignment & Execution",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          // Department
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDepartment,
                                validator: _reqDropdown,
                                decoration: _decoration('Select Department...'),
                                items:
                                    const [
                                          'Maintenance',
                                          'Engineering',
                                          'Facilities',
                                          'IT Support',
                                        ]
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) =>
                                        setState(() => _selectedDepartment = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Assigned Staff - REMOVED FROM HERE AS IT'S MOVED UP TO BASIC INFO
                          // Expanded(
                          //   child: _fieldBox(
                          //     child: TextFormField(
                          //       controller: _assignedStaffController,
                          //       validator: _req,
                          //       decoration: _decoration('Add Staff...'),
                          //     ),
                          //   ),
                          // ),
                          // Placeholder for potential additional staff assignment if needed
                          Expanded(
                            child: _fieldBox(
                              child: TextFormField(
                                decoration: _decoration(
                                  'Add Staff...',
                                ), // Keep as a placeholder or for future use
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "Attachments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'File upload - Feature coming soon!',
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Drop files here or click to upload",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "PDF, PNG, JPG up to 10MB",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "Remarks / Admin Notes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _remarksController,
                        maxLines: 5,
                        decoration: _decoration('Enter Description....'),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedAdminNotification,
                                decoration: _decoration('Before due date'),
                                items:
                                    const [
                                          'Before due date',
                                          '1 day before',
                                          '3 days before',
                                          '1 week before',
                                        ]
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(
                                      () => _selectedAdminNotification = v,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _fieldBox(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStaffNotification,
                                decoration: _decoration('Before due date'),
                                items:
                                    const [
                                          'Before due date',
                                          '1 day before',
                                          '3 days before',
                                          '1 week before',
                                        ]
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (v) => setState(
                                      () => _selectedStaffNotification = v,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // ===== Actions =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _saveDraft,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.save_outlined,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Save Draft",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _onNext, // VALIDATE then NAVIGATE
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- SMALL UI HELPERS --------------------
  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400]),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.blue),
    ),
  );

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
  );

  // Wrap inputs to enforce consistent heights
  Widget _fieldBox({required Widget child}) =>
      SizedBox(height: _kFieldHeight, child: child);
}
