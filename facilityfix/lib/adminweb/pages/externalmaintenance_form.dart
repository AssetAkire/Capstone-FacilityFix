import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';

class ExternalMaintenanceFormPage extends StatefulWidget {
  const ExternalMaintenanceFormPage({super.key});

  @override
  State<ExternalMaintenanceFormPage> createState() => _ExternalMaintenanceFormPageState();
}

class _ExternalMaintenanceFormPageState extends State<ExternalMaintenanceFormPage> {
  // Form Controllers for text fields
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskCodeController = TextEditingController();
  final TextEditingController _createdByController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contractorNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _recommendationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _maintenanceTypeController = TextEditingController();

  // Form State Variables
  String? _selectedServiceCategory;
  DateTime? _dateCreated;
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedLocation;
  String? _selectedRecurrence;
  DateTime? _startDate;
  DateTime? _nextDueDate;
  DateTime? _serviceWindowStart;
  DateTime? _serviceWindowEnd;
  DateTime? _serviceDateActual;
  DateTime? _loggedDate;
  String? _selectedAssessmentReceived;
  String? _selectedLoggedBy;
  DateTime? _assignedStaffDate;
  String? _selectedAdminNotifications;

  // Dropdown options
  final List<String> _serviceCategoryOptions = [
    'HVAC Systems', 'Electrical Systems', 'Plumbing', 'Fire Safety', 
    'Security Systems', 'Elevators', 'Cleaning Services', 'Pest Control'
  ];
  
  final List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _statusOptions = ['New', 'In Progress', 'Completed', 'On Hold'];
  final List<String> _locationOptions = [
    'Building A - Basement', 'Building A - Ground Floor', 'Building A - 2nd Floor',
    'Building B - Ground Floor', 'Building B - 2nd Floor', 'Unit 101', 'Unit 201', 'Unit 210'
  ];
  final List<String> _recurrenceOptions = ['Weekly', 'Monthly', '3 Months', '6 Months', 'Yearly'];
  final List<String> _assessmentOptions = ['Yes', 'No', 'Pending'];
  final List<String> _loggedByOptions = ['Auto-filled', 'Manual Entry', 'System Generated'];
  final List<String> _adminNotificationOptions = ['Before due date', 'On due date', '1 day before', '1 week before'];

  // Helper function to convert routeKey to actual route path
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_view': '/inventory/view',
      'inventory_add': '/inventory/add',
      'analytics': '/analytics',
      'notice': '/notice',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

