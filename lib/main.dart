import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/auth/auth_gate.dart';   

import 'firebase_options.dart'; 
import 'package:me_mpr/screens/call_analysis_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter', // A clean, friendly font
        // Define the color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          background: AppColors.background,
          primary: AppColors.primaryAccent,
          secondary: AppColors.accentYellow,
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.primaryText,
          elevation: 2,
          surfaceTintColor: Colors.transparent, // Prevents tint on scroll
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primaryText,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 3,
          shadowColor: Colors.black12,
          color: AppColors.cardBackground,
          surfaceTintColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // FAB Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accentYellow,
          foregroundColor: Colors.white,
          elevation: 6,
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryAccent,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Bottom App Bar Theme
        bottomAppBarTheme: BottomAppBarThemeData(
          color: AppColors.cardBackground,
          surfaceTintColor: AppColors.cardBackground,
          elevation: 8,
        ),
      ),

// In lib/main.dart's build method
home: const AuthGate(), // Temporarily set this for testing
    );
  }
}
