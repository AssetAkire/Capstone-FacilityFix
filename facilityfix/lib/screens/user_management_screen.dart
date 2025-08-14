import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../models/enums.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  // Registration controllers
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regFirstNameController = TextEditingController();
  final _regLastNameController = TextEditingController();
  UserRole _regSelectedRole = UserRole.tenant;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Profile update controllers
  final _profileFirstNameController = TextEditingController();
  final _profileLastNameController = TextEditingController();
  final _profilePhoneController = TextEditingController();

  String _message = '';
  bool _isLoading = false;
  UserModel? _currentUserProfile;
  UserRole? _currentUserRole;
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _authService.userChanges.listen((user) {
      _fetchCurrentUserProfileAndRole();
      _fetchAllUsers(); // Refresh user list on auth state change
    });
    _fetchCurrentUserProfileAndRole();
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regFirstNameController.dispose();
    _regLastNameController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _profileFirstNameController.dispose();
    _profileLastNameController.dispose();
    _profilePhoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserProfileAndRole() async {
    setState(() {
      _isLoading = true;
      _message = 'Fetching user data...';
    });
    try {
      final firebaseUser = _authService.getCurrentFirebaseUser();
      if (firebaseUser != null) {
        _currentUserProfile = await _databaseService.getUser(firebaseUser.uid);
        _currentUserRole = await _authService.getCurrentUserRole();
        if (_currentUserProfile != null) {
          _profileFirstNameController.text = _currentUserProfile!.firstName;
          _profileLastNameController.text = _currentUserProfile!.lastName;
          _profilePhoneController.text = _currentUserProfile!.phoneNumber ?? '';
        }
        _message = 'User data loaded.';
      } else {
        _currentUserProfile = null;
        _currentUserRole = null;
        _message = 'No user logged in.';
      }
    } catch (e) {
      _message = 'Error fetching user data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllUsers() async {
    if (_currentUserRole == UserRole.admin) {
      setState(() {
        _isLoading = true;
        _message = 'Fetching all users...';
      });
      try {
        _allUsers =
            await _databaseService.getUsersStream().first; // Get current list
        _message = 'All users loaded.';
      } catch (e) {
        _message = 'Error fetching all users: $e';
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _allUsers = []; // Clear list if not admin
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _message = 'Registering user...';
    });
    try {
      await _authService.registerUser(
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text.trim(),
        firstName: _regFirstNameController.text.trim(),
        lastName: _regLastNameController.text.trim(),
        userRole: _regSelectedRole,
        buildingId: 'building_001', // Default for new users
      );
      _message = 'Registration successful! Please log in.';
      _regEmailController.clear();
      _regPasswordController.clear();
      _regFirstNameController.clear();
      _regLastNameController.clear();
    } catch (e) {
      _message = 'Registration failed: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _message = 'Signing in...';
    });
    try {
      await _authService.signIn(
        _loginEmailController.text.trim(),
        _loginPasswordController.text.trim(),
      );
      _message = 'Signed in successfully!';
      _loginEmailController.clear();
      _loginPasswordController.clear();
    } catch (e) {
      _message = 'Sign-in failed: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _message = 'Signing out...';
    });
    try {
      await _authService.signOut();
      _message = 'Signed out successfully!';
    } catch (e) {
      _message = 'Sign-out failed: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUserProfile == null) {
      setState(() {
        _message = 'No user logged in to update profile.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = 'Updating profile...';
    });
    try {
      await _authService.updateUserProfile(_currentUserProfile!.id, {
        'first_name': _profileFirstNameController.text.trim(),
        'last_name': _profileLastNameController.text.trim(),
        'phone_number': _profilePhoneController.text.trim(),
      });
      _message = 'Profile updated successfully!';
    } catch (e) {
      _message = 'Profile update failed: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeUserRole(String targetUid, UserRole newRole) async {
    setState(() {
      _isLoading = true;
      _message = 'Changing user role...';
    });
    try {
      await _authService.setUserRole(targetUid, newRole);
      _message = 'User role updated successfully!';
      await _fetchAllUsers(); // Refresh list
    } catch (e) {
      _message = 'Failed to change role: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String targetUid) async {
    setState(() {
      _isLoading = true;
      _message = 'Deleting user...';
    });
    try {
      await _authService.deleteUser(targetUid);
      _message = 'User deleted successfully!';
      await _fetchAllUsers(); // Refresh list
    } catch (e) {
      _message = 'Failed to delete user: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Message
                    if (_message.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color:
                              _message.contains('failed') ||
                                      _message.contains('Error')
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _message.contains('failed') ||
                                        _message.contains('Error')
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color:
                                _message.contains('failed') ||
                                        _message.contains('Error')
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Current User Info
                    Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current User Info',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${_authService.getCurrentFirebaseUser()?.email ?? 'N/A'}',
                            ),
                            Text(
                              'UID: ${_authService.getCurrentFirebaseUser()?.uid ?? 'N/A'}',
                            ),
                            Text('Role: ${_currentUserRole?.name ?? 'N/A'}'),
                            if (_currentUserProfile != null) ...[
                              Text('Name: ${_currentUserProfile!.fullName}'),
                              Text(
                                'Phone: ${_currentUserProfile!.phoneNumber ?? 'N/A'}',
                              ),
                              Text(
                                'Building ID: ${_currentUserProfile!.buildingId ?? 'N/A'}',
                              ),
                            ],
                            SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      _authService.getCurrentFirebaseUser() ==
                                              null
                                          ? null
                                          : _signOut,
                                  child: Text('Sign Out'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _fetchCurrentUserProfileAndRole,
                                  child: Text('Refresh User Info'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Registration Form
                    _buildSectionCard(
                      context,
                      title: 'Register New User',
                      children: [
                        TextField(
                          controller: _regEmailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _regPasswordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        TextField(
                          controller: _regFirstNameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                        TextField(
                          controller: _regLastNameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                        DropdownButtonFormField<UserRole>(
                          value: _regSelectedRole,
                          decoration: InputDecoration(labelText: 'Role'),
                          items:
                              UserRole.values.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role.name.toUpperCase()),
                                );
                              }).toList(),
                          onChanged: (role) {
                            if (role != null) {
                              setState(() {
                                _regSelectedRole = role;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _register,
                          child: Text('Register'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Login Form
                    _buildSectionCard(
                      context,
                      title: 'Sign In',
                      children: [
                        TextField(
                          controller: _loginEmailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _loginPasswordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _signIn,
                          child: Text('Sign In'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Profile Management
                    _buildSectionCard(
                      context,
                      title: 'Update Profile',
                      children: [
                        TextField(
                          controller: _profileFirstNameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                        TextField(
                          controller: _profileLastNameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                        TextField(
                          controller: _profilePhoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              _currentUserProfile == null
                                  ? null
                                  : _updateProfile,
                          child: Text('Update Profile'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Admin User Management (only visible to Admin)
                    if (_currentUserRole == UserRole.admin)
                      _buildSectionCard(
                        context,
                        title: 'Admin: Manage Users',
                        children: [
                          ElevatedButton(
                            onPressed: _fetchAllUsers,
                            child: Text('Refresh All Users'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (_allUsers.isEmpty)
                            Text(
                              'No other users found or you are not an admin.',
                            )
                          else
                            ..._allUsers.map((user) {
                              if (user.id ==
                                  _authService.getCurrentFirebaseUser()?.uid) {
                                return SizedBox.shrink(); // Don't show current admin user
                              }
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${user.fullName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('Email: ${user.email}'),
                                      Text(
                                        'Role: ${user.userRole.name.toUpperCase()}',
                                      ),
                                      Text('UID: ${user.id}'),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          DropdownButton<UserRole>(
                                            value: user.userRole,
                                            onChanged: (UserRole? newRole) {
                                              if (newRole != null) {
                                                _changeUserRole(
                                                  user.id,
                                                  newRole,
                                                );
                                              }
                                            },
                                            items:
                                                UserRole.values.map((role) {
                                                  return DropdownMenuItem(
                                                    value: role,
                                                    child: Text(
                                                      'Set to ${role.name.toUpperCase()}',
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed:
                                                () => _deleteUser(user.id),
                                            child: Text('Delete User'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
