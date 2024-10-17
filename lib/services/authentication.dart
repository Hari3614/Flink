import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  late String _userUid;
  String get getUserUid => _userUid;

  //<<<<<<<< create Account >>>>>>>>

  Future<void> createAccount(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        _userUid = user.uid;
        print('User UID: $_userUid');
        notifyListeners();
      } else {
        print('Failed to get user after sign in.');
      }
    } catch (e) {
      print('Error during sign-in: $e'); // Print the error message
    }
  }

  Future logOutViaEmail() {
    return firebaseAuth.signOut();
  }

//<<<<<<<< Google SignIn >>>>>>>>

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        print('Sign in aborted by user');
        return false; // Return false if the user cancels sign-in
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(authCredential);

      final User? user = userCredential.user;
      assert(user?.uid != null);

      _userUid = user!.uid; // Save the user ID
      print('Google user uid => $_userUid');

      notifyListeners(); // Notify listeners about the change

      return true; // Return true on successful sign-in
    } catch (e) {
      print('Error signing in with Google: $e');
      return false; // Return false on error
    }
  }
}