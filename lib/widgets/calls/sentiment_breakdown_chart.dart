import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class SentimentBreakdownChart extends StatelessWidget {
  final double positive;
  final double neutral;
  final double negative;

  const SentimentBreakdownChart({
    super.key,
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Call Sentiment Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSentimentBar(
              label: 'Positive',
              score: positive,
              gradient: const LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFFA7F3D0)],
              ),
            ),
            _buildSentimentBar(
              label: 'Neutral',
              score: neutral,
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFFDE68A)],
              ),
            ),
            _buildSentimentBar(
              label: 'Negative',
              score: negative,
              gradient: const LinearGradient(
                colors: [Color(0xFFF87171), Color(0xFFFCA5A5)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentBar({
    required String label,
    required double score,
    required Gradient gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
