import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_auth.dart';

final _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);

Future<UserCredential?> googleSignInFunc() async {
  UserCredential? userCredential;
  
  if (kIsWeb) {
    // Once signed in, return the UserCredential
    userCredential = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  } else {
    await signOutWithGoogle().catchError((_) => null);
    final auth = await (await _googleSignIn.signIn())?.authentication;
    if (auth == null) {
      return null;
    }
    final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);
    userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  }
  
  // Validate email domain after sign-in
  final email = userCredential.user?.email;
  if (email != null && !isValidStudentEmail(email)) {
    // Sign out the user if email domain is not valid
    await FirebaseAuth.instance.signOut();
    await signOutWithGoogle();
    throw FirebaseAuthException(
      code: 'invalid-email-domain',
      message: 'Only Antiques Pride School email addresses (@antiquespride.edu.ph) are allowed.',
    );
  }
  
  return userCredential;
}

Future signOutWithGoogle() => _googleSignIn.signOut();
