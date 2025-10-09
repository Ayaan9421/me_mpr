import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:me_mpr/screens/home_page.dart';
import 'package:me_mpr/screens/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Show loading while waiting for Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF1F8E9), // Light yellow background
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFC107), // Yellow loader
              ),
            ),
          );
        }

        // ✅ If user is logged in, go to HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }

        // ❌ If user not logged in, go to LoginPage
        else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Something went wrong. Please restart the app.',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
