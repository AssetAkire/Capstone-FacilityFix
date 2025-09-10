import 'package:facilityfix/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facilityfix/landingpage/choose.dart';
import 'package:facilityfix/tenant/home.dart'; // HomePage
import 'package:facilityfix/widgets/forms.dart' hide DropdownField; // InputField (with errorText)
// NOTE: If your DropdownField is also in forms.dart but you hid it here to avoid conflicts,
// import it from its defining file OR remove "hide DropdownField" above.

class SignUp extends StatefulWidget {
  final String role; // 'tenant' | 'staff' | 'admin'
  const SignUp({Key? key, required this.role}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();
  final idController = TextEditingController(); // tenant building/unit OR staff ID (if needed later)
  final emailController = TextEditingController();
  final contactNumberController = TextEditingController();
  final passwordController = TextEditingController();

  // Staff classification
  String? _selectedClassification; // 'General Maintenance' | 'Plumbing' | 'Electrician' | 'Others'
  final TextEditingController classificationOtherController = TextEditingController();

  // Show built-in "required" visuals for dropdowns only after submit attempt
  bool _submitted = false;

  // External error captions (drive InputField red borders + custom captions)
  String? _firstNameErr;
  String? _lastNameErr;
  String? _birthdateErr;
  String? _tenantBuildingErr; // tenant
  String? _emailErr;
  String? _contactErr;        // optional but validate format if provided
  String? _passwordErr;
  String? _staffClassErr;     // used specifically for "Others must have text"

  bool _obscurePassword = true;

  bool get _isTenant => widget.role.toLowerCase() == 'tenant';
  bool get _isStaff  => widget.role.toLowerCase() == 'staff';
  bool get _isAdmin  => widget.role.toLowerCase() == 'admin';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthdateController.dispose();
    idController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    passwordController.dispose();
    classificationOtherController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      birthdateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() => _birthdateErr = null);
    }
  }

  bool _validate() {
    // reset all external errors
    _firstNameErr = null;
    _lastNameErr = null;
    _birthdateErr = null;
    _tenantBuildingErr = null;
    _emailErr = null;
    _contactErr = null;
    _passwordErr = null;
    _staffClassErr = null;

    final first   = firstNameController.text.trim();
    final last    = lastNameController.text.trim();
    final bday    = birthdateController.text.trim();
    final email   = emailController.text.trim();
    final contact = contactNumberController.text.trim(); // expects 10 digits (exclude +63)
    final pass    = passwordController.text;

    // Requireds (external captions)
    if (first.isEmpty) _firstNameErr = 'First Name is required.';
    if (last.isEmpty)  _lastNameErr  = 'Last Name is required.';
    if (bday.isEmpty)  _birthdateErr = 'Birthdate is required.';

    if (_isTenant && idController.text.trim().isEmpty) {
      _tenantBuildingErr = 'Building & Unit No. is required.';
    }

    // Staff classification: required via DropdownField (isRequired: _submitted)
    // Additional rule: when "Others" is chosen, a detail is required.
    if (_isStaff && _selectedClassification == 'Others') {
      if (classificationOtherController.text.trim().isEmpty) {
        _staffClassErr = 'Please specify your classification.';
      }
    }

    // Email format
    final emailRe = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (email.isEmpty) {
      _emailErr = 'Email is required.';
    } else if (!emailRe.hasMatch(email)) {
      _emailErr = 'Enter a valid email address.';
    }

    // Contact number: not required, but if provided must be 10 digits (for +63 prefix)
    if (contact.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(contact)) {
      _contactErr = 'Enter 10 digits (exclude +63).';
    }
    // If you want contact to be required, uncomment:
    // else if (contact.isEmpty) {
    //   _contactErr = 'Contact number is required.';
    // }

    // Password
    if (pass.isEmpty) {
      _passwordErr = 'Password is required.';
    } else if (pass.length < 6) {
      _passwordErr = 'Password must be at least 6 characters.';
    }

    // Trigger built-in (isRequired) red borders
    _formKey.currentState?.validate();

    setState(() {}); // refresh captions
    final basicOk = _firstNameErr == null &&
        _lastNameErr == null &&
        _birthdateErr == null &&
        _tenantBuildingErr == null &&
        _emailErr == null &&
        _contactErr == null &&
        _passwordErr == null;

    // Combine with classification special-case error (if staff)
    final staffOk = !_isStaff || _staffClassErr == null;

    return basicOk && staffOk;
  }

  void _onSubmit() {
    // allow DropdownField to show its red "required" message
    setState(() => _submitted = true);

    if (!_validate()) return;

    // If you also want to enforce that classification is chosen at all at submit time (in addition to DropdownField’s required UI):
    if (_isStaff && (_selectedClassification == null || _selectedClassification!.isEmpty)) {
      // Nothing chosen; the DropdownField should already show the requiredMessage.
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // tap outside to dismiss
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: GestureDetector(
          onTap: () {}, // prevent dismiss on content tap
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 600, // fixed modal height
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF005CE7),
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // First Name
                                InputField(
                                  label: 'First Name',
                                  hintText: 'e.g., Juan',
                                  controller: firstNameController,
                                  isRequired: true,
                                  errorText: _firstNameErr,
                                ),

                                // Last Name
                                InputField(
                                  label: 'Last Name',
                                  hintText: 'e.g., Dela Cruz',
                                  controller: lastNameController,
                                  isRequired: true,
                                  errorText: _lastNameErr,
                                ),

                                // Birthdate (read-only with picker)
                                InputField(
                                  label: 'Birthdate',
                                  hintText: 'YYYY-MM-DD',
                                  controller: birthdateController,
                                  isRequired: true,
                                  readOnly: true,
                                  onTap: _pickBirthdate,
                                  errorText: _birthdateErr,
                                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF98A2B3)),
                                ),

                                // Tenant-only: Building & Unit
                                if (_isTenant)
                                  InputField(
                                    label: 'Building & Unit No.',
                                    hintText: 'e.g., Tower A – 10F – 10B',
                                    controller: idController,
                                    isRequired: true,
                                    errorText: _tenantBuildingErr,
                                    prefixIcon: const Icon(Icons.location_city_outlined, color: Color(0xFF98A2B3)),
                                  ),

                                // Staff-only: Classification dropdown (Audience-like)
                                if (_isStaff) ...[
                                  DropdownField<String>(
                                    label: 'Classification',
                                    items: const [
                                      'General Maintenance',
                                      'Plumbing',
                                      'Electrician',
                                      'Others',
                                    ],
                                    value: _selectedClassification,
                                    onChanged: (v) => setState(() {
                                      _selectedClassification = v;
                                      // clear "Others detail" error if user changes away from Others or starts typing
                                      if (v != 'Others') _staffClassErr = null;
                                    }),
                                    isRequired: _submitted,
                                    requiredMessage: 'Classification is required.',
                                    hintText: 'Select classification',
                                    otherController: classificationOtherController, // when “Others” is chosen
                                  ),
                                  if (_staffClassErr != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _staffClassErr!,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFD92D20),
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ],

                                // Email
                                InputField(
                                  label: 'Email',
                                  hintText: 'you@example.com',
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  isRequired: true,
                                  errorText: _emailErr,
                                  prefixIcon: const Icon(Icons.mail, color: Color(0xFF98A2B3)),
                                ),

                                // Contact Number (+63 prefix; 10 digits only, optional)
                                InputField(
                                  label: 'Contact Number',
                                  hintText: 'e.g., 9123456789',
                                  controller: contactNumberController,
                                  keyboardType: TextInputType.number,
                                  isRequired: false, // set to true if you want it required
                                  errorText: _contactErr,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  // Use baseline-aligned prefix so "+63" lines up perfectly
                                  prefixIcon: const Text(
                                    '+63 ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Color(0xFF667085),
                                    ),
                                  ),
                                ),

                                // Password (eye toggle: no circle + 4px right inset)
                                InputField(
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  controller: passwordController,
                                  isRequired: true,
                                  obscureText: _obscurePassword,
                                  errorText: _passwordErr,
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF98A2B3)),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFF818181),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sign Up Button (matches login button style)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005CE7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _onSubmit,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Already have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChooseRole(isLogin: true),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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
