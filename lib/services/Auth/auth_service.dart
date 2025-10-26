import 'package:firebase_auth/firebase_auth.dart';
import 'package:me_mpr/models/auth_result.dart';
import 'package:me_mpr/failure/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn.instance;
  }

  Future<Either<AppFailure, AuthResult>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      // print(user);
      // print(result.additionalUserInfo);
      // var token = await user!.getIdToken();
      // print(token);
      if (user != null) {
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        return Right(AuthResult(user: user, isNewUser: isNewUser));
      } else {
        return Left(AppFailure('User object is null after sign-in.'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AppFailure(e.message.toString()));
    } catch (e) {
      return Left(AppFailure('Unknown error: $e'));
    }
  }

  Future<Either<AppFailure, AuthResult>> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        return Right(AuthResult(user: user, isNewUser: isNewUser));
      } else {
        return Left(AppFailure('User object is null after sign-in.'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AppFailure(e.message.toString()));
    } catch (e) {
      return Left(AppFailure('Unknown error: $e'));
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<Either<AppFailure, String>> resetPasswordUsingEmail(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right("Password reset email sent successfully.");
    } on FirebaseAuthException catch (e) {
      return Left(AppFailure(e.message.toString()));
    } catch (e) {
      return Left(AppFailure('Unknown error: $e'));
    }
  }

  Future getToken() async {
    return await FirebaseAuth.instance.currentUser!.getIdToken();
  }
}
