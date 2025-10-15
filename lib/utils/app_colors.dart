import 'package:flutter/material.dart';

/// A class to hold the modernized, calming color palette for the app.
class AppColors {
  // --- Primary Palette ---
  /// A calm, trustworthy blue. The main brand color.
  static const Color primary = Color(0xFF3B82F6);

  /// A slightly darker blue for hover/pressed states.
  static const Color primaryDark = Color(0xFF2563EB);

  /// The main background color. A very light, soft grey-blue.
  static const Color background = Color(0xFFF3F6FB);

  // --- Accent Palette ---
  /// A warm, gentle peach for positive accents and highlights.
  static const Color accent = Color(0xFFFFA781);

  /// A soft, encouraging yellow for secondary accents.
  static const Color accentYellow = Color(0xFFFFD073);

  // --- Component & Text Colors ---
  /// The default background for cards and surfaces.
  static const Color cardBackground = Colors.white;

  /// The primary color for text. A dark, readable charcoal.
  static const Color primaryText = Color(0xFF1F2937);

  /// A softer grey for subtitles and secondary information.
  static const Color secondaryText = Color(0xFF6B7280);

  /// The color for borders and dividers.
  static const Color border = Color(0xFFE5E7EB);

  // --- Status & Mood Colors ---
  /// A gentle green for success messages and positive moods.
  static const Color success = Color(0xFF34D399);

  /// A soft, muted red for error states and warnings.
  static const Color error = Color(0xFFF87171);

  /// A gentle amber for informational alerts or warnings.
  static const Color warning = Color(0xFFFBBF24);
}
