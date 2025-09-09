import 'package:facilityfix/widgets/forms.dart';
import 'package:flutter/material.dart';
class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const Color brand = Color(0xFF005CE7); // keeps your existing blue
    final Color bg    = brand.withOpacity(0.06);
    final BorderRadius radius = BorderRadius.circular(12);

    return Semantics(
      button: true,
      label: 'Logout',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: brand, width: 1),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            splashColor: brand.withOpacity(0.12),
            highlightColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: brand, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: 0.1,
                    color: Color(0xFF005CE7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Password field with toggle visibility
class PasswordInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isRequired;
  final bool readOnly;
  final Widget? prefixIcon;

  const PasswordInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.isRequired = false,
    this.readOnly = false,
    this.prefixIcon,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label + (widget.isRequired ? ' *' : ''),
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: GestureDetector(
          onTap: _toggleVisibility,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Settings row item with icon and chevron
class SettingsOption extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
              ),
              const SizedBox(width: 10),// ← spacing fixed to 16 px
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}


/// Card section with optional trailing widget (e.g., edit icon)
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Avatar widget with gradient border and camera badge
class ProfileInfoWidget extends StatelessWidget {
  final ImageProvider profileImage;
  final String name;
  final String staffId;
  final VoidCallback onTap;

  const ProfileInfoWidget({
    super.key,
    required this.profileImage,
    required this.name,
    required this.staffId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6AA9FF), Color(0xFF7CE3FF)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 4),
              Text(staffId,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }
}

// Edit Personal details
class EditedPersonalDetails {
  final String name;
  final String email;
  final String phone;

  const EditedPersonalDetails({
    required this.name,
    required this.email,
    required this.phone,
  });
}

Future<EditedPersonalDetails?> showEditPersonalDetailsSheet({
  required BuildContext context,          // parent context (for SnackBar)
  required String initialName,
  required String initialEmail,
  required String initialPhone,
  String title = 'Edit Personal Details',
}) async {
  final editUserName = TextEditingController(text: initialName);
  final editEmail = TextEditingController(text: initialEmail);
  final editPhone = TextEditingController(text: initialPhone);

  EditedPersonalDetails? result;

  try {
    result = await showModalBottomSheet<EditedPersonalDetails>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // Username
                InputField(
                  label: 'Username',
                  controller: editUserName,
                  hintText: 'Enter username',
                  isRequired: true,
                  readOnly: false,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),

                // Email
                InputField(
                  label: 'Email',
                  controller: editEmail,
                  hintText: 'Enter email',
                  isRequired: true,
                  readOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.mail),
                  ),
                ),
                const SizedBox(height: 10),

                // Phone
                InputField(
                  label: 'Phone Number',
                  controller: editPhone,
                  hintText: 'Enter phone number',
                  isRequired: true,
                  readOnly: false,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF005CE7),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final name = editUserName.text.trim();
                          final email = editEmail.text.trim();
                          final phone = editPhone.text.trim();

                          if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                            // Use the PARENT context so the SnackBar shows above the sheet.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please complete all fields')),
                            );
                            return;
                          }

                          Navigator.pop(
                            ctx,
                            EditedPersonalDetails(
                              name: name,
                              email: email,
                              phone: phone,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF005CE7),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  } finally {
    editUserName.dispose();
    editEmail.dispose();
    editPhone.dispose();
  }

  return result;
}