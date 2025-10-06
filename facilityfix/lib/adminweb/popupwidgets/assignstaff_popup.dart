import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AssignScheduleWorkDialog extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onAssignmentComplete;

  const AssignScheduleWorkDialog({
    super.key,
    required this.task,
    this.onAssignmentComplete,
  });

  @override
  State<AssignScheduleWorkDialog> createState() =>
      _AssignScheduleWorkDialogState();

  static void show(
    BuildContext context,
    Map<String, dynamic> task, {
    VoidCallback? onAssignmentComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AssignScheduleWorkDialog(
          task: task,
          onAssignmentComplete: onAssignmentComplete,
        );
      },
    );
  }
}

class _AssignScheduleWorkDialogState extends State<AssignScheduleWorkDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _formValid = false;
  bool _isLoading = false;
  bool _isAssigning = false;

  String? selectedStaffId;
  String? selectedStaffName;
  DateTime? selectedDate;
  final TextEditingController notesController = TextEditingController();

  List<Map<String, dynamic>> _staffList = [];
  List<Map<String, dynamic>> _filteredStaffList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    notesController.addListener(_revalidate);
    _loadStaffMembers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revalidate());
  }

  Future<void> _loadStaffMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the task category to filter staff by department
      String? taskCategory = widget.task['category']?.toString().toLowerCase();
      String? department;

      // Map task categories to departments
      switch (taskCategory) {
        case 'electrical':
          department = 'electrical';
          break;
        case 'plumbing':
          department = 'plumbing';
          break;
        case 'hvac':
          department = 'hvac';
          break;
        case 'carpentry':
          department = 'carpentry';
          break;
        case 'maintenance':
          department = 'maintenance';
          break;
        case 'security':
          department = 'security';
          break;
        case 'fire_safety':
          department = 'fire_safety';
          break;
        default:
          department = null; // Get all staff for general tasks
      }

      final staffData = await _apiService.getStaffMembers(
        department: department,
        availableOnly: true,
      );

      setState(() {
        _staffList = staffData.cast<Map<String, dynamic>>();
        _filteredStaffList = List.from(_staffList);
        _isLoading = false;
      });

      print('[AssignStaff] Loaded ${_staffList.length} staff members');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load staff members: $e';
        _isLoading = false;
      });
      print('[AssignStaff] Error loading staff: $e');
    }
  }

  void _revalidate() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (ok != _formValid) setState(() => _formValid = ok);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  String _getStaffDisplayName(Map<String, dynamic> staff) {
    final firstName = staff['first_name'] ?? '';
    final lastName = staff['last_name'] ?? '';
    final department =
        staff['staff_department'] ?? staff['department'] ?? 'General';
    final userId = staff['user_id'] ?? staff['id'] ?? '';

    String name = '$firstName $lastName'.trim();
    if (name.isEmpty) name = 'Staff Member';

    return '$name - $department ($userId)';
  }

  String _getStaffId(Map<String, dynamic> staff) {
    return staff['user_id'] ?? staff['id'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAssignHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskInfo(),
                      const SizedBox(height: 24),
                      _buildUrgencyChip(widget.task['priority'] ?? 'Medium'),
                      const SizedBox(height: 32),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildStaffDropdown()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDatePicker()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildAssignFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 24, top: 24, bottom: 16),
      child: Row(
        children: [
          const Text(
            'Assign & Schedule Work',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _isAssigning ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task: ${widget.task['id'] ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.task['title'] ?? 'No Title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${widget.task['department'] ?? 'General'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String priority) {
    Color bgColor;
    Color textColor;
    switch (priority.toLowerCase()) {
      case 'high':
      case 'critical':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        break;
      case 'medium':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
        break;
      case 'low':
        bgColor = const Color(0xFFE8F5E8);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF8F00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$priority Priority',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStaffDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign Staff',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: selectedStaffId,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText:
                  _filteredStaffList.isEmpty
                      ? 'No staff available'
                      : 'Select Staff...',
            ),
            items:
                _filteredStaffList.map((staff) {
                  final staffId = _getStaffId(staff);
                  final displayName = _getStaffDisplayName(staff);
                  return DropdownMenuItem(
                    value: staffId,
                    child: Text(displayName, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            onChanged:
                _filteredStaffList.isEmpty
                    ? null
                    : (value) {
                      setState(() {
                        selectedStaffId = value;
                        selectedStaffName = _filteredStaffList
                            .firstWhere((staff) => _getStaffId(staff) == value)
                            .let((staff) => _getStaffDisplayName(staff));
                      });
                      _revalidate();
                    },
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a staff member'
                        : null,
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Order Schedule',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        FormField<DateTime>(
          validator: (_) {
            if (selectedDate == null) return 'Please pick a date';
            final today = DateTime.now();
            final floor = DateTime(today.year, today.month, today.day);
            if (selectedDate!.isBefore(floor))
              return 'Date can\'t be in the past';
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _selectDate(context).then((_) => _revalidate()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: state.hasError ? Colors.red : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: state.hasError ? Colors.red : Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? _fmtDate(selectedDate!)
                              : 'DD / MM / YY',
                          style: TextStyle(
                            color:
                                selectedDate != null
                                    ? Colors.black87
                                    : (state.hasError
                                        ? Colors.red
                                        : Colors.grey[500]),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString().substring(2);
    return '$dd / $mm / $yy';
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Internal Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: notesController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Enter Notes....',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(500)],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (v.trim().length < 5)
              return 'Add a bit more detail or leave blank';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAssignFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: _isAssigning ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[600]!),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed:
                (_formValid && !_isAssigning) ? _handleSaveAndAssign : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child:
                _isAssigning
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Save & Assign Staff',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _handleSaveAndAssign() async {
    if (!_formValid || selectedStaffId == null) return;

    setState(() => _isAssigning = true);

    try {
      // Get the concern slip ID from the task
      final concernSlipId =
          widget.task['rawData']?['id'] ??
          widget.task['rawData']?['_doc_id'] ??
          widget.task['id'];

      if (concernSlipId == null) {
        throw Exception('Concern slip ID not found');
      }

      print(
        '[AssignStaff] Assigning staff $selectedStaffId to concern slip $concernSlipId',
      );

      // Call the API to assign staff
      final result = await _apiService.assignStaffToConcernSlip(
        concernSlipId,
        selectedStaffId!,
      );

      print('[AssignStaff] Assignment successful: $result');

      // Close the dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Work assigned to $selectedStaffName on ${_fmtDate(selectedDate!)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Trigger callback to refresh the parent page
        widget.onAssignmentComplete?.call();
      }
    } catch (e) {
      print('[AssignStaff] Assignment failed: $e');

      if (mounted) {
        setState(() => _isAssigning = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign staff: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

// Extension to add 'let' function for convenience
extension LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
