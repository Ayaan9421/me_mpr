import 'package:flutter/material.dart';
import 'package:me_mpr/models/therapy_recommendation.dart';
import 'package:me_mpr/screens/Therapies/breathing_exercise_page.dart';
import 'package:me_mpr/screens/Therapies/mediation_timer_page.dart';
import 'package:me_mpr/screens/Therapies/therapy_guide_page.dart';
import 'package:me_mpr/utils/app_colors.dart';

class TherapyCard extends StatelessWidget {
  final TherapyRecommendation recommendation;

  const TherapyCard({super.key, required this.recommendation});

  // --- NEW: Navigation Logic ---
  void _navigateToActivity(BuildContext context) {
    // Determine which page to navigate to
    Widget targetPage;
    List<String> guideSteps = []; // For TherapyGuidePage

    switch (recommendation.title) {
      case 'Guided Meditation':
        targetPage = const MeditationTimerPage();
        break;
      case 'Box Breathing Exercise': // Title updated for clarity
        targetPage = const BreathingExercisePage();
        break;
      case 'Positive Affirmations':
        guideSteps = [
          "Find a quiet space where you won't be disturbed.",
          "Stand or sit comfortably, perhaps in front of a mirror.",
          "Take a few deep breaths to center yourself.",
          "Repeat positive statements about yourself (e.g., 'I am capable', 'I am worthy', 'I handle challenges well').",
          "Say them out loud or silently, focusing on believing the words.",
          "Continue for 2-5 minutes.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Mindful Walking':
        guideSteps = [
          "Choose a place where you can walk without too many distractions.",
          "Start walking at a natural, comfortable pace.",
          "Bring your awareness to the sensation of your feet touching the ground.",
          "Notice the movement in your legs and body.",
          "Pay attention to your breath as you walk.",
          "Expand your awareness to the sights, sounds, and smells around you without judgment.",
          "Continue for 5-10 minutes.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Visualization Exercise':
        guideSteps = [
          "Find a comfortable position, sitting or lying down.",
          "Close your eyes and take several slow, deep breaths.",
          "Imagine a place where you feel completely safe, calm, and happy (e.g., a beach, a forest).",
          "Engage all your senses: What do you see? Hear? Smell? Feel?",
          "Spend 5-10 minutes exploring this peaceful place in your mind.",
          "When ready, slowly bring your awareness back to the room and open your eyes.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Journal Prompts':
        guideSteps = [
          "Find a quiet space and a notebook or use the app's journal feature.",
          "Consider these prompts (or others that resonate):",
          " - What am I grateful for today, even if small?",
          " - What emotions am I feeling right now, and where do I feel them in my body?",
          " - What is one thing I can control in this situation?",
          " - What would my compassionate self say to me right now?",
          "Write freely for 5-10 minutes without judgment.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Physical Activity / Exercise':
        guideSteps = [
          "Choose a simple activity you can do right now (e.g., jumping jacks, stretching, walking up/down stairs, dancing).",
          "Set a timer for 5-10 minutes.",
          "Focus on the physical sensations in your body as you move.",
          "Move at a pace that feels energizing but not overwhelming.",
          "Notice how your mood shifts during and after the activity.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Cold Water Splash / Relaxation Technique':
        guideSteps = [
          "Go to a sink.",
          "Cup your hands and fill them with cold water.",
          "Gently splash the cold water onto your face.",
          "Alternatively, hold an ice cube in your hand and focus on the sensation.",
          "Take several slow, deep breaths.",
          "This activates the mammalian diving reflex, which can quickly calm the nervous system.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Listen to Uplifting Music':
        guideSteps = [
          "Choose music that generally makes you feel good, hopeful, or energized.",
          "Put on headphones or play it in a space where you can focus.",
          "Close your eyes or engage in a simple activity (like tidying up).",
          "Allow yourself to feel the rhythm and melody.",
          "Notice any shifts in your mood or energy levels.",
          "Listen for at least 5-10 minutes.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      case 'Connect with a Friend or Family Member':
        guideSteps = [
          "Think of someone you trust and feel comfortable talking to.",
          "Reach out via text, call, or in person.",
          "You don't have to discuss deep problems; simply sharing your day or asking about theirs can help.",
          "Focus on the connection and feeling less alone.",
          "If you don't feel like talking, just being in the presence of someone supportive can be beneficial.",
        ];
        targetPage = TherapyGuidePage(
          recommendation: recommendation,
          steps: guideSteps,
        );
        break;
      // Default Case (shouldn't happen if titles match)
      default:
        print("Unknown therapy title: ${recommendation.title}");
        return; // Don't navigate
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: recommendation.iconColor.withOpacity(0.15),
              child: Icon(
                recommendation.icon,
                color: recommendation.iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      // TODO: Implement navigation/action later
                      onPressed: () => _navigateToActivity(context),
                      child: const Text('Start Now →'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
