import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About MindEase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.spa_outlined, // Or your app logo icon
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'MindEase',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Your Personal Mental Wellness Companion',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            ),
            const Divider(height: 40),

            _buildSectionTitle('How It Works'),
            _buildParagraph(
              'MindEase helps you understand your emotional state through AI-powered analysis of your journal entries and call recordings (with your explicit consent).',
            ),
            _buildParagraph(
              'Simply write a diary entry or record your thoughts using the voice journal feature. You can also allow the app to analyze selected call recordings saved on your device.',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('AI Analysis'),
            _buildParagraph(
              'Our AI analyzes the text (from typed entries or transcribed audio) and the emotional tone of your voice recordings to provide insights into your mood, potential risks, and helpful advice. This includes a depression score (0-10) based on the 5 stages model (Acceptance, Denial, Bargaining, Anger, Depression).',
            ),
            _buildParagraph(
              'For call recordings, the AI also generates a brief summary of the conversation.',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Mood Tracking'),
            _buildParagraph(
              'The app tracks your mood trends over the week based on your analyzed entries (both diary and calls). Keep journaling daily to build your streak and see how your mood evolves!',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Therapies & Support'),
            _buildParagraph(
              'Based on your weekly mood average, the app suggests helpful activities like guided meditations, breathing exercises, or journaling prompts. It also provides information on nearby therapists (using map data).',
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Privacy'),
            _buildParagraph(
              'Your privacy is crucial. Diary entries and call analyses are stored securely on your device\'s local storage. Call recordings themselves are *never* uploaded or stored by the app – analysis happens based on the files you select directly from your phone.',
            ),
            _buildParagraph(
              'Location data is only used to display nearby therapists on the map when you access the feature and grant permission.',
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0', // Replace with your actual version
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Made with ❤️ by Aayush',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}
