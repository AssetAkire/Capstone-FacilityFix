import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/enums.dart';
import '../models/database_schema.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole userRole,
    String? buildingId,
    String? unitId,
  }) async {
    try {
      // Create user with Firebase Auth directly
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        // Create user profile in Firestore
        final userData = {
          FieldNames.USER_ID: user.uid,
          FieldNames.EMAIL: email,
          FieldNames.FIRST_NAME: firstName,
          FieldNames.LAST_NAME: lastName,
          FieldNames.USER_ROLE: userRole.name,
          FieldNames.STATUS: UserStatus.active.name,
          FieldNames.CREATED_AT: FieldValue.serverTimestamp(),
          FieldNames.UPDATED_AT: FieldValue.serverTimestamp(),
        };

        // Add optional fields if provided
        if (buildingId != null) userData[FieldNames.BUILDING_ID] = buildingId;
        if (unitId != null) userData[FieldNames.UNIT_ID] = unitId;

        await _firestore
            .collection(DatabaseSchema.USERS)
            .doc(user.uid)
            .set(userData);

        // Return the created user model
        final userDoc =
            await _firestore
                .collection(DatabaseSchema.USERS)
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print(
        'FirebaseAuthException during registration: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  // Sign in user with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userDoc =
            await _firestore
                .collection(DatabaseSchema.USERS)
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserRole?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc =
          await _firestore.collection(DatabaseSchema.USERS).doc(user.uid).get();
      if (userDoc.exists) {
        final roleString = userDoc.data()?[FieldNames.USER_ROLE] as String?;
        if (roleString != null) {
          return UserRole.values.firstWhere(
            (e) => e.name == roleString,
            orElse: () => UserRole.tenant,
          );
        }
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return null;
  }

  // Stream of current user's authentication state
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Stream of current user's profile from Firestore
  Stream<UserModel?> get currentUserProfileStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      } else {
        return _firestore
            .collection(DatabaseSchema.USERS)
            .doc(user.uid)
            .snapshots()
            .map((doc) {
              if (doc.exists) {
                return UserModel.fromFirestore(doc);
              } else {
                return null;
              }
            });
      }
    });
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data[FieldNames.UPDATED_AT] = FieldValue.serverTimestamp();
    await _firestore.collection(DatabaseSchema.USERS).doc(uid).update(data);
  }

  Future<void> setUserRole(String targetUid, UserRole newRole) async {
    try {
      // Check if current user is admin
      final currentRole = await getCurrentUserRole();
      if (currentRole != UserRole.admin) {
        throw Exception('Only admins can change user roles');
      }

      await _firestore.collection(DatabaseSchema.USERS).doc(targetUid).update({
        FieldNames.USER_ROLE: newRole.name,
        FieldNames.UPDATED_AT: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting user role: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String targetUid) async {
    try {
      // Check if current user is admin
      final currentRole = await getCurrentUserRole();
      if (currentRole != UserRole.admin) {
        throw Exception('Only admins can delete users');
      }

      // Delete user document from Firestore
      await _firestore.collection(DatabaseSchema.USERS).doc(targetUid).delete();

      // Note: Cannot delete Firebase Auth user from client side
      // This would need to be done manually in Firebase Console or via Admin SDK
      print(
        'User document deleted. Firebase Auth user must be deleted manually from console.',
      );
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
