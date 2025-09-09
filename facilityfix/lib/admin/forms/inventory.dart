import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // FilledButton
import 'package:facilityfix/widgets/forms.dart' hide DropdownField; // keep your InputField
import 'package:flutter/material.dart' hide FilledButton;
import 'package:flutter/services.dart'; // for inputFormatters
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/modals.dart'; // CustomPopup

class InventoryForm extends StatefulWidget {
  /// Steps: 'Inventory Form' | 'Stock & Supplier Details'
  final String requestType;
  const InventoryForm({super.key, required this.requestType});

  @override
  State<InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  // highlight the Inventory tab (index 4) in the bottom nav
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

  // ---------- Form key (for DropdownField validator) ----------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ---------- Controllers ----------
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController dateAddedController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController reorderLevelController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController warrantyController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  // For "Others" on Classification (separate InputField)
  final TextEditingController _classificationOtherCtrl = TextEditingController();

  // ---------- Dropdown values ----------
  String? classificationValue;
  String? tagValue;

  // ---------- Submit flags for error visibility ----------
  bool _submittedBasic = false; // step "Inventory Form"
  bool _submittedStock = false; // step "Stock & Supplier Details"

  // ---------- Step helpers ----------
  bool get _isFinalStep => widget.requestType == 'Stock & Supplier Details';

  // ---------- Error helpers (for text/numeric fields) ----------
  String? _errBasic(String key) {
    switch (key) {
      case 'name':
        return itemNameController.text.trim().isEmpty ? 'Item name is required' : null;
      case 'code':
        return itemCodeController.text.trim().isEmpty ? 'Item code is required' : null;
      case 'date':
        return dateAddedController.text.trim().isEmpty ? 'Date added is required' : null;
      case 'classification':
        final hasClass = classificationValue != null && classificationValue!.isNotEmpty;
        if (!hasClass) return 'Classification is required';
        if (classificationValue == 'Others' &&
            _classificationOtherCtrl.text.trim().isEmpty) {
          return 'Please specify classification';
        }
        return null;
      default:
        return null;
    }
  }

  String? _errStock(String key) {
    switch (key) {
      case 'quantity': {
        final raw = quantityController.text.trim();
        if (raw.isEmpty) return 'Quantity is required';
        final n = int.tryParse(raw);
        if (n == null) return 'Numbers only';
        if (n <= 0) return 'Must be greater than 0';
        return null;
      }
      case 'reorder': {
        final raw = reorderLevelController.text.trim();
        if (raw.isEmpty) return 'Reorder level is required';
        final n = int.tryParse(raw);
        if (n == null) return 'Numbers only';
        if (n <= 0) return 'Must be greater than 0';
        return null;
      }
      case 'contact': {
        // NOT REQUIRED: empty is fine; if provided, must be exactly 11 digits
        final raw = contactNumberController.text.trim();
        if (raw.isEmpty) return null;
        final isValid11 = RegExp(r'^\d{11}$').hasMatch(raw);
        return isValid11 ? null : 'Must be exactly 11 digits';
      }
      default:
        return null;
    }
  }

