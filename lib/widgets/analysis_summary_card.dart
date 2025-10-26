import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class AnalysisSummaryCard extends StatelessWidget {
  final int score;
  final String description;

  const AnalysisSummaryCard({
    super.key,
    required this.score,
    required this.description,
  });

  Color _getScoreColor(int score) {
    if (score <= 3) return AppColors.success;
    if (score <= 6) return AppColors.accentYellow;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 10.0,
                    strokeWidth: 8,
                    backgroundColor: _getScoreColor(score).withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(score),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Depression Score Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      height: 1.4,
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
