import 'package:facilityfix/config/env.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/services/api_services.dart';
import 'package:facilityfix/services/auth_storage.dart';
import 'package:go_router/go_router.dart';
//import 'adminwebdash_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _remember = true;
  bool _obscure = true;

  String? _emailErr;
  String? _passErr;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  bool _validate() {
    _emailErr = null;
    _passErr = null;

    final e = _email.text.trim();
    final p = _pass.text;
    final emailRe = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (e.isEmpty) {
      _emailErr = 'Email is required.';
    } else if (!emailRe.hasMatch(e)) {
      _emailErr = 'Enter a valid email address.';
    }

    if (p.isEmpty) {
      _passErr = 'Password is required.';
    } else if (p.length < 6) {
      _passErr = 'Password must be at least 6 characters.';
    }

    setState(() {});
    return _emailErr == null && _passErr == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    setState(() => _loading = true);

    final api = APIService(roleOverride: AppRole.admin);
    final email = _email.text.trim();
    final pass = _pass.text;

    try {
      final res = await api.loginRoleBased(
        role: 'admin',
        email: email,
        password: pass,
      );

      final Map<String, dynamic> profile =
          (res['profile'] is Map<String, dynamic>)
              ? (res['profile'] as Map<String, dynamic>)
              : <String, dynamic>{};

      final role =
          ((res['role'] ?? profile['role'] ?? 'admin').toString())
              .toLowerCase();

      final localProfile = <String, dynamic>{
        'user_id': profile['user_id'] ?? res['user_id'],
        'first_name': profile['first_name'] ?? '',
        'last_name': profile['last_name'] ?? '',
        'full_name':
            profile['full_name'] ??
            '${(profile['first_name'] ?? '').toString()} ${(profile['last_name'] ?? '').toString()}'
                .trim(),
        'birth_date': profile['birth_date'],
        'email': res['email'] ?? profile['email'] ?? email,
        'phone_number': profile['phone_number'],
        'role': role,
        'building_unit': profile['building_unit'],
        'staff_department': profile['staff_department'],
      };
      await AuthStorage.saveProfile(localProfile);

      final idToken =
          (res['id_token'] ?? res['token'] ?? res['idToken'] ?? '').toString();
      if (idToken.isNotEmpty) {
        await AuthStorage.saveToken(idToken);
      }

      if (!mounted) return;
      _showSnack(
        'Welcome ${localProfile['full_name'] ?? localProfile['email'] ?? 'Admin'}',
      );
      context.go('/dashboard');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel (as-is)
          if (isDesktop)
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFFB5D9F3),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'lib/adminweb/assets/images/logo.png',
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FacilityFix',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Image.asset(
                        'lib/adminweb/assets/images/leftpartgraphics.png',
                        height: 400,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

          // Right Panel - Login Form (wired up)
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to FacilityFix',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your all-in-one solution for maintenance and repair management system.',
                      style: TextStyle(color: Colors.grey, fontSize: 11.5),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline),
                        hintText: 'Email',
                        errorText: _emailErr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _pass,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Password',
                        errorText: _passErr,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Remember me + Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged:
                                  (v) => setState(() => _remember = v ?? true),
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            _showSnack(
                              'Forgot Password flow not implemented on web yet.',
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                      ),
                    ),

                    // Optional: quick link to dashboard if already authenticated
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final t = await AuthStorage.getToken();
                            if (t != null && t.isNotEmpty && mounted) {
                              context.go('/dashboard');
                            } else {
                              _showSnack('No active session found.');
                            }
                          },
                          child: const Text('dashboard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
