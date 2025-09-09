import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // FilledButton
import 'package:facilityfix/widgets/forms.dart';   // InputField, FileAttachmentPicker
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/modals.dart';  // <-- CustomPopup
import 'package:flutter/material.dart' hide FilledButton;

class AssessmentForm extends StatefulWidget {
  /// Optional context string for where the assessment is coming from (e.g., a WO title or id)
  final String? requestType;

  const AssessmentForm({super.key, this.requestType});

  @override
  State<AssessmentForm> createState() => _AssessmentFormState();
}

class _AssessmentFormState extends State<AssessmentForm> {
  // Highlight Work tab for staff
  int _selectedIndex = 1;

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

  // -------- Controllers --------
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateAssessedController = TextEditingController();
  final TextEditingController assessmentController = TextEditingController();
  final TextEditingController recommendationController = TextEditingController();

  // -------- Error states --------
  String? _assessmentError;
  String? _recommendationError;

  @override
  void initState() {
    super.initState();
    // Prefill (replace with authed user + server time as needed)
    nameController.text = 'Juan Dela Cruz';
    final now = DateTime.now();
    dateAssessedController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    nameController.dispose();
    dateAssessedController.dispose();
    assessmentController.dispose();
    recommendationController.dispose();
    super.dispose();
  }

  // 🔹 Success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message:
            'Your assessment has been submitted successfully and is now recorded under Work Orders.',
        primaryText: 'Go to Work Orders',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkOrderPage()),
          );
        },
      ),
    );
  }

  bool _validateFields() {
    String? assessErr;
    String? recErr;

    if (assessmentController.text.trim().isEmpty) {
      assessErr = 'Assessment is required';
    }
    if (recommendationController.text.trim().isEmpty) {
      recErr = 'Recommendation is required';
    }

    setState(() {
      _assessmentError = assessErr;
      _recommendationError = recErr;
    });

    return assessErr == null && recErr == null;
  }

  void _submit() {
    if (_validateFields()) {
      _showSuccessDialog(context); // ✅ Show dialog instead of snackbar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the highlighted fields.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = (widget.requestType != null && widget.requestType!.trim().isNotEmpty)
        ? 'for ${widget.requestType}'
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: const BackButton(),
        title: 'Assessment & Recommendation',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Detail Information', style: TextStyle(fontSize: 20)),
                Text('Enter Detail Information $subtitle', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),

                const Text('Basic Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                InputField(
                  label: 'Full Name',
                  controller: nameController,
                  hintText: 'Auto-filled',
                  isRequired: true,
                  readOnly: true,
                ),
                InputField(
                  label: 'Date Assessed',
                  controller: dateAssessedController,
                  hintText: 'Auto-filled',
                  isRequired: true,
                  readOnly: true,
                ),

                const SizedBox(height: 16),
                const Text('Assessment and Recommendation',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                InputField(
                  label: 'Assessment',
                  controller: assessmentController,
                  hintText: 'Enter assessment',
                  isRequired: true,
                  maxLines: 4,
                  errorText: _assessmentError,
                ),
                const SizedBox(height: 8),
                InputField(
                  label: 'Recommendation',
                  controller: recommendationController,
                  hintText: 'Enter recommendation',
                  isRequired: true,
                  maxLines: 4,
                  errorText: _recommendationError,
                ),

                const SizedBox(height: 8),
                const Text('Attachment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const FileAttachmentPicker(label: 'Upload Attachment'),
              ],
            ),
          ),
        ),
      ),

      // ✅ Sticky bottom button + NavBar
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
                child: FilledButton(
                  label: 'Submit Assessment',
                  backgroundColor: const Color(0xFF005CE7),
                  textColor: Colors.white,
                  withOuterBorder: false,
                  onPressed: _submit,
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
