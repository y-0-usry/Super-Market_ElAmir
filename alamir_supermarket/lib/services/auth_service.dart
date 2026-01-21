import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Normalize phone to digits only
  String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits;
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes (للـ Session Persistence)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Get current user data error: $e');
    }
    return null;
  }

  // Sign up with phone and password
  Future<UserModel?> signUp({
    required String phone,
    required String password,
    required String name,
    required String role, // 'customer', 'admin', 'owner'
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      if (normalizedPhone.length < 8) {
        throw FirebaseAuthException(
          code: 'invalid-phone-number',
          message: 'رقم الموبايل غير صالح',
        );
      }

      // Convert phone to email format: phone@alamir.local
      String email = '$normalizedPhone@alamir.local';
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          phone: normalizedPhone,
          email: email,
          role: role,
          isActive: true,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('unknown-signup-error');
    }
    return null;
  }

  // Sign in with phone and password
  Future<UserModel?> signIn({
    required String phone,
    required String password,
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      if (normalizedPhone.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-phone-number',
          message: 'رقم الموبايل غير صالح',
        );
      }

      // Convert phone to email format
      String email = '$normalizedPhone@alamir.local';
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          UserModel userData = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          
          // Update last login
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': Timestamp.now(),
          });

          return userData;
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('unknown-signin-error');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get user data error: $e');
    }
    return null;
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Add address to user
  Future<void> addAddress(String uid, String address) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        List<String> addresses = List.from(user.addresses);
        addresses.add(address);
        await _firestore.collection('users').doc(uid).update({
          'addresses': addresses,
        });
      }
    } catch (e) {
      print('Add address error: $e');
      rethrow;
    }
  }

  // Remove address from user
  Future<void> removeAddress(String uid, String address) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        List<String> addresses = List.from(user.addresses);
        addresses.remove(address);
        await _firestore.collection('users').doc(uid).update({
          'addresses': addresses,
        });
      }
    } catch (e) {
      print('Remove address error: $e');
      rethrow;
    }
  }
}
