import 'package:flutter/material.dart';

/// A class to hold the custom color palette for the app.
class AppColors {
  // Main Palette
  static const Color primaryBlue = Color(0xFFB3E5FC); // Light blue for app bars
  static const Color background = Color(
    0xFFF1F8E9,
  ); // Light, calming green/yellow
  static const Color accentYellow = Color(
    0xFFFFC107,
  ); // Bright yellow for FABs and accents

  // Component Colors
  static const Color cardBackground = Colors.white;
  static const Color primaryAccent = Color(
    0xFF009688,
  ); // Teal for primary actions

  // Text Colors
  static const Color primaryText = Colors.black87;
  static const Color secondaryText = Colors.grey;

  // Mood & Status Colors
  static const Color moodGood = Color(
    0xFFA5D6A7,
  ); // Light green for positive moods
  static const Color error = Colors.redAccent;
}
