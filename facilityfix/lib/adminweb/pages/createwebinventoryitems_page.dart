import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../services/api_service.dart';
import '../../services/auth_storage.dart';

class InventoryItemCreatePage extends StatefulWidget {
  const InventoryItemCreatePage({super.key});

  @override
  State<InventoryItemCreatePage> createState() =>
      _InventoryItemCreatePageState();
}

class _InventoryItemCreatePageState extends State<InventoryItemCreatePage> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemCodeController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _supplierController = TextEditingController();
  final _warrantyDateController = TextEditingController();

  bool _isValidationEnabled = false;
  bool _isSaving = false;

  String? _selectedClassification;
  String? _selectedDepartment;
  String? _selectedUnit;
  String? _selectedTag;

  final String _buildingId = 'default_building_id';

  final List<String> _classifications = [
    'Materials',
    'Tools',
    'Equipment',
    'Consumables',
    'Spare Parts',
  ];

  final List<String> _departments = [
    'Civil/Carpentry',
    'Electrical',
    'Plumbing',
    'HVAC',
    'General Maintenance',
  ];

  final List<String> _units = [
    'pcs',
    'box',
    'set',
    'roll',
    'kg',
    'liter',
    'meter',
    'pack',
  ];

  final List<String> _tags = [
    'High-Turnover',
    'Critical',
    'Essential',
    'Standard',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        print('[v0] Auth token retrieved and set in API service');
      } else {
        print('[v0] Warning: No auth token found in storage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[v0] Error retrieving auth token: $e');
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _brandNameController.dispose();
    _quantityController.dispose();
    _reorderLevelController.dispose();
    _supplierController.dispose();
    _warrantyDateController.dispose();
    super.dispose();
  }

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

  Future<void> _selectWarrantyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _warrantyDateController.text =
            "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (!_isValidationEnabled) return null;
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateItemCode(String? value) {
    if (!_isValidationEnabled) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Item Code is required';
    }
    final regex = RegExp(r'^[A-Z0-9]+-[A-Z0-9]+-[0-9]+$');
    if (!regex.hasMatch(value.toUpperCase())) {
      return 'Format: AAA-BBB-123 (e.g., MAT-CIV-003)';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (!_isValidationEnabled) return null;
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  String? _validateDropdown(String? value, String fieldName) {
    if (!_isValidationEnabled) return null;
    if (value == null || value.isEmpty) {
      return 'Please select $fieldName';
    }
    return null;
  }

  Future<void> _handleSave() async {
    setState(() {
      _isValidationEnabled = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final itemData = {
      'building_id': _buildingId,
      'item_name': _itemNameController.text.trim(),
      'item_code': _itemCodeController.text.trim().toUpperCase(),
      'classification': _selectedClassification,
      'department': _selectedDepartment,
      'brand_name':
          _brandNameController.text.trim().isEmpty
              ? '-'
              : _brandNameController.text.trim(),
      'current_stock': int.parse(_quantityController.text.trim()),
      'reorder_level': int.parse(_reorderLevelController.text.trim()),
      'unit': _selectedUnit,
      'is_critical': _selectedTag == 'Critical',
      'supplier':
          _supplierController.text.trim().isEmpty
              ? 'Not Specified'
              : _supplierController.text.trim(),
      'warranty_until':
          _warrantyDateController.text.trim().isEmpty
              ? null
              : _warrantyDateController.text.trim(),
    };

    try {
      final response = await _apiService.createInventoryItem(itemData);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (response['success'] == true) {
          final createdItemId = response['item_id'] ?? itemData['item_code'];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          context.go('/inventory/item/$createdItemId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${response['message'] ?? 'Failed to create item'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[v0] Error creating inventory item: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _determineStatus(int quantity, int reorderLevel) {
    if (quantity == 0) {
      return 'Out of Stock';
    } else if (quantity <= reorderLevel) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  void _handleCancel() {
    bool hasData =
        _itemNameController.text.isNotEmpty ||
        _itemCodeController.text.isNotEmpty ||
        _selectedClassification != null ||
        _selectedDepartment != null ||
        _brandNameController.text.isNotEmpty ||
        _quantityController.text.isNotEmpty ||
        _reorderLevelController.text.isNotEmpty ||
        _selectedUnit != null ||
        _selectedTag != null ||
        _supplierController.text.isNotEmpty ||
        _warrantyDateController.text.isNotEmpty;

    if (hasData) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'Are you sure you want to discard this new item? All entered data will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Editing'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/inventory/items');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          );
        },
      );
    } else {
      context.go('/inventory/items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'inventory_items',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode:
              _isValidationEnabled
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create New Item",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => context.go('/dashboard'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text('Dashboard'),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 16,
                          ),
                          TextButton(
                            onPressed: () => context.go('/inventory/items'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text('Inventory Management'),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text('Create Item'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving ? null : _handleCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSave,
                        icon:
                            _isSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.save, size: 18),
                        label: Text(
                          _isSaving ? "Saving..." : "Save Item",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      "Basic Information",
                      Icons.info_outline,
                      const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _itemNameController,
                                label: "Item Name",
                                hint: "e.g., Galvanized Screw 3mm",
                                validator:
                                    (value) =>
                                        _validateRequired(value, 'Item Name'),
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _itemCodeController,
                                label: "Item Code",
                                hint: "e.g., MAT-CIV-003",
                                validator: _validateItemCode,
                                isRequired: true,
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField(
                                label: "Classification",
                                value: _selectedClassification,
                                items: _classifications,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClassification = value;
                                  });
                                },
                                validator:
                                    (value) => _validateDropdown(
                                      value,
                                      'Classification',
                                    ),
                                isRequired: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        Expanded(
                          child: Column(
                            children: [
                              _buildDropdownField(
                                label: "Department",
                                value: _selectedDepartment,
                                items: _departments,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value;
                                  });
                                },
                                validator:
                                    (value) =>
                                        _validateDropdown(value, 'Department'),
                                isRequired: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _brandNameController,
                                label: "Brand Name",
                                hint: "Optional - Enter brand name",
                                isRequired: false,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField(
                                label: "Tag",
                                value: _selectedTag,
                                items: _tags,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTag = value;
                                  });
                                },
                                validator:
                                    (value) => _validateDropdown(value, 'Tag'),
                                isRequired: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      "Stock Details",
                      Icons.inventory_2_outlined,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _quantityController,
                                label: "Quantity in Stock",
                                hint: "e.g., 150",
                                validator:
                                    (value) =>
                                        _validateNumber(value, 'Quantity'),
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildDropdownField(
                                label: "Unit",
                                value: _selectedUnit,
                                items: _units,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                },
                                validator:
                                    (value) => _validateDropdown(value, 'Unit'),
                                isRequired: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _reorderLevelController,
                                label: "Reorder Level",
                                hint: "e.g., 50",
                                validator:
                                    (value) =>
                                        _validateNumber(value, 'Reorder Level'),
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      "Supplier Information",
                      Icons.local_shipping_outlined,
                      const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _supplierController,
                            label: "Supplier",
                            hint: "Optional - Enter supplier name",
                            isRequired: false,
                          ),
                        ),
                        const SizedBox(width: 24),

                        Expanded(
                          child: _buildDateField(
                            controller: _warrantyDateController,
                            label: "Warranty Until",
                            hint: "Optional - Select date",
                            onTap: () => _selectWarrantyDate(context),
                            isRequired: false,
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
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
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
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
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
