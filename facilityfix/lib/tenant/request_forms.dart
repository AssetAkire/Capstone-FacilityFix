import 'dart:async';
import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart' as fx;
import 'package:facilityfix/widgets/forms.dart';
import 'package:facilityfix/widgets/modals.dart'; // CustomPopup
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:intl/intl.dart';

class RequestForm extends StatefulWidget {
  /// Allowed: "Concern Slip", "Job Service", "Work Order"
  final String requestType;

  const RequestForm({
    super.key,
    required this.requestType,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
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
    if (index != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  // ----- Form + validation -----
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false; // <- drives inline error visibility

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  final List<String> _requestTypes = const [
    'Air Conditioning',
    'Electrical',
    'Civil/Carpentry',
    'Plumbing',
    'Others',
  ];

  // Date/Time picking
  Future<void> _pickDateTimeInto(TextEditingController controller) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      controller.text = DateFormat('MMM d, yyyy h:mm a').format(dt);
      // Recompute inline errors after picking a date
      _formKey.currentState?.validate();
    });
  }

  // Controllers
  final TextEditingController reqIdController = TextEditingController();
  final TextEditingController dateRequestedController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController permitIdController = TextEditingController();
  final TextEditingController validFromController = TextEditingController();
  final TextEditingController validToController = TextEditingController();

  // Local state
  String _requestTypeValue = ''; // dropdown selection for work order type
  bool _hasContractors = false;  // list not empty?
  PlatformFile? selectedFile;

  @override
  void initState() {
    super.initState();
    // Prefill some common "Auto-filled" values (replace with real auth/unit data)
    final now = DateTime.now();
    dateRequestedController.text = DateFormat('MMM d, yyyy h:mm a').format(now);
    reqIdController.text = 'REQ-${now.millisecondsSinceEpoch.toString().substring(5)}';
    unitController.text = 'Tower A - Unit 10B';
    nameController.text = 'John Doe';

    // For Work Order -> permit
    permitIdController.text = 'PERMIT-${now.year}${now.month.toString().padLeft(2, '0')}-0012';
  }

  @override
  void dispose() {
    reqIdController.dispose();
    dateRequestedController.dispose();
    unitController.dispose();
    nameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    availabilityController.dispose();
    permitIdController.dispose();
    validFromController.dispose();
    validToController.dispose();
    super.dispose();
  }

