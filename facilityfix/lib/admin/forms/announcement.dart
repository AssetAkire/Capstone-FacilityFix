import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // FilledButton
import 'package:facilityfix/widgets/forms.dart' hide DropdownField; // use BOTH: InputField + DropdownField
import 'package:flutter/material.dart' hide FilledButton; // hide Flutter FilledButton
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/modals.dart'; // CustomPopup

class AnnouncementForm extends StatefulWidget {
  final String requestType;

  const AnnouncementForm({super.key, required this.requestType});

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  // ---------------- Form & Nav ----------------
  final _formKey = GlobalKey<FormState>();
  int _selectedIndex = 2;

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
    }
  }

  // ---------------- Date/Time State ----------------
  DateTime? _visibilityFromDT;
  DateTime? _visibilityToDT;
  DateTime? _postingDT; // optional

  Future<void> _pickVisibilityFrom() async {
    final dt = await _pickDateTime();
    if (dt != null) {
      setState(() {
        _visibilityFromDT = dt;
        scheduleVisibilityFromController.text = _formatDT(dt);
      });
      _maybeRevalidate();
    }
  }

  Future<void> _pickVisibilityTo() async {
    final dt = await _pickDateTime();
    if (dt != null) {
      setState(() {
        _visibilityToDT = dt;
        scheduleVisibilityToController.text = _formatDT(dt);
      });
      _maybeRevalidate();
    }
  }

  Future<void> _pickPosting() async {
    final dt = await _pickDateTime();
    if (dt != null) {
      setState(() {
        _postingDT = dt;
        schedulePostingController.text = _formatDT(dt);
      });
      _maybeRevalidate();
    }
  }

  Future<DateTime?> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _formatDT(DateTime dt) =>
      "${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}";

  void _maybeRevalidate() {
    if (_submitted) {
      _formKey.currentState?.validate(); // refresh red borders
      setState(() {}); // refresh captions
    }
  }

  // ---------------- Controllers ----------------
  final TextEditingController audienceController = TextEditingController();
  final TextEditingController noticeTypeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final TextEditingController scheduleVisibilityFromController =
      TextEditingController();
  final TextEditingController scheduleVisibilityToController =
      TextEditingController();
  final TextEditingController schedulePostingController =
      TextEditingController();

  // Optional “Others” inputs (if you use Others in dropdowns)
  final TextEditingController audienceOtherController = TextEditingController();
  final TextEditingController noticeTypeOtherController = TextEditingController();

  // ---------------- Maintenance-style flags ----------------
  bool _submitted = false;

  // ---------------- Tiny 4px caption style ----------------
  static const TextStyle _kErr4px = TextStyle(
    color: Color(0xFFD92D20),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 0.33, // ~4px line height
  );

  Widget _errorCaption(String? msg) {
    if (msg == null || msg.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(msg, style: _kErr4px),
    );
  }

  // ---------------- Error calculators ----------------
  String? _errDescription() {
    final txt = descriptionController.text.trim();
    if (txt.isEmpty) return 'Description is required.';
    if (txt.length < 10) return 'Please enter at least 10 characters.';
    return null;
  }

  String? _errLocation() {
    if (locationController.text.trim().isEmpty) return 'Location is required.';
    return null;
  }

  String? _errSchedule() {
    // optional: if both blank → no error
    if (scheduleVisibilityFromController.text.trim().isEmpty &&
        scheduleVisibilityToController.text.trim().isEmpty) {
      return null;
    }

    if (scheduleVisibilityFromController.text.trim().isEmpty ||
        scheduleVisibilityToController.text.trim().isEmpty) {
      return 'Both From and To are required if one is set.';
    }

    if (_visibilityFromDT != null &&
        _visibilityToDT != null &&
        _visibilityFromDT!.isAfter(_visibilityToDT!)) {
      return 'Visibility "From" must be before "To".';
    }

    return null;
  }

  String? _errPosting() {
    if (_postingDT != null && _visibilityFromDT != null) {
      if (_postingDT!.isAfter(_visibilityFromDT!)) {
        return 'Posting must be on/before Visibility From.';
      }
    }
    return null;
  }

  bool _hasAnyError() {
    if (audienceController.text.trim().isEmpty) return true;
    if (noticeTypeController.text.trim().isEmpty) return true;
    if (_errDescription() != null) return true;
    if (_errLocation() != null) return true;
    if (_errSchedule() != null) return true;
    if (_errPosting() != null) return true;
    return false;
  }

  // ---------------- Form body ----------------
  List<Widget> _formFields() {
    return [
      const Text('Detail Information', style: TextStyle(fontSize: 20)),
      const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
      const SizedBox(height: 8),

      // Audience
      DropdownField<String>(
        label: 'Audience',
        items: const ['Tenant', 'Staff', 'All', 'Others'],
        value: audienceController.text.isEmpty ? null : audienceController.text,
        onChanged: (v) => setState(() => audienceController.text = v ?? ''),
        isRequired: _submitted,
        requiredMessage: 'Audience is required.',
        hintText: 'Select audience',
        otherController: audienceOtherController,
      ),

      // Notice Type
      DropdownField<String>(
        label: 'Notice Type',
        items: const [
          'Scheduled Maintenance',
          'Utility Interruption',
          'Safety Inspection',
          'Facility Works',
          'General Announcement',
          'Pest Control',
          'Power Outage',
          'Others',
        ],
        value: noticeTypeController.text.isEmpty ? null : noticeTypeController.text,
        onChanged: (v) => setState(() => noticeTypeController.text = v ?? ''),
        isRequired: _submitted,
        requiredMessage: 'Notice type is required.',
        hintText: 'Select notice type',
        otherController: noticeTypeOtherController,
      ),


      // Description
      InputField(
        label: 'Description / Message Body',
        controller: descriptionController,
        hintText: 'Enter announcement details',
        isRequired: true,
        maxLines: 4,
      ),
      if (_submitted) _errorCaption(_errDescription()),

      const SizedBox(height: 8),

      // Location
      InputField(
        label: 'Location (Affected Area)',
        controller: locationController,
        hintText: 'Enter location',
        isRequired: true,
      ),
      if (_submitted) _errorCaption(_errLocation()),

      const SizedBox(height: 12),

      const Text('Schedule Visibility (Optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),

      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickVisibilityFrom,
              child: AbsorbPointer(
                child: InputField(
                  label: 'From',
                  controller: scheduleVisibilityFromController,
                  hintText: 'Select date & time',
                  isRequired: false, 
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 20, color: Color(0xFF005CE7)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _pickVisibilityTo,
              child: AbsorbPointer(
                child: InputField(
                  label: 'To',
                  controller: scheduleVisibilityToController,
                  hintText: 'Select date & time',
                  isRequired: false,
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
                      size: 20, color: Color(0xFF005CE7)),
                ),
              ),
            ),
          ),
        ],
      ),
      if (_submitted) _errorCaption(_errSchedule()),

      const SizedBox(height: 8),

      // Posting (optional)
      GestureDetector(
        onTap: _pickPosting,
        child: AbsorbPointer(
          child: InputField(
            label: 'Schedule Posting (Optional)',
            controller: schedulePostingController,
            hintText: 'Select date & time (optional)',
            isRequired: false,
            suffixIcon: const Icon(Icons.calendar_today_rounded,
                size: 20, color: Color(0xFF005CE7)),
          ),
        ),
      ),
      if (_submitted) _errorCaption(_errPosting()),

      const SizedBox(height: 8),
    ];
  }

  // ---------------- Submit ----------------
  void _onSubmit() {
    _submitted = true;

    _formKey.currentState?.validate();
    setState(() {}); // refresh captions

    if (_hasAnyError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
      return;
    }

    _showRequestDialog(context);
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message:
            'Your ${widget.requestType.toLowerCase()} has been submitted successfully and is now listed under Announcements.',
        primaryText: 'Go to Announcements',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AnnouncementPage()),
          );
        },
      ),
    );
  }

  // ---------------- Bottom Submit Bar ----------------
  Widget _buildBottomSubmitBar() {
    return SafeArea(
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
            label: 'Submit',
            backgroundColor: const Color(0xFF005CE7),
            textColor: Colors.white,
            withOuterBorder: false,
            onPressed: _onSubmit,
          ),
        ),
      ),
    );
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    final autovalidate =
        _submitted ? AutovalidateMode.always : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'New Announcement',
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
                      ..._formFields(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSubmitBar(),
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
