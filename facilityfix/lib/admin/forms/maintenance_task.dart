import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // FilledButton
import 'package:facilityfix/widgets/forms.dart' hide DropdownField; // keep your InputField
import 'package:flutter/material.dart' hide FilledButton;
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/modals.dart'; // CustomPopup

class MaintenanceForm extends StatefulWidget {
  /// 'Basic Information' | 'Assign & Schedule Work'
  final String requestType;

  const MaintenanceForm({super.key, required this.requestType});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  // ---- Nav ----
  int _selectedIndex = 1;
  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];
  void _onTabTapped(int index) {
    final pages = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const CalendarPage(),
      const InventoryPage(),
    ];
    if (index != _selectedIndex) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => pages[index]));
    }
  }

  // ---- Step ----
  bool get _isFinalStep => widget.requestType == 'Assign & Schedule Work';

  // ---- Form key (so DropdownField validators run) ----
  final _formKey = GlobalKey<FormState>();

  // ---- Controllers ----
  final TextEditingController titleController = TextEditingController();         // Task Title
  final TextEditingController idController = TextEditingController();            // Task Id
  final TextEditingController createdByController = TextEditingController();     // Created By
  final TextEditingController dateCreatedController = TextEditingController();   // Date Created
  final TextEditingController descriptionController = TextEditingController();   // Description
  final TextEditingController hoursController = TextEditingController();         // Estimated Duration
  final TextEditingController dateStartedController = TextEditingController();   // Start Date (picker)
  final TextEditingController dueDateController = TextEditingController();       // Due Date (auto)
  final TextEditingController remarksController = TextEditingController();       // Notes
  final TextEditingController otherPriorityController = TextEditingController(); // used by "Others"

  final List<TextEditingController> checklistControllers = [];

  // ---- Dropdown state ----
  String? priorityValue;
  String? locationValue;
  String? recurringValue;
  String? departmentValue;
  String? staffValue;

  final List<String> notificationOptions = const [
    'Same Day',
    '1 Day Before',
    '2 Days Before',
    '3 Days Before',
    '1 Week Before',
    '1 Month Before',
    '3 Months Before',
  ];
  List<String> adminNotifTime = [];
  List<String> staffNotifTime = [];

  // ---- Validation state (for text fields & non-Form controls) ----
  bool _submittedBasic = false;
  bool _submittedAssign = false;

  final Map<String, String?> _errorsBasic = {
    'title': null,
    'id': null,
    'createdBy': null,
    'dateCreated': null,
    'description': null,
  };

  final Map<String, String?> _errorsAssign = {
    'hours': null,
    'startDate': null,
    'adminNotif': null,
    'staffNotif': null,
  };

  String? _errBasic(String k) => _errorsBasic[k];
  String? _errAssign(String k) => _errorsAssign[k];

  // Small helper for non-TextFormField error captions
  Widget _errorText(String? msg) {
    if (msg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        msg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFD92D20),
          fontSize: 12,
          height: 0.33,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ---- Validators for InputFields (dropdowns validate inside widget) ----
  void _validateBasic() {
    _errorsBasic.updateAll((k, v) => null);
    if (titleController.text.trim().isEmpty) _errorsBasic['title'] = 'Task Title is required.';
    if (idController.text.trim().isEmpty) _errorsBasic['id'] = 'Task Id is required.';
    if (createdByController.text.trim().isEmpty) _errorsBasic['createdBy'] = 'Created By is required.';
    if (dateCreatedController.text.trim().isEmpty) _errorsBasic['dateCreated'] = 'Date Created is required.';

    final desc = descriptionController.text.trim();
    if (desc.isEmpty) {
      _errorsBasic['description'] = 'Description is required.';
    } else if (desc.length < 10) {
      _errorsBasic['description'] = 'Please enter at least 10 characters.';
    }
  }

  void _validateAssign() {
    _errorsAssign.updateAll((k, v) => null);

    final hours = hoursController.text.trim();
    final hNum = double.tryParse(hours);
    if (hours.isEmpty) {
      _errorsAssign['hours'] = 'Estimated duration (hours) is required.';
    } else if (hNum == null || hNum <= 0) {
      _errorsAssign['hours'] = 'Enter a positive number of hours.';
    }
    if (dateStartedController.text.trim().isEmpty) {
      _errorsAssign['startDate'] = 'Start date is required.';
    }
    if (adminNotifTime.isEmpty) _errorsAssign['adminNotif'] = 'Select at least one admin notification time.';
    if (staffNotifTime.isEmpty) _errorsAssign['staffNotif'] = 'Select at least one staff notification time.';
  }

  // ---- Checklist controls ----
  void addChecklistItem() => setState(() => checklistControllers.add(TextEditingController()));
  void removeChecklistItem(int index) => setState(() => checklistControllers.removeAt(index));

  // ---- Lifecycle ----
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateCreatedController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    idController.text = "MTN-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}";
    createdByController.text = "System"; // or current user name
  }

  @override
  void dispose() {
    titleController.dispose();
    idController.dispose();
    createdByController.dispose();
    dateCreatedController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
    dateStartedController.dispose();
    dueDateController.dispose();
    remarksController.dispose();
    otherPriorityController.dispose();
    for (final c in checklistControllers) c.dispose();
    super.dispose();
  }

  // ---- Actions ----
  void _onNextOrSubmit() {
    // Let dropdowns (inside the Form) run their validators
    final formOk = _formKey.currentState?.validate() ?? false;

    if (_isFinalStep) {
      _submittedAssign = true;
      _validateAssign();
      setState(() {}); // refresh text-field errors

      final hasErrors = _errorsAssign.values.any((e) => e != null);
      if (!formOk || hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }
      _showRequestDialog(context);
    } else {
      _submittedBasic = true;
      _validateBasic();
      setState(() {}); // refresh text-field errors

      final hasErrors = _errorsBasic.values.any((e) => e != null);
      if (!formOk || hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MaintenanceForm(requestType: 'Assign & Schedule Work'),
        ),
      );
    }
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message: 'Your ${widget.requestType.toLowerCase()} has been submitted successfully and is now listed under Maintenance Tasks.',
        primaryText: 'Go to Work Orders',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WorkOrderPage()));
        },
      ),
    );
  }

  // ---- Form per step ----
  List<Widget> getFormFields() {
    switch (widget.requestType) {
      case 'Basic Information':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Basic Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Text inputs
          InputField(
            label: 'Task Title',
            controller: titleController,
            hintText: 'Enter Task Title',
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('title') : null,
          ),
          InputField(
            label: 'Task Id',
            controller: idController,
            hintText: 'Auto-filled',
            isRequired: true,
            readOnly: true,
            errorText: _submittedBasic ? _errBasic('id') : null,
          ),
          InputField(
            label: 'Created By',
            controller: createdByController,
            hintText: 'Auto-filled',
            isRequired: true,
            readOnly: true,
            errorText: _submittedBasic ? _errBasic('createdBy') : null,
          ),
          InputField(
            label: 'Date Created',
            controller: dateCreatedController,
            hintText: 'Auto-filled',
            isRequired: true,
            readOnly: true,
            errorText: _submittedBasic ? _errBasic('dateCreated') : null,
          ),

          // Priority (required) — handled by DropdownField’s validator
          DropdownField<String>(
            label: 'Priority',
            value: priorityValue,
            items: const ['Low', 'Medium', 'High'],
            onChanged: (v) {
              setState(() => priorityValue = v);
              _formKey.currentState?.validate(); // update outline immediately
            },
            isRequired: true,
            requiredMessage: 'Priority is required.',
          ),

          const SizedBox(height: 8),
          const Text('Maintenance Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Location (required) — with “Others”
          DropdownField<String>(
            label: 'Location',
            value: locationValue,
            items: const ['Lobby', 'Gate', 'Pool', 'Others'],
            onChanged: (v) {
              setState(() => locationValue = v);
              _formKey.currentState?.validate();
            },
            isRequired: true,
            requiredMessage: 'Location is required.',
            otherController: otherPriorityController, // used when "Others" is selected
          ),

          InputField(
            label: 'Description',
            controller: descriptionController,
            hintText: 'Enter task description',
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('description') : null,
          ),

          const SizedBox(height: 8),
          ChecklistSection(
            checklistControllers: checklistControllers,
            addChecklistItem: addChecklistItem,
            removeChecklistItem: removeChecklistItem,
          ),
        ];

      case 'Assign & Schedule Work':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Schedule & Assignment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          DropdownField<String>(
            label: 'Recurring Interval',
            value: recurringValue,
            items: const ['1 week', '1 month', '3 months', '1 year', 'Others'],
            onChanged: (v) {
              setState(() => recurringValue = v);
              _formKey.currentState?.validate();
            },
            isRequired: true,
            requiredMessage: 'Recurring interval is required.',
            otherController: otherPriorityController,
          ),

          InputField(
            label: 'Estimated Duration',
            controller: hoursController,
            hintText: 'In hours',
            isRequired: true,
            errorText: _submittedAssign ? _errAssign('hours') : null,
          ),

          InputField(
            controller: dateStartedController,
            readOnly: true,
            label: 'Start Date',
            hintText: 'Pick start date',
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF005CE7)), // brand blue
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  dateStartedController.text =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  if (_submittedAssign) _validateAssign();
                });
              }
            },
            errorText: _submittedAssign ? _errAssign('startDate') : null,
          ),

          InputField(
            label: 'Due Date',
            controller: dueDateController,
            hintText: 'Auto-calculated',
            readOnly: true,
            errorText: null,
          ),

          DropdownField<String>(
            label: 'Department',
            value: departmentValue,
            items: const ['Maintenance', 'Plumbing', 'Electrical', 'Carpentry', 'Others'],
            onChanged: (v) {
              setState(() => departmentValue = v);
              _formKey.currentState?.validate();
            },
            isRequired: true,
            requiredMessage: 'Department is required.',
            otherController: otherPriorityController,
          ),

          DropdownField<String>(
            label: 'Assign Staff',
            value: staffValue,
            items: const ['Juan Dela Cruz', 'Anna Marie', 'Pedro Santos'],
            onChanged: (v) {
              setState(() => staffValue = v);
              _formKey.currentState?.validate();
            },
            isRequired: true,
            requiredMessage: 'Assigned staff is required.',
          ),

          FileAttachmentPicker(label: 'Upload Attachment'),

          InputField(
            label: 'Notes',
            controller: remarksController,
            hintText: 'Enter remarks',
            isRequired: false,
            errorText: null,
          ),

          const SizedBox(height: 8),
          const Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Not a TextFormField -> manual error caption
          NotificationChecklist(
            label: 'Admin Notifications',
            items: notificationOptions,
            values: adminNotifTime,
            onChanged: (vals) {
              setState(() => adminNotifTime = vals);
              if (_submittedAssign) _validateAssign();
            },
            isRequired: true,
          ),
          if (_submittedAssign) _errorText(_errAssign('adminNotif')),

          const SizedBox(height: 8),
          NotificationChecklist(
            label: 'Staff Notifications',
            items: notificationOptions,
            values: staffNotifTime,
            onChanged: (vals) {
              setState(() => staffNotifTime = vals);
              if (_submittedAssign) _validateAssign();
            },
            isRequired: true,
          ),
          if (_submittedAssign) _errorText(_errAssign('staffNotif')),
        ];

      default:
        return [const Text('Invalid request type')];
    }
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    // Turn on autovalidate after first submit/next so dropdown borders/captions show immediately
    final autovalidate = (_submittedBasic || _submittedAssign)
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'New Maintenance Task',
        leading: Row(children: const [BackButton(), SizedBox(width: 8)]),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: autovalidate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...getFormFields(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    label: _isFinalStep ? 'Submit' : 'Next',
                    backgroundColor: const Color(0xFF005CE7),
                    textColor: Colors.white,
                    withOuterBorder: false,
                    onPressed: _onNextOrSubmit,
                  ),
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

/// ===== Checklist Section =====
class ChecklistSection extends StatelessWidget {
  final List<TextEditingController> checklistControllers;
  final VoidCallback addChecklistItem;
  final void Function(int) removeChecklistItem;

  const ChecklistSection({
    super.key,
    required this.checklistControllers,
    required this.addChecklistItem,
    required this.removeChecklistItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Task Checklist',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: addChecklistItem,
              icon: const Icon(Icons.add, size: 18, color: Color(0xFF005CE7)),
              label: const Text(
                'Add item',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF005CE7),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                foregroundColor: const Color(0xFF005CE7),
                splashFactory: InkRipple.splashFactory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(checklistControllers.length, (index) {
            final c = checklistControllers[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == checklistControllers.length - 1 ? 0 : 8),
              child: InputField(
                label: 'Item ${index + 1}',
                controller: c,
                hintText: 'Enter checklist item',
                isRequired: true,
                errorText: null,
                // Delete icon (no circular background)
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => removeChecklistItem(index),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