  // ----- Success dialog sending user to Work Order Management -----
  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message:
            'Your ${widget.requestType.toLowerCase()} has been submitted successfully and is now listed under Work Order Management.',
        primaryText: 'Go to Work Orders',
        onPrimaryPressed: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkOrderPage()),
          );
        },
      ),
    );
  }

  // ----- Parsing + inline error helpers -----
  DateTime? _parseDT(String value) {
    try {
      return DateFormat('MMM d, yyyy h:mm a').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  // Concern Slip errors
  String? _errCS(String key) {
    if (!_submitted) return null;
    switch (key) {
      case 'title':
        return titleController.text.trim().isEmpty ? 'Task title is required.' : null;
      case 'desc':
        return descriptionController.text.trim().isEmpty ? 'Description is required.' : null;
      case 'avail':
        if (availabilityController.text.trim().isEmpty) return 'Availability is required.';
        return _parseDT(availabilityController.text.trim()) == null
            ? 'Invalid date & time.'
            : null;
      default:
        return null;
    }
  }

  // Job Service errors
  String? _errJS(String key) {
    if (!_submitted) return null;
    switch (key) {
      case 'notes':
        return descriptionController.text.trim().isEmpty ? 'Notes are required.' : null;
      case 'avail':
        if (availabilityController.text.trim().isEmpty) return 'Availability is required.';
        return _parseDT(availabilityController.text.trim()) == null
            ? 'Invalid date & time.'
            : null;
      default:
        return null;
    }
  }

  // Work Order errors
  String? _errWO(String key) {
    if (!_submitted) return null;
    switch (key) {
      case 'type':
        return _requestTypeValue.trim().isEmpty ? 'Request type is required.' : null;
      case 'from':
        if (validFromController.text.trim().isEmpty) return 'Start is required.';
        return _parseDT(validFromController.text.trim()) == null ? 'Invalid date & time.' : null;
      case 'to':
        if (validToController.text.trim().isEmpty) return 'End is required.';
        final from = _parseDT(validFromController.text.trim());
        final to = _parseDT(validToController.text.trim());
        if (to == null) return 'Invalid date & time.';
        if (from != null && !to.isAfter(from)) return 'End must be later than start.';
        return null;
      case 'contractors':
        return !_hasContractors ? 'Please add at least one contractor/personnel.' : null;
      default:
        return null;
    }
  }

  bool _hasAnyErrorForType(String type) {
    switch (type) {
      case 'Concern Slip':
        return _errCS('title') != null ||
            _errCS('desc') != null ||
            _errCS('avail') != null;
      case 'Job Service':
        return _errJS('notes') != null ||
            _errJS('avail') != null;
      case 'Work Order':
        return _errWO('type') != null ||
            _errWO('from') != null ||
            _errWO('to') != null ||
            _errWO('contractors') != null;
      default:
        return true;
    }
  }

  void _onSubmit() {
    // Mark as submitted so errorText becomes visible
    setState(() => _submitted = true);

    // Also run any internal validators the custom fields may have
    _formKey.currentState?.validate();

    final type = widget.requestType.trim();
    if (_hasAnyErrorForType(type)) {
      _showSnack('Please correct the highlighted fields.');
      return;
    }

    // Passed all checks → show success dialog
    _showRequestDialog(context);
  }

  // ----- UI sections -----
  List<Widget> getFormFields() {
    switch (widget.requestType) {
      case 'Concern Slip':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('Basic Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                label: 'Request Id',
                controller: reqIdController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Date Requested',
                controller: dateRequestedController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Building & Unit No.',
                controller: unitController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Name',
                controller: nameController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Request Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                label: 'Task Title',
                controller: titleController,
                hintText: 'Enter Task Title',
                isRequired: true,
                errorText: _errCS('title'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Description',
                controller: descriptionController,
                hintText: 'Enter task description',
                isRequired: true,
                maxLines: 4,
                errorText: _errCS('desc'),
              ),
              InputField(
                label: 'Availability',
                controller: availabilityController,
                hintText: 'Select preferred date & time',
                isRequired: true,
                readOnly: true,
                onTap: () => _pickDateTimeInto(availabilityController),
                errorText: _errCS('avail'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 8),
              const FileAttachmentPicker(label: 'Upload Attachment'),
            ],
          ),
        ];

      case 'Job Service':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('Basic Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                label: 'Request Id',
                controller: reqIdController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Date Requested',
                controller: dateRequestedController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Building & Unit No.',
                controller: unitController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Name',
                controller: nameController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Request Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                label: 'Notes',
                controller: descriptionController,
                hintText: 'Enter additional notes',
                isRequired: true,
                maxLines: 4,
                errorText: _errJS('notes'),
              ),
              InputField(
                label: 'Availability',
                controller: availabilityController,
                hintText: 'Select preferred date & time',
                isRequired: true,
                readOnly: true,
                onTap: () => _pickDateTimeInto(availabilityController),
                errorText: _errJS('avail'),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 8),
              const FileAttachmentPicker(label: 'Upload Attachment'),
            ],
          ),
        ];

      case 'Work Order':
        return [
          const Text('Permit Validation', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('Basic Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                label: 'Request Id',
                controller: reqIdController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Date Requested',
                controller: dateRequestedController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Building & Unit No.',
                controller: unitController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 8),
              InputField(
                label: 'Name',
                controller: nameController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Permit Validation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              // Request Type (dropdown w/ required message)
              DropdownField<String>(
                label: 'Request Type',
                value: _requestTypeValue.isEmpty ? null : _requestTypeValue,
                items: _requestTypes,
                onChanged: (v) {
                  setState(() => _requestTypeValue = v ?? '');
                  _formKey.currentState?.validate();
                },
                isRequired: _submitted,                      // only show built-in error after submit
                requiredMessage: 'Request type is required.',
                hintText: 'Select request type',
              ),
              // Also show our explicit errorText slot if your DropdownField supports it:
              if (_errWO('type') != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(_errWO('type')!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 8),

              // Valid From / Valid To (two-up row, blue calendar icon) with inline errors
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDateTimeInto(validFromController),
                      child: AbsorbPointer(
                        child: InputField(
                          label: 'Valid From',
                          controller: validFromController,
                          hintText: 'Select date & time',
                          isRequired: true,
                          suffixIcon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Color(0xFF005CE7),
                          ),
                          errorText: _errWO('from'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDateTimeInto(validToController),
                      child: AbsorbPointer(
                        child: InputField(
                          label: 'Valid To',
                          controller: validToController,
                          hintText: 'Select date & time',
                          isRequired: true,
                          suffixIcon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Color(0xFF005CE7),
                          ),
                          errorText: _errWO('to'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text('List of Contractors/Personnel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              MultiContractorInputField(
                isRequired: true,
                onChanged: (contractorList) {
                  setState(() => _hasContractors = (contractorList?.isNotEmpty ?? false));
                },
              ),
              if (_errWO('contractors') != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(_errWO('contractors')!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
        ];

      default:
        // Graceful fallback: show a helpful message instead of a hard error.
        return [
          const SizedBox(height: 16),
          Text(
            'Unsupported form: "${widget.requestType}". Please go back and choose a valid request type.',
            style: const TextStyle(color: Colors.red),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.requestType) {
      'Concern Slip' => 'New Concern Slip',
      'Job Service'  => 'New Job Service',
      'Work Order'   => 'New Work Order Permit',
      _               => 'New Request',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: title,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...getFormFields(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      // Sticky action + NavBar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                child: fx.FilledButton(
                  label: 'Create Task',
                  backgroundColor: const Color(0xFF005CE7),
                  withOuterBorder: false,
                  elevation: 0,
                  onPressed: _onSubmit,
                ),
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
