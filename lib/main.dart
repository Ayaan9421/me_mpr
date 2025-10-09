import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_mpr/auth/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindEase', // your app name
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // light yellow
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB3E5FC), // light blue
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107), // yellow FAB
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB3E5FC),
        ),
        useMaterial3: true,
      ),

      // ✅ AuthGate decides: LoginPage OR HomePage
      home: const AuthGate(),
    );
  }
}
