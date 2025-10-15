import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class InsightsSection extends StatelessWidget {
  final List<String> insights;

  const InsightsSection({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  insight,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
