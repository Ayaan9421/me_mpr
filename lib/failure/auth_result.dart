import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final User user;
  final bool isNewUser;

  AuthResult({required this.user, required this.isNewUser});
}
