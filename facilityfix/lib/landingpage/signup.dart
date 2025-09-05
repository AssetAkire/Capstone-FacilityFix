// Required imports
import 'package:facilityfix/tenant/home.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/landingpage/choose.dart';
class SignUp extends StatefulWidget {
  final String role;
  const SignUp({Key? key, required this.role}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final contactNumberController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? selectedClassification;

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

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 600, // Fixed modal height
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),

              // Main content area
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

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              // First Name field with validation
                              _buildValidatedField(
                                controller: firstNameController,
                                hint: "First Name",
                              ),
                              const SizedBox(height: 16),

                              // Last Name field with validation
                              _buildValidatedField(
                                controller: lastNameController,
                                hint: "Last Name",
                              ),
                              const SizedBox(height: 16),

                              // Birthdate field with date picker
                              TextFormField(
                                controller: birthdateController,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    birthdateController.text =
                                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Birthdate",
                                  hintStyle: hintTextStyle,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: inputPadding,
                                  border: borderStyle,
                                  enabledBorder: borderStyle,
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Birthdate is required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // ID field for tenant or staff
                              if (widget.role == 'tenant') ...[
                                _buildValidatedField(
                                  controller: idController,
                                  hint: "Building & Unit No.",
                                ),
                                const SizedBox(height: 16),

                                // Classification dropdown for staff
                              ] else if (widget.role == 'staff') ...[
                                DropdownButtonFormField<String>(
                                  value: selectedClassification,
                                  onChanged: (value) => setState(() => selectedClassification = value),
                                  items: [
                                    'General Maintenance',
                                    'Plumbing',
                                    'Electrician',
                                  ].map((label) => DropdownMenuItem(
                                        value: label,
                                        child: Text(label),
                                      ))
                                      .toList(),
                                  decoration: InputDecoration(
                                    hintText: "Classification",
                                    hintStyle: hintTextStyle,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: inputPadding,
                                    border: borderStyle,
                                    enabledBorder: borderStyle,
                                  ),
                                  validator: (value) => value == null ? 'Please select classification' : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email field with validation
                              _buildValidatedEmailField(),
                              const SizedBox(height: 16),

                              // Phone field with validation
                              _buildValidatedPhoneField(),
                              const SizedBox(height: 16),
                              _buildValidatedPasswordField(),
                            ],
                          ),
                        ),

                        // Sign Up Button
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomePage()),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Sign Up',
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

// Validated text fields
  Widget _buildValidatedField({required TextEditingController controller, required String hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF818181),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$hint is required';
        return null;
      },
    );
  }

// Email field with validation
Widget _buildValidatedEmailField() {
  return TextFormField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      hintText: "Email",
      hintStyle: TextStyle(
        color: Color(0xFF818181),
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Email is required';
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Enter a valid email';
      return null;
    },
  );
}

// Phone field with validation
Widget _buildValidatedPhoneField() {
  return TextFormField(
    controller: contactNumberController,
    keyboardType: TextInputType.phone,
    maxLength: 11,
    decoration: const InputDecoration(
      hintText: "Contact Number",
      hintStyle: TextStyle(color: Color(0xFF818181)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
      ),
      counterText: "",
      prefixText: "+63 ",

    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Contact number is required';
      }
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Enter 10 digits (exclude +63)';
      }
      return null;
    },
  );
}

// Password field with validation 
  Widget _buildValidatedPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(color: Color(0xFF818181)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE5E6E8), width: 1),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF818181),
          ),
          onPressed: () => setState(() {
            _obscurePassword = !_obscurePassword;
          }),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }
}
