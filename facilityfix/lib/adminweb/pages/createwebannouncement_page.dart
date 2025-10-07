import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../layout/facilityfix_layout.dart';
import '../services/api_service.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final ApiService _apiService = ApiService();

  // Form controllers for backend integration
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Form state variables
  String? _selectedAudience;
  String? _selectedType;
  String? _selectedLocation;
  bool _pinToDashboard = false;
  List<File> _attachedFiles = [];

  // Dropdown options
  final List<String> _audienceOptions = ['Tenant', 'Staff', 'All'];

  final List<Map<String, dynamic>> _typeOptions = [
    {
      'value': 'Scheduled Maintenance',
      'label': 'Scheduled Maintenance',
      'icon': Icons.build,
      'color': Colors.green,
    },
    {
      'value': 'Utility Interruption',
      'label': 'Utility Interruption',
      'icon': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'value': 'Safety Inspection',
      'label': 'Safety Inspection',
      'icon': Icons.warning,
      'color': Colors.orange,
    },
    {
      'value': 'Power Outage',
      'label': 'Power Outage',
      'icon': Icons.power_off,
      'color': Colors.grey[700],
    },
    {
      'value': 'General Announcement',
      'label': 'General Announcement',
      'icon': Icons.campaign,
      'color': Colors.orange,
    },
    {
      'value': 'Pest Control',
      'label': 'Pest Control',
      'icon': Icons.pest_control,
      'color': Colors.orange,
    },
  ];

  // Sample location options - replace with actual data from backend
  final List<String> _locationOptions = [
    'Tower A, Floors 1-5',
    'Tower B, Floors 1-10',
    'Building C, Lobby',
    'Parking Area',
    'Common Areas',
    'All Buildings',
  ];

  // Route mapping helper function
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

  // Logout functionality
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

  // File picker functionality
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(
            result.paths
                .where((path) => path != null)
                .map((path) => File(path!))
                .toList(),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: $e');
    }
  }

  // Remove file functionality
  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  // Date picker functionality
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // Form validation
  bool _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return false;
    }
    if (_selectedAudience == null) {
      _showErrorSnackBar('Please select an audience');
      return false;
    }
    if (_selectedType == null) {
      _showErrorSnackBar('Please select a type');
      return false;
    }
    if (_detailsController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter announcement details');
      return false;
    }
    return true;
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Submit form - ready for backend integration
  void _submitForm() async {
    if (!_validateForm()) return;

    final announcementData = {
      'title': _titleController.text.trim(),
      'content': _detailsController.text.trim(),
      'type': _selectedType ?? 'General Announcement',
      'audience': _selectedAudience?.toLowerCase() ?? 'all',
      'location_affected': _selectedLocation,
      'start_date':
          _startDateController.text.isNotEmpty
              ? _startDateController.text
              : null,
      'end_date':
          _endDateController.text.isNotEmpty ? _endDateController.text : null,
      'pin_to_dashboard': _pinToDashboard,
      'building_id': 'building_001', // TODO: Get from user session
      'created_by': 'admin_user', // TODO: Get from user session
    };

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _apiService.createAnnouncement(announcementData);

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Announcement created successfully! ID: ${response['formatted_id'] ?? response['id']}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to announcement list
        context.go('/announcement');
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create announcement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FacilityFixLayout(
      currentRoute: 'announcement',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      // Important: let THIS be the only scroll view at this level.
      // Important: this entire "body:" replaces the current one
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;

          // Build the actual page content once,(optionally) wrap it with a ConstrainedBox
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // shrink-wrap vertically
            children: [
              // ===== Header Section with breadcrumbs =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Announcement",
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
                        child: const Text('Announcement'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ===== Main Form Container (no inner scroll view) =====
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // shrink-wrap vertically
                    children: [
                      // ===== Title =====
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "e.g., Scheduled Water Interruption",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== Audience & Type =====
                      Row(
                        children: [
                          // Audience
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Audience",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedAudience,
                                  hint: const Text("Select recipients..."),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items:
                                      _audienceOptions.map((audience) {
                                        return DropdownMenuItem(
                                          value: audience,
                                          child: Text(audience),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAudience = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Type
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Type",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedType,
                                  hint: const Text("Select type..."),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items:
                                      _typeOptions.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type['value'] as String,
                                          child: Row(
                                            children: [
                                              Icon(
                                                type['icon'] as IconData,
                                                color: type['color'] as Color?,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(type['label'] as String),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ===== Post Details =====
                      const Text(
                        "Post Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        alignment:
                            Alignment.centerLeft, // align label to the left
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: const Text(
                          "Text",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      TextField(
                        controller: _detailsController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: "Enter the full announcement details...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ===== Location + Schedule =====
                      Row(
                        children: [
                          // Location
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Location Affected (Optional)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedLocation,
                                  hint: const Text("Select"),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items:
                                      _locationOptions.map((location) {
                                        return DropdownMenuItem(
                                          value: location,
                                          child: Text(location),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLocation = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Schedule
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  "Schedule Visibility",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _startDateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "DD / MM / YY",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.blue[600],
                                            size: 20,
                                          ),
                                        ),
                                        onTap:
                                            () => _selectDate(
                                              _startDateController,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _endDateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "DD / MM / YY",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.blue[600],
                                            size: 20,
                                          ),
                                        ),
                                        onTap:
                                            () =>
                                                _selectDate(_endDateController),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Start date → Expiry Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ===== Attachments =====
                      const Text(
                        "Attachments(Optional)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickFiles,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Drop files here or click to upload",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "PDF, PNG, JPG up to 10MB",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_attachedFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...List.generate(_attachedFiles.length, (index) {
                          final file = _attachedFiles[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.path
                                        .split(Platform.pathSeparator)
                                        .last,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeFile(index),
                                  icon: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 8),

                      // ===== Bottom Actions =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(
                              top: 12,
                            ), // spacing from above
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Pin to Dashboard",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Switch(
                                  value: _pinToDashboard, // bool state
                                  onChanged: (value) {
                                    setState(() {
                                      _pinToDashboard = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text(
                              "Publish",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Keep visible at top",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          // Only ONE scroll view. If parent has a finite height, it we stretch to it.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child:
                hasBoundedHeight
                    ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: content,
                    )
                    : content, // if unbounded, don't force a minHeight
          );
        },
      ),
    );
  }
}
