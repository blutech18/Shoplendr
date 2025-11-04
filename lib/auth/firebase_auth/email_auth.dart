import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> emailSignInFunc(
  String email,
  String password,
) async {
  final trimmedEmail = email.trim();
  
  // Validate email domain
  if (!isValidStudentEmail(trimmedEmail)) {
    throw FirebaseAuthException(
      code: 'invalid-email-domain',
      message: 'Only Antiques Pride School email addresses (@antiquespride.edu.ph) are allowed.',
    );
  }
  
  return await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: trimmedEmail, password: password);
}

/// Validates if email is from allowed domain (Antiques Pride School)
bool isValidStudentEmail(String email) {
  final trimmedEmail = email.trim().toLowerCase();
  return trimmedEmail.endsWith('@antiquespride.edu.ph');
}

Future<UserCredential?> emailCreateAccountFunc(
  String email,
  String password,
) async {
  final trimmedEmail = email.trim();
  
  // Validate email domain
  if (!isValidStudentEmail(trimmedEmail)) {
    throw FirebaseAuthException(
      code: 'invalid-email-domain',
      message: 'Only Antiques Pride School email addresses (@antiquespride.edu.ph) are allowed.',
    );
  }
  
  return await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: trimmedEmail,
    password: password,
  );
}
