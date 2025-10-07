import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../popupwidgets/webforgotpassword_popup.dart';
import '../services/api_service.dart';

class UserProfileDialog extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileDialog({super.key, required this.user});

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();

  // Static method to show the dialog
  static void show(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return UserProfileDialog(user: user);
      },
    );
  }
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  bool isEditMode = false;
  final ApiService _apiService = ApiService();

  // Controllers for editable fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController departmentController;

  bool isFirstNameValid = true;
  bool isLastNameValid = true;
  bool isEmailValid = true;
  bool isPhoneValid = true;
  bool isDepartmentValid = true;

  bool _validateInputs() {
    setState(() {
      isFirstNameValid = firstNameController.text.trim().isNotEmpty;
      isLastNameValid = lastNameController.text.trim().isNotEmpty;
      isEmailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(emailController.text.trim());
      isPhoneValid = phoneController.text.trim().isNotEmpty;
      isDepartmentValid = true; // Department is optional
    });

    return isFirstNameValid && isLastNameValid && isEmailValid && isPhoneValid;
  }

  @override
  void initState() {
    super.initState();
    final rawUser = widget.user['_raw'] ?? {};
    firstNameController = TextEditingController(
      text: rawUser['first_name'] ?? '',
    );
    lastNameController = TextEditingController(
      text: rawUser['last_name'] ?? '',
    );
    emailController = TextEditingController(
      text: rawUser['email'] ?? widget.user['email'] ?? '',
    );
    phoneController = TextEditingController(
      text: rawUser['phone_number'] ?? '',
    );
    departmentController = TextEditingController(
      text: rawUser['department'] ?? widget.user['department'] ?? '',
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  String _getUserIdLabel() {
    final role = widget.user['role'] ?? 'Tenant';
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin ID';
      case 'staff':
        return 'Staff ID';
      case 'tenant':
      default:
        return 'Tenant ID';
    }
  }

  String _getUserId() {
    return widget.user['id'] ?? widget.user['_raw']?['user_id'] ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
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
            // Header Section
            _buildHeader(context),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image Section
                    _buildProfileImage(),
                    const SizedBox(height: 24),

                    // Name Section
                    _buildNameSection(),
                    const SizedBox(height: 8),

                    _buildUserIdSection(),
                    const SizedBox(height: 32),

                    // Personal Details Section
                    _buildPersonalDetailsSection(),
                  ],
                ),
              ),
            ),

            // Footer Section
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Header with title, edit toggle, delete, and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 24, top: 24, bottom: 16),
      child: Row(
        children: [
          const Text(
            'User Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (!isEditMode)
            IconButton(
              onPressed: () => _deleteUser(context),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[600],
                size: 24,
              ),
              tooltip: 'Delete User',
            ),
          const SizedBox(width: 8),
          // Edit toggle button
          IconButton(
            onPressed: () => _toggleEditMode(),
            icon: Icon(
              isEditMode ? Icons.save : Icons.edit,
              color: isEditMode ? Colors.green[600] : Colors.blue[600],
              size: 24,
            ),
            tooltip: isEditMode ? 'Save Changes' : 'Edit Profile',
          ),
          const SizedBox(width: 8),
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Profile image with camera icon for editing
  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[200]!, width: 3),
          ),
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Colors.grey[100],
            backgroundImage:
                widget.user['profileImage'] != null
                    ? NetworkImage(widget.user['profileImage'])
                    : null,
            child:
                widget.user['profileImage'] == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                    : null,
          ),
        ),
        if (isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                onPressed: () => _changeProfileImage(),
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameSection() {
    return isEditMode
        ? Column(
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: firstNameController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'First Name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  errorText: !isFirstNameValid ? 'Required' : null,
                ),
                onChanged: (val) {
                  setState(() {
                    isFirstNameValid = val.trim().isNotEmpty;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: lastNameController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  errorText: !isLastNameValid ? 'Required' : null,
                ),
                onChanged: (val) {
                  setState(() {
                    isLastNameValid = val.trim().isNotEmpty;
                  });
                },
              ),
            ),
          ],
        )
        : Text(
          widget.user['name'] ?? 'No Name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        );
  }

  Widget _buildUserIdSection() {
    return Text(
      '${_getUserIdLabel()}: ${_getUserId()}',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    final rawUser = widget.user['_raw'] ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with edit icon
          Row(
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (isEditMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.edit_note,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Email field
          _buildDetailField(
            'Email',
            emailController,
            rawUser['email'] ?? widget.user['email'] ?? 'Not specified',
            keyboardType: TextInputType.emailAddress,
            isValid: isEmailValid,
            onChanged: (val) {
              setState(() {
                isEmailValid = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(val);
              });
            },
          ),
          const SizedBox(height: 20),

          // Phone Number field
          _buildDetailField(
            'Phone Number',
            phoneController,
            rawUser['phone_number'] ?? 'Not specified',
            keyboardType: TextInputType.phone,
            isValid: isPhoneValid,
            onChanged: (val) {
              setState(() {
                isPhoneValid = val.trim().isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 20),

          // Department field
          _buildDetailField(
            'Department',
            departmentController,
            rawUser['department'] ??
                widget.user['department'] ??
                'Not specified',
            isValid: isDepartmentValid,
          ),
          const SizedBox(height: 20),

          // Role (read-only)
          _buildReadOnlyField('Role', widget.user['role'] ?? 'Tenant'),
          const SizedBox(height: 20),

          // Status (read-only)
          _buildReadOnlyField('Status', widget.user['status'] ?? 'Offline'),
          const SizedBox(height: 24),

          // Forgot Password link
          _buildForgotPasswordSection(),
        ],
      ),
    );
  }

  Widget _buildDetailField(
    String label,
    TextEditingController controller,
    String displayValue, {
    bool isDate = false,
    TextInputType? keyboardType,
    required bool isValid,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (isEditMode)
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: isDate,
            onTap: isDate ? () => _selectDate(controller) : null,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isValid ? Colors.grey[300]! : Colors.red,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isValid ? Colors.grey[300]! : Colors.red,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isValid ? const Color(0xFF1976D2) : Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              suffixIcon:
                  isDate ? const Icon(Icons.calendar_today, size: 20) : null,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        if (isEditMode && !isValid)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              "Please enter a valid $label",
              style: TextStyle(fontSize: 12, color: Colors.red[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Forgot password section
  Widget _buildForgotPasswordSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _forgotPassword(),
                  child: Text(
                    'Reset password',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Footer with action buttons
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditMode) ...[
            // Cancel button (only in edit mode)
            OutlinedButton(
              onPressed: () => _cancelEdit(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            // Save button (only in edit mode)
            ElevatedButton(
              onPressed: () => _saveChanges(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text('Save Changes'),
            ),
          ] else ...[
            // Close button (only in view mode)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text('Close'),
            ),
          ],
        ],
      ),
    );
  }

  // Event handlers and utility methods

  // Toggle between edit and view modes
  void _toggleEditMode() {
    if (isEditMode) {
      _saveChanges();
    } else {
      setState(() {
        isEditMode = true;
      });
    }
  }

  // Cancel editing and revert changes
  void _cancelEdit() {
    final rawUser = widget.user['_raw'] ?? {};
    setState(() {
      isEditMode = false;
      // Reset controllers to original values
      firstNameController.text = rawUser['first_name'] ?? '';
      lastNameController.text = rawUser['last_name'] ?? '';
      emailController.text = rawUser['email'] ?? widget.user['email'] ?? '';
      phoneController.text = rawUser['phone_number'] ?? '';
      departmentController.text =
          rawUser['department'] ?? widget.user['department'] ?? '';

      // Reset validation flags
      isFirstNameValid = true;
      isLastNameValid = true;
      isEmailValid = true;
      isPhoneValid = true;
      isDepartmentValid = true;
    });
  }

  void _saveChanges() async {
    // Validate first
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userId = widget.user['id'];

      Map<String, dynamic> updateData = {
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'department': departmentController.text.trim(),
      };

      print('[v0] Updating user $userId with data: $updateData');

      await _apiService.updateUser(userId, updateData);

      // Update local user data
      widget.user['name'] =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
      widget.user['email'] = emailController.text.trim();
      widget.user['department'] = departmentController.text.trim();

      if (widget.user['_raw'] != null) {
        widget.user['_raw']['first_name'] = firstNameController.text.trim();
        widget.user['_raw']['last_name'] = lastNameController.text.trim();
        widget.user['_raw']['email'] = emailController.text.trim();
        widget.user['_raw']['phone_number'] = phoneController.text.trim();
        widget.user['_raw']['department'] = departmentController.text.trim();
      }

      setState(() {
        isEditMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Close dialog and refresh parent page
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[v0] Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteUser(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${widget.user['name']}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final userId = widget.user['id'];
      print('[v0] Deleting user $userId');

      await _apiService.deleteUser(userId, permanent: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted user: ${widget.user['name']}")),
        );

        // Close dialog and refresh parent page
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('[v0] Error deleting user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete user: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Date picker for birth date
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  // Change profile image
  void _changeProfileImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image change coming soon...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Forgot password handler
  void _forgotPassword() {
    ForgotPasswordDialog.show(context);
  }
}
