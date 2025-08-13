import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userRole,
    required String buildingId,
    String? unitId,
    String? department,
  }) async {
    try {
      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
        result.user!,
        firstName: firstName,
        lastName: lastName,
        userRole: userRole,
        buildingId: buildingId,
        unitId: unitId,
        department: department,
      );

      print('User created successfully: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw e;
    } catch (e) {
      print('Sign up error: $e');
      throw e;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw e;
    } catch (e) {
      print('Sign in error: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Sign out error: $e');
      throw e;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    required String firstName,
    required String lastName,
    required String userRole,
    required String buildingId,
    String? unitId,
    String? department,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'firstName': firstName,
        'lastName': lastName,
        'userRole': userRole,
        'buildingId': buildingId,
        'unitId': unitId,
        'department': department,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User document created in Firestore');
    } catch (e) {
      print('Error creating user document: $e');
      throw e;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Get user role
  Future<String?> getUserRole() async {
    UserModel? userData = await getUserData();
    return userData?.userRole.toString();
  }

  // Stream of user data
  Stream<UserModel?> get userDataStream {
    if (currentUser == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
