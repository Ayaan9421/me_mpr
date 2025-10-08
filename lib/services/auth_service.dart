import 'package:firebase_auth/firebase_auth.dart';
import 'package:me_mpr/failure/auth_result.dart';
import 'package:me_mpr/failure/failure.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  Future<Either<AppFailure, AuthResult>> signInWithGoogle() async {
    try {
      _googleSignIn.initialize(serverClientId: dotenv.env['SERVER_CLIENT_ID']);

      final googleUser = await _googleSignIn.authenticate();

      // ignore: unnecessary_null_comparison
      if (googleUser == null) {
        return Left(AppFailure("Google Sign-In aborted by user"));
      }

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        return Right(AuthResult(user: result.user!, isNewUser: isNewUser));
      }
      return Left(AppFailure("Failed to retrieve user from Google sign-in"));
    } on FirebaseAuthException catch (e) {
      return Left(AppFailure("FirebaseAuth error: ${e.message}"));
    } catch (e) {
      return Left(AppFailure("Unexpected error: $e"));
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
