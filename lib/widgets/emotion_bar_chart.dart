import 'package:flutter/material.dart';
import 'package:me_mpr/failure/depression_report.dart';
import 'package:me_mpr/utils/app_colors.dart';

class EmotionBarChart extends StatelessWidget {
  final List<EmotionDetail> emotions;

  const EmotionBarChart({super.key, required this.emotions});

  @override
  Widget build(BuildContext context) {
    // Sort emotions by score for better visualization
    final sortedEmotions = List<EmotionDetail>.from(emotions)
      ..sort((a, b) => b.score.compareTo(a.score));

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
            ...sortedEmotions.map((emotion) => _buildEmotionBar(emotion)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionBar(EmotionDetail emotion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${emotion.label[0].toUpperCase()}${emotion.label.substring(1)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: emotion.score,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${(emotion.score * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
