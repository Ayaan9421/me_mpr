import 'package:flutter/material.dart';

class TherapyRecommendation {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  // Could add a route or action later (e.g., navigate to MeditationTimerPage)

  TherapyRecommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
