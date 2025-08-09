import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthTestScreen extends StatefulWidget {
  @override
  _AuthTestScreenState createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _selectedRole = 'tenant';
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Auth Test'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildLoggedInView(snapshot.data!);
          } else {
            return _buildAuthView();
          }
        },
      ),
    );
  }

  Widget _buildLoggedInView(User user) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Email: ${user.email}'),
          Text('UID: ${user.uid}'),
          SizedBox(height: 16),

          // Display user data from Firestore
          StreamBuilder<UserModel?>(
            stream: _authService.userDataStream,
            builder: (context, userSnapshot) {
              if (userSnapshot.hasData && userSnapshot.data != null) {
                UserModel userData = userSnapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name: ${userData.fullName}'),
                    Text('Role: ${userData.userRole}'),
                    Text('Building ID: ${userData.buildingId}'),
                    if (userData.unitId != null)
                      Text('Unit ID: ${userData.unitId}'),
                    if (userData.department != null)
                      Text('Department: ${userData.department}'),
                    Text('Status: ${userData.status}'),
                  ],
                );
              }
              return Text('Loading user data...');
            },
          ),

          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _signOut,
            child: Text('Sign Out'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthView() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'FacilityFix Authentication Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              items: [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
                DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _message.contains('Error')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _message.contains('Error') ? Colors.red : Colors.green,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color:
                        _message.contains('Error')
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      setState(() {
        _message = 'Error: Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userRole: _selectedRole,
        buildingId: 'building_001', // Default building ID
        department: _selectedRole == 'staff' ? 'maintenance' : null,
      );

      setState(() {
        _message = 'Account created successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Error: Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _message = 'Signed in successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();
      _clearFields();
    } catch (e) {
      setState(() {
        _message = 'Error signing out: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    setState(() {
      _selectedRole = 'tenant';
      _message = '';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
