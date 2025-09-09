import 'package:flutter/material.dart' hide FilledButton;
import 'package:flutter/services.dart';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // FilledButton
import 'package:facilityfix/widgets/forms.dart' hide DropdownField;   // InputField + DropdownField
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/modals.dart'; // CustomPopup

class InventoryFormSteps {
  static const basic = 'Basic Information';
  static const item  = 'Item Details';

  static bool isValid(String s) => s == basic || s == item;
}

class InventoryForm extends StatefulWidget {
  final String requestType;
  const InventoryForm({super.key, required this.requestType});

  @override
  State<InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  int _selectedIndex = 4;

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Basic Info controllers
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController dateRequestedController = TextEditingController();
  final TextEditingController requestedByController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController neededByController = TextEditingController();

  // Item Details controllers
  final TextEditingController requestQuantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final TextEditingController _classificationOtherCtrl = TextEditingController();

  bool _submittedBasic = false;
  bool _submittedItem = false;

  String get _currentStep =>
      InventoryFormSteps.isValid(widget.requestType)
          ? widget.requestType
          : InventoryFormSteps.basic;

  bool get _isFinalStep => _currentStep == InventoryFormSteps.item;

  // ---- Error helpers
  String? _errBasic(String key) {
    switch (key) {
      case 'name':
        return itemNameController.text.trim().isEmpty ? 'Item name is required' : null;
      case 'code':
        return itemCodeController.text.trim().isEmpty ? 'Item code is required' : null;
      case 'dateRequested':
        return dateRequestedController.text.trim().isEmpty ? 'Date requested is required' : null;
      case 'requestedBy':
        return requestedByController.text.trim().isEmpty ? 'Requested by is required' : null;
      case 'department':
        return departmentController.text.trim().isEmpty ? 'Department is required' : null;
      case 'neededBy':
        return neededByController.text.trim().isEmpty ? 'Needed by is required' : null;
      default:
        return null;
    }
  }

  String? _errItem(String key) {
    switch (key) {
      case 'quantity': {
        final raw = requestQuantityController.text.trim();
        if (raw.isEmpty) return 'Request quantity is required';
        final n = int.tryParse(raw);
        if (n == null) return 'Numbers only';
        if (n <= 0) return 'Must be greater than 0';
        return null;
      }
      case 'unit':
        return unitController.text.trim().isEmpty ? 'Unit is required' : null;
      default:
        return null;
    }
  }

  // ---- Actions
  void _onPrimaryPressed() {
    final formOk = _formKey.currentState?.validate() ?? false;

    if (_isFinalStep) {
      setState(() => _submittedItem = true);

      final hasItemErrors =
          _errItem('quantity')  != null ||
          _errItem('unit')      != null;

      if (!formOk || hasItemErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }

      _showRequestDialog(context);
    } else {
      setState(() => _submittedBasic = true);

      final hasBasicErrors =
          _errBasic('name')          != null ||
          _errBasic('code')          != null ||
          _errBasic('dateRequested') != null ||
          _errBasic('requestedBy')   != null ||
          _errBasic('department')    != null ||
          _errBasic('neededBy')      != null;

      if (!formOk || hasBasicErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const InventoryForm(
            requestType: InventoryFormSteps.item,
          ),
        ),
      );
    }
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message: 'Your request has been submitted successfully and is now listed under Inventory Requests.',
        primaryText: 'Go to Inventory',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InventoryPage()),
          );
        },
      ),
    );
  }

  // ---- Bottom bar
  Widget _buildBottomBar() {
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
            label: _isFinalStep ? 'Submit' : 'Next',
            backgroundColor: const Color(0xFF005CE7),
            textColor: Colors.white,
            withOuterBorder: false,
            onPressed: _onPrimaryPressed,
          ),
        ),
      ),
    );
  }

  // ---- Lifecycle
  void _attachFieldListeners() {
    for (final c in [
      itemNameController,
      itemCodeController,
      dateRequestedController,
      requestedByController,
      departmentController,
      neededByController,
      requestQuantityController,
      unitController,
      notesController,
      _classificationOtherCtrl,
    ]) {
      c.addListener(_onAnyFieldChanged);
    }
  }

  void _detachFieldListeners() {
    for (final c in [
      itemNameController,
      itemCodeController,
      dateRequestedController,
      requestedByController,
      departmentController,
      neededByController,
      requestQuantityController,
      unitController,
      notesController,
      _classificationOtherCtrl,
    ]) {
      c.removeListener(_onAnyFieldChanged);
    }
  }

  void _onAnyFieldChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickNeededByDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      neededByController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    dateRequestedController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    itemCodeController.text =
        "INV-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}";
    requestedByController.text = 'CMO Staff';
    departmentController.text  = 'Maintenance';

    _attachFieldListeners();
  }

  @override
  void dispose() {
    _detachFieldListeners();
    itemNameController.dispose();
    itemCodeController.dispose();
    dateRequestedController.dispose();
    requestedByController.dispose();
    departmentController.dispose();
    neededByController.dispose();
    requestQuantityController.dispose();
    unitController.dispose();
    notesController.dispose();
    _classificationOtherCtrl.dispose();
    super.dispose();
  }

  // ---- Form fields by step
  List<Widget> _getFormFields() {
    switch (_currentStep) {
      case InventoryFormSteps.basic:
        return [
          const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          InputField(
            label: 'Item Code',
            controller: itemCodeController,
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('code') : null,
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Date Requested',
            controller: dateRequestedController,
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('dateRequested') : null,
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Item Name',
            controller: itemNameController,
            hintText: 'Enter item name',
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('name') : null,
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Requested By',
            controller: requestedByController,
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('requestedBy') : null,
          ),
          const SizedBox(height: 12),
          InputField(
            label: 'Department',
            controller: departmentController,
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('department') : null,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickNeededByDate,
            child: AbsorbPointer(
              child: InputField(
                label: 'Needed By',
                controller: neededByController,
                hintText: 'Pick date',
                isRequired: true,
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                errorText: _submittedBasic ? _errBasic('neededBy') : null,
              ),
            ),
          ),
        ];

      case InventoryFormSteps.item:
      return [
        const Text(
          'Item Request Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Request Quantity
        InputField(
          label: 'Request Quantity',
          controller: requestQuantityController,
          keyboardType: TextInputType.number,
          hintText: 'Enter quantity (e.g. 10)',
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          errorText: _submittedItem ? _errItem('quantity') : null,
        ),
        const SizedBox(height: 12),

        // Unit
        DropdownField<String>(
          label: 'Unit',
          value: unitController.text.isEmpty ? null : unitController.text,
          items: const ['pcs', 'box', 'set', 'pack', 'roll', 'litre', 'kg', 'gal'],
          onChanged: (v) {
            setState(() => unitController.text = v ?? '');
            _formKey.currentState?.validate();
          },
          isRequired: true,
          requiredMessage: 'Unit is required.',
          hintText: 'Select unit of measurement',
        ),
        const SizedBox(height: 12),

        // Notes
        InputField(
          label: 'Notes (optional)',
          controller: notesController,
          hintText: 'Add remarks, special instructions, or purpose',
          maxLines: 4,
        ),
      ];

      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final autovalidate = (_submittedBasic || _submittedItem)
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _isFinalStep ? InventoryFormSteps.item : 'Add Inventory Item',
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidate,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getFormFields(),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
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
