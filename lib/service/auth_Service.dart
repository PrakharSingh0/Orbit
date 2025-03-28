import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  // Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Check if profile setup is complete
  Future<bool> isProfileSetupComplete(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) return false; // If document doesn't exist, return false

    // Check if 'userTag' exists in the document
    var data = userDoc.data() as Map<String, dynamic>?;

    return data != null && data.containsKey('userTag') && data['userTag'] != null;
  }


  // Complete profile setup
  Future<void> completeProfileSetup(String uid, String userName, String userTag, String dob, String location, String? email,Timestamp createdAt) async {
    await _firestore.collection('users').doc(uid).set({
      "createdAt" : createdAt,
      "email": email,
      "follower":0,
      "following":0,
      "onlineStatus":true,
      'userName': userName,
      'userTag': userTag,
      'dob': dob,
      'location': location,
    });
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email);
  }
}