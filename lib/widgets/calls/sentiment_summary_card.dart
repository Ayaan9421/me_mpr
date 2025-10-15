import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class SentimentSummaryCard extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;

  const SentimentSummaryCard({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caller,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
