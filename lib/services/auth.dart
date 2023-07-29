import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  // Future<void> googleLogin() async {
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) return;

  //     final googleAuth = await googleUser.authentication;
  //     final authCredential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(authCredential);
  //     await FirestoreService().createUser(googleUser.displayName ?? 'Unknown Player', googleUser.photoUrl);
  //   } on FirebaseAuthException catch (e) {
  //     debugPrint('error: ' + e.toString());
  //   }
  // }

  Future<User?> emailPassLogin(String email, String password) async {
    final authCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    return authCredential.user;
  }

  Future<User?> createUser(String email, String password) async {
    final authCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    return authCredential.user;
  }

  Future<bool> isEmailVerified() async {
    await user!.reload();
    return user!.emailVerified;
  }

  Future sendVerificationEmail() async {
    await user!.sendEmailVerification();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> resetPassword({required String email}) async {
    debugPrint('reset password. email: ' + email);
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteUser() async {
    user!.delete();
  }
}
