import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.sendEmailVerification();
    await _firebaseAuth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "An email for verification is successfully sent. Kindly verify and sign in.")));
  }

  Future<bool> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    if (_firebaseAuth.currentUser != null &&
        !_firebaseAuth.currentUser!.emailVerified) {
      print(_firebaseAuth.currentUser!.emailVerified);
      await _firebaseAuth.signOut();
      return false;
    }
    return true;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser!;
    await user.reload(); // Reload user to get the latest data
    return user.emailVerified;
  }

  Future<void> sendVerificationEmail() async {
    User user = _firebaseAuth.currentUser!;
    await user.sendEmailVerification();
  }

  Future<User?> getCurrentUser() async {
    User user = _firebaseAuth.currentUser!;
    return user;
  }
}