  // Handle logout functionality
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
                context.go('/'); // Go back to login page
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Date picker helper function
  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  // Save draft functionality
  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Submit form functionality
  void _submitForm() {
    // Basic validation
    if (_taskTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('External preventive maintenance task created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    context.go('/adminweb/pages/externalviewtask');
  }

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - Page Title and Breadcrumb
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
                Row(
                  children: [
                    Text(
                      "Main",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Work Orders",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Maintenance Tasks",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main Form Container - Scrollable Content
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionTitle("Basic Information"),
                    const SizedBox(height: 24),
                    
                    // First row - Task Title and Task Code
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Task Title",
                            controller: _taskTitleController,
                            placeholder: "Enter Item Name",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextField(
                            label: "Task Code",
                            controller: _taskCodeController,
                            placeholder: "Code Id",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Second row - Maintenance Type and Service Category
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Maintenance Type",
                            controller: _maintenanceTypeController,
                            placeholder: "External / 3rd-Party",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDropdownField(
                            label: "Service Category",
                            value: _selectedServiceCategory,
                            placeholder: "Input",
                            options: _serviceCategoryOptions,
                            onChanged: (value) => setState(() => _selectedServiceCategory = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Third row - Created By and Date Created
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Created By",
                            controller: _createdByController,
                            placeholder: "Enter Item Name",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDateField(
                            label: "Date Created",
                            selectedDate: _dateCreated,
                            placeholder: "DD / MM / YY",
                            onDateSelected: (date) => setState(() => _dateCreated = date),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Fourth row - Priority and Status
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "Priority",
                            value: _selectedPriority,
                            placeholder: "Select Priority...",
                            options: _priorityOptions,
                            onChanged: (value) => setState(() => _selectedPriority = value),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDropdownField(
                            label: "Status",
                            value: _selectedStatus,
                            placeholder: "Select Status...",
                            options: _statusOptions,
                            onChanged: (value) => setState(() => _selectedStatus = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Service Scope & Description Section
                    _buildSectionTitle("Service Scope & Description"),
                    const SizedBox(height: 24),

                    // Location/Area field
                    _buildDropdownField(
                      label: "Location / Area",
                      value: _selectedLocation,
                      placeholder: "Select Department...",
                      options: _locationOptions,
                      onChanged: (value) => setState(() => _selectedLocation = value),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 24),

                    // Description field
                    _buildTextAreaField(
                      label: "Description",
                      controller: _descriptionController,
                      placeholder: "Enter Description...",
                    ),
                    const SizedBox(height: 40),

                    // Contractor Information Section
                    _buildSectionTitle("Contractor Information"),
                    const SizedBox(height: 24),

                    // Contractor Name and Contact Person
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Contractor Name",
                            controller: _contractorNameController,
                            placeholder: "Enter Name",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextField(
                            label: "Contact Person",
                            controller: _contactPersonController,
                            placeholder: "Enter Name",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Contact Number and Email
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Contact Number",
                            controller: _contactNumberController,
                            placeholder: "Input Contact Number",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextField(
                            label: "Email",
                            controller: _emailController,
                            placeholder: "Input Email",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Recurrence & Schedule Section
                    _buildSectionTitle("Recurrence & Schedule"),
                    const SizedBox(height: 24),

                    // Recurrence and Start Date
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "Recurrence",
                            value: _selectedRecurrence,
                            placeholder: "Input",
                            options: _recurrenceOptions,
                            onChanged: (value) => setState(() => _selectedRecurrence = value),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDateField(
                            label: "Start Date",
                            selectedDate: _startDate,
                            placeholder: "DD / MM / YY",
                            onDateSelected: (date) => setState(() => _startDate = date),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Next Due Date and Service Window
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: "Next Due Date",
                            selectedDate: _nextDueDate,
                            placeholder: "DD / MM / YY",
                            onDateSelected: (date) => setState(() => _nextDueDate = date),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service Window",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateField(
                                      label: "",
                                      selectedDate: _serviceWindowStart,
                                      placeholder: "DD / MM / YY",
                                      onDateSelected: (date) => setState(() => _serviceWindowStart = date),
                                      showLabel: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDateField(
                                      label: "",
                                      selectedDate: _serviceWindowEnd,
                                      placeholder: "DD / MM / YY",
                                      onDateSelected: (date) => setState(() => _serviceWindowEnd = date),
                                      showLabel: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Post-Service Assessment Logging Section
                    _buildSectionTitle("Post-Service Assessment Logging"),
                    const SizedBox(height: 16),

                    // Information note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,        // background light blue
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200), // optional border
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Colors.blue), // info icon
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "These fields will be filled after the 3rd-party service visit is completed",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service Date and Assessment Received
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: "Service Date (Actual)",
                            selectedDate: _serviceDateActual,
                            placeholder: "Auto-generated",
                            onDateSelected: (date) => setState(() => _serviceDateActual = date),
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDropdownField(
                            label: "Assessment Received",
                            value: _selectedAssessmentReceived,
                            placeholder: "Input",
                            options: _assessmentOptions,
                            onChanged: (value) => setState(() => _selectedAssessmentReceived = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Logged By and Logged Date
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "Logged By",
                            value: _selectedLoggedBy,
                            placeholder: "Auto-filled",
                            options: _loggedByOptions,
                            onChanged: (value) => setState(() => _selectedLoggedBy = value),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDateField(
                            label: "Logged Date",
                            selectedDate: _loggedDate,
                            placeholder: "Auto-generated",
                            onDateSelected: (date) => setState(() => _loggedDate = date),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Assessment and Recommendation
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextAreaField(
                            label: "Assessment",
                            controller: _assessmentController,
                            placeholder: "Enter Recommendation...",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextAreaField(
                            label: "Recommendation",
                            controller: _recommendationController,
                            placeholder: "Enter Recommendation...",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Assignment & Execution Section
                    _buildSectionTitle("Assignment & Execution"),
                    const SizedBox(height: 24),

                    // Department and Assigned Staff
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Department",
                            controller: _departmentController,
                            placeholder: "Enter Supplier Name",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildDateField(
                            label: "Assigned Staff",
                            selectedDate: _assignedStaffDate,
                            placeholder: "DD / MM / YY",
                            onDateSelected: (date) => setState(() => _assignedStaffDate = date),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Attachments Section
                    _buildSectionTitle("Attachments"),
                    const SizedBox(height: 24),

                    // File upload area
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Drop files here or click to upload",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
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
                    const SizedBox(height: 40),

                    // Notifications Section
                    _buildSectionTitle("Notifications"),
                    const SizedBox(height: 24),

                    // Admin Notifications
                    _buildDropdownField(
                      label: "Admin Notifications",
                      value: _selectedAdminNotifications,
                      placeholder: "Before due date",
                      options: _adminNotificationOptions,
                      onChanged: (value) => setState(() => _selectedAdminNotifications = value),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Save Draft Button
                        SizedBox(
                          width: 140,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _saveDraft,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save Draft',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Submit Button
                        SizedBox(
                          width: 100,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget - Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Helper Widget - Text Field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey[50],
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget - Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String placeholder,
    required List<String> options,
    required Function(String?) onChanged,
    bool fullWidth = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 48,
          width: fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            dropdownColor: Colors.white,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget - Date Field
  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required String placeholder,
    required Function(DateTime) onDateSelected,
    bool enabled = true,
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey[50],
          ),
          child: InkWell(
            onTap: enabled ? () => _selectDate(context, onDateSelected) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: enabled ? Colors.blue : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? "${selectedDate.day.toString().padLeft(2, '0')} / ${selectedDate.month.toString().padLeft(2, '0')} / ${selectedDate.year.toString().substring(2)}"
                          : placeholder,
                      style: TextStyle(
                        color: selectedDate != null ? Colors.black87 : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget - Text Area Field
  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskCodeController.dispose();
    _createdByController.dispose();
    _descriptionController.dispose();
    _contractorNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _assessmentController.dispose();
    _recommendationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}