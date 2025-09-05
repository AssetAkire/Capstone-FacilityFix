import 'package:facilityfix/landingpage/login.dart';
import 'package:facilityfix/landingpage/signup.dart';
import 'package:flutter/material.dart';

class ChooseRole extends StatelessWidget {
  final bool isLogin; // true for login, false for sign up
  const ChooseRole({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo at the top
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                child: Image.asset(
                  "assets/images/Logo.png",
                  height: 120,
                ),
              ),
            ),

            // Spacer for separation
            const SizedBox(height: 40),

            // Centered Welcome and Role Buttons
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role Buttons
                      _buildRoleButton(context, 'Tenant', 'tenant'),
                      const SizedBox(height: 16),

                      _buildRoleButton(context, 'Staff', 'staff'),
                      const SizedBox(height: 16),

                      _buildRoleButton(context, 'Admin', 'admin'),
                      const SizedBox(height: 24),

                      // Back Button
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String label, String role) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005CE8),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  isLogin ? LogIn(role: role) : SignUp(role: role),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
