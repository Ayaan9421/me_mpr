import 'package:flutter/material.dart';
import 'package:me_mpr/failure/depression_report.dart';
import 'package:me_mpr/utils/app_colors.dart';

class EmotionBarChart extends StatelessWidget {
  final List<EmotionDetail> emotions;

  const EmotionBarChart({super.key, required this.emotions});

  @override
  Widget build(BuildContext context) {
    // A palette of beautiful gradients for the chart bars
    final List<Gradient> gradientPalette = [
      const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF93C5FD)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Blue
      const LinearGradient(
        colors: [Color(0xFFFFA781), Color(0xFFFFD1AD)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Peach
      const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFFA7F3D0)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Green
      const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFFDE68A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Amber
      const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFC4B5FD)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Purple
      const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF9A8D4)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ), // Pink
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotion Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(emotions.length, (index) {
              final emotion = emotions[index];
              return _buildEmotionBar(
                context,
                label: emotion.label,
                score: emotion.score,
                gradient: gradientPalette[index % gradientPalette.length],
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UPDATED TO USE GRADIENTS ---
  Widget _buildEmotionBar(
    BuildContext context, {
    required String label,
    required double score,
    required Gradient gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            // Replaced LinearProgressIndicator with a custom gradient container
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 16,
                color: AppColors.border,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: score,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${(score * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
