import 'package:flutter/material.dart';
import 'package:facilityfix/landingpage/login.dart';
import 'package:facilityfix/landingpage/signup.dart';
import 'package:flutter/services.dart';

class ChooseRole extends StatelessWidget {
  final bool isLogin; // true for login, false for sign up
  const ChooseRole({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF005CE7);
    const textColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          // Soft gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, -1),
              end: Alignment(0, 0.7),
              colors: [Color(0xFFEAF2FF), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 90,
                  ),
                ),

                const SizedBox(height: 24),

                // Centered card
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x144B5563), // subtle
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLogin ? 'Log In as' : 'Sign Up as',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Choose your role to continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475467),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(height: 1, color: const Color(0xFFF1F5F9)),
                              const SizedBox(height: 20),

                              // Role buttons (open as modal bottom sheets)
                              _buildRoleButton(context, 'Tenant', 'tenant', brandBlue),
                              const SizedBox(height: 12),
                              _buildRoleButton(context, 'Staff', 'staff', brandBlue),
                              const SizedBox(height: 12),
                              _buildRoleButton(context, 'Admin', 'admin', brandBlue),

                              const SizedBox(height: 20),

                              // Back button
                              SizedBox(
                                width: 160,
                                height: 40,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String label,
    String role,
    Color brandBlue,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: () {
          // Open as a modal bottom sheet on TOP of ChooseRole.
          // Tapping outside will close it (barrierDismissible = true by default).
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent, // keep rounded top from child
            builder: (_) => isLogin ? LogIn(role: role) : SignUp(role: role),
          );
        },
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