  // ---------- Actions ----------
  void _onPrimaryPressed() {
    // Let DropdownField validators run (Priority-style)
    final formOk = _formKey.currentState?.validate() ?? false;

    if (_isFinalStep) {
      setState(() => _submittedStock = true);

      final hasStockTextErrors =
          _errStock('quantity') != null ||
          _errStock('reorder')  != null ||
          _errStock('contact')  != null;

      if (!formOk || hasStockTextErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }

      _showRequestDialog(context);
    } else {
      setState(() => _submittedBasic = true);

      final hasBasicTextErrors =
          _errBasic('name')           != null ||
          _errBasic('code')           != null ||
          _errBasic('date')           != null ||
          _errBasic('classification') != null;

      if (!formOk || hasBasicTextErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const InventoryForm(
            requestType: 'Stock & Supplier Details',
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
        message:
            'Your ${widget.requestType.toLowerCase()} has been submitted successfully and is now listed under Inventory Requests.',
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

  // ---------- Bottom bar (exact design) ----------
  void _onSubmit() => _onPrimaryPressed();

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
            onPressed: _onSubmit,
          ),
        ),
      ),
    );
  }

  // ---------- Field listeners ----------
  void _attachFieldListeners() {
    for (final c in [
      itemNameController,
      itemCodeController,
      dateAddedController,
      quantityController,
      reorderLevelController,
      unitController,
      _classificationOtherCtrl,
      contactNumberController,
    ]) {
      c.addListener(_onAnyFieldChanged);
    }
  }

  void _detachFieldListeners() {
    for (final c in [
      itemNameController,
      itemCodeController,
      dateAddedController,
      quantityController,
      reorderLevelController,
      unitController,
      _classificationOtherCtrl,
      contactNumberController,
    ]) {
      c.removeListener(_onAnyFieldChanged);
    }
  }

  void _onAnyFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateAddedController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    itemCodeController.text =
        "INV-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}";
    _attachFieldListeners();
  }

  @override
  void dispose() {
    _detachFieldListeners();
    itemNameController.dispose();
    itemCodeController.dispose();
    dateAddedController.dispose();
    quantityController.dispose();
    reorderLevelController.dispose();
    unitController.dispose();
    supplierController.dispose();
    warrantyController.dispose();
    contactNumberController.dispose();
    _classificationOtherCtrl.dispose();
    super.dispose();
  }

  /// Builds fields based on which step we're on.
  List<Widget> getFormFields() {
    switch (widget.requestType) {
      // Step 1 – Basic Information
      case 'Inventory Form':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),

          const Text('Basic Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          InputField(
            label: 'Item Name',
            controller: itemNameController,
            hintText: 'Enter item name',
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('name') : null,
          ),
          InputField(
            label: 'Item Code',
            controller: itemCodeController,
            hintText: 'Auto-filled',
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('code') : null,
          ),
          InputField(
            label: 'Date Added',
            controller: dateAddedController,
            hintText: 'Auto-filled',
            readOnly: true,
            isRequired: true,
            errorText: _submittedBasic ? _errBasic('date') : null,
          ),

          // Classification (REQUIRED, DropdownField validator drives red outline)
          DropdownField<String>(
            label: 'Classification',
            value: classificationValue,
            items: const [
              'Lighting',
              'Fasteners',
              'Tools',
              'Materials',
              'Consumables',
              'PPE',
              'HVAC',
              'Electrical Fixtures',
              'Plumbing Parts',
              'Others',
            ],
            onChanged: (v) {
              setState(() => classificationValue = v);
              _formKey.currentState?.validate(); // update outline immediately
            },
            isRequired: true,
            requiredMessage: 'Classification is required.',
            otherController: _classificationOtherCtrl,
          ),

          const SizedBox(height: 12),
          if (classificationValue == 'Others')
            InputField(
              label: 'Specify Classification',
              controller: _classificationOtherCtrl,
              hintText: 'e.g., Paints/Coatings',
              isRequired: true,
              errorText: _submittedBasic ? _errBasic('classification') : null,
            ),
        ];

      // Step 2 – Stock & Supplier Details
      case 'Stock & Supplier Details':
        return [
          const Text('Detail Information', style: TextStyle(fontSize: 20)),
          const Text('Enter Detail Information', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('Stock Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          InputField(
            label: 'Quantity In Stock',
            controller: quantityController,
            hintText: 'Enter quantity',
            isRequired: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            errorText: _submittedStock ? _errStock('quantity') : null,
          ),
          InputField(
            label: 'Reorder Level',
            controller: reorderLevelController,
            hintText: 'Enter reorder level',
            isRequired: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            errorText: _submittedStock ? _errStock('reorder') : null,
          ),

          // Unit (REQUIRED, DropdownField validator drives red outline)
          DropdownField<String>(
            label: 'Unit',
            value: unitController.text.isEmpty ? null : unitController.text,
            items: const ['pcs', 'box', 'set', 'pack', 'roll', 'litre', 'kg', 'gal'],
            onChanged: (v) {
              setState(() => unitController.text = v ?? '');
              _formKey.currentState?.validate(); // update outline immediately
            },
            isRequired: true,
            requiredMessage: 'Unit is required.',
          ),

          const SizedBox(height: 12),

          // Tag (REQUIRED, DropdownField validator drives red outline)
          DropdownField<String>(
            label: 'Tag',
            value: tagValue,
            items: const ['High-Turnover', 'Critical-Use', 'Repair-Prone'],
            onChanged: (v) {
              setState(() => tagValue = v);
              _formKey.currentState?.validate(); // update outline immediately
            },
            isRequired: true,
            requiredMessage: 'Tag is required.',
          ),

          const SizedBox(height: 12),
          const Text('Supplier Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          InputField(
            label: 'Supplier',
            controller: supplierController,
            hintText: 'Enter supplier name',
          ),

          // NOT REQUIRED, but if provided must be exactly 11 digits
          InputField(
            label: 'Contact Number',
            controller: contactNumberController,
            hintText: '11-digit mobile number (optional)',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            isRequired: false,
            errorText: _submittedStock ? _errStock('contact') : null,
          ),

          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  warrantyController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                });
              }
            },
            child: AbsorbPointer(
              child: InputField(
                label: 'Warranty Until',
                controller: warrantyController,
                hintText: 'Select date',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ];

      default:
        return [const Text('Invalid request type')];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirror MaintenanceForm behavior: turn on autovalidate after first attempt
    final autovalidate = (_submittedBasic || _submittedStock)
        ? AutovalidateMode.always
        : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _isFinalStep ? 'Stock & Supplier Details' : 'Add Inventory Item',
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Form( // wrap to enable validate() on dropdown change
          key: _formKey,
          autovalidateMode: autovalidate,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [...getFormFields()],
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
