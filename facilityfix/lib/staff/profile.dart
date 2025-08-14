import 'dart:io';
import 'package:facilityfix/landingpage/welcomepage.dart';
import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/forms.dart';
import 'package:facilityfix/widgets/pop_up.dart';
import 'package:facilityfix/widgets/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

  // Controllers moved here
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _profileImageFile;

  ImageProvider get _profileImageProvider {
    if (_profileImageFile != null) {
      return FileImage(_profileImageFile!);
    }
    return const AssetImage('assets/images/profile.png');
  }

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

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Upload a photo',
        message: 'Would you like to change your profile photo?',
        primaryText: 'Upload from gallery',
        onPrimaryPressed: () async {
          Navigator.of(context).pop();

          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );

          if (result != null && result.files.isNotEmpty) {
            setState(() {
              _profileImageFile = File(result.files.first.path!);
            });
          }
        },
        secondaryText: 'Take a photo',
        onSecondaryPressed: () async {
          Navigator.of(context).pop();

          final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

          if (photo != null) {
            setState(() {
              _profileImageFile = File(photo.path);
            });
          }
        },
        icon: Icons.image,
        primaryIcon: Icons.photo_library,
        secondaryIcon: Icons.camera_alt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: const BackButton(),
            ),
            Text('Profile'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoWidget(
                profileImage: _profileImageProvider,
                name: 'Juan Dela Cruz',
                staffId: 'Staff ID: #S12345',
                onTap: () => _showRequestDialog(context),
              ),
              const SizedBox(height: 24),

              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              InputField(
                label: 'Email',
                controller: emailController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.mail),
                ),
              ),
              const SizedBox(height: 8),

              InputField(
                label: 'Phone Number',
                controller: phoneNumberController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 8),

              PasswordInputField(
                label: 'Password',
                controller: passwordController,
                hintText: 'Auto-filled',
                isRequired: true,
                readOnly: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Column(
                children: [
                  SettingsOption(
                    text: 'Notifications',
                    icon: Icons.notifications,
                    onTap: () {},
                  ),
                  SettingsOption(
                    text: 'Privacy & Security',
                    icon: Icons.lock,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              LogoutButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomPopup(
                      title: 'Confirm Logout',
                      message: 'Are you sure you want to logout?',
                      primaryText: 'Yes',
                      onPrimaryPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomePage()),
                        );
                      },
                      secondaryText: 'No',
                      onSecondaryPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
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

// Password input field with eye icon to toggle visibility.
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
    setState(() {
      _obscureText = !_obscureText;
    });
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
          child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// SettingsOption widget
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
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFEEF0F4),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: const Color(0xFF545F70), size: 24),
            const SizedBox(width: 24),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF545F70),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.38,
                letterSpacing: -0.32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
