import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'email_auth.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<UserCredential> appleSignIn() async {
  UserCredential userCredential;
  
  if (kIsWeb) {
    final provider = OAuthProvider("apple.com")
      ..addScope('email')
      ..addScope('name');

    // Sign in the user with Firebase.
    userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
  } else {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    final displayName = [appleCredential.givenName, appleCredential.familyName]
        .where((name) => name != null)
        .join(' ');

    // The display name does not automatically come with the user.
    if (displayName.isNotEmpty) {
      await userCredential.user?.updateDisplayName(displayName);
    }
  }
  
  // Validate email domain after sign-in
  final email = userCredential.user?.email;
  if (email != null && !isValidStudentEmail(email)) {
    // Sign out the user if email domain is not valid
    await FirebaseAuth.instance.signOut();
    throw FirebaseAuthException(
      code: 'invalid-email-domain',
      message: 'Only Antiques Pride School email addresses (@antiquespride.edu.ph) are allowed.',
    );
  }

  return userCredential;
}
