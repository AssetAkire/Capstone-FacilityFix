import 'package:flutter/material.dart';

// Pages
import 'package:facilityfix/landingpage/forgot_password.dart';
import 'package:facilityfix/tenant/home.dart' as Tenant;
import 'package:facilityfix/staff/home.dart' as Staff;
import 'package:facilityfix/admin/home.dart' as Admin;

class LogIn extends StatefulWidget {
  final String role; // 'tenant' | 'staff' | 'admin'
  const LogIn({Key? key, required this.role}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final buildingController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    idController.dispose();
    passwordController.dispose();
    buildingController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final role = widget.role.toLowerCase();

    Widget destination;
    switch (role) {
      case 'tenant':
        destination = const Tenant.HomePage();
        break;
      case 'staff':
        destination = const Staff.HomePage();
        break;
      case 'admin':
        destination = const Admin.HomePage();
        break;
      default:
        destination = const Tenant.HomePage();
        break;
    }

    // Replace the modal with the destination
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    const inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
    );
    const hintTextStyle = TextStyle(
      color: Color(0xFF818181),
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );

    final isTenant = widget.role.toLowerCase() == 'tenant';
    final isStaff = widget.role.toLowerCase() == 'staff';
    final isAdmin = widget.role.toLowerCase() == 'admin';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(), // tap outside to dismiss
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: GestureDetector(
          onTap: () {}, // prevent dismiss on modal tap
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Log In',
                          style: TextStyle(
                            color: Color(0xFF005CE7),
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form with validation
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: "Email",
                                    hintStyle: hintTextStyle,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: inputPadding,
                                    border: borderStyle,
                                    enabledBorder: borderStyle,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    final emailRe = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
                                    if (!emailRe.hasMatch(value.trim())) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Role-specific fields
                                if (isTenant) ...[
                                  TextFormField(
                                    controller: idController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: "Tenant ID",
                                      hintStyle: hintTextStyle,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: inputPadding,
                                      border: borderStyle,
                                      enabledBorder: borderStyle,
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty) ? 'Tenant ID is required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: buildingController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: "Building & Unit No.",
                                      hintStyle: hintTextStyle,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: inputPadding,
                                      border: borderStyle,
                                      enabledBorder: borderStyle,
                                    ),
                                    validator: (value) => (value == null || value.isEmpty)
                                        ? 'Building & Unit No. is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                ] else if (isStaff) ...[
                                  TextFormField(
                                    controller: idController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: "Staff ID",
                                      hintStyle: hintTextStyle,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: inputPadding,
                                      border: borderStyle,
                                      enabledBorder: borderStyle,
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty) ? 'Staff ID is required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                ] else if (isAdmin) ...[
                                  TextFormField(
                                    controller: idController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: "Admin ID",
                                      hintStyle: hintTextStyle,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: inputPadding,
                                      border: borderStyle,
                                      enabledBorder: borderStyle,
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty) ? 'Admin ID is required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Password
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: hintTextStyle,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: inputPadding,
                                    border: borderStyle,
                                    enabledBorder: borderStyle,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFF818181),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _handleLogin(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Login Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF818181),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _handleLogin,
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Forgot Password
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const ForgotPassword(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return child;
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'I forgot my password',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
