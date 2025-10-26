import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:me_mpr/utils/app_colors.dart'; // Import AppColors

class AiTypingIndicator extends StatelessWidget {
  const AiTypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground, // Use card background
          border: Border.all(color: AppColors.border), // Use border color
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: SizedBox(
          height: 20, // Constrain height to match text line height
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 20.0, // Adjust size to look like dots
              color: AppColors.secondaryText, // Use secondary text color
            ),
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                WavyAnimatedText(
                  '...',
                  speed: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
