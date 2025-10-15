import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class CallDetailView extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;
  final Map<String, dynamic> analysisData;

  const CallDetailView({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          const Text(
            'Call Sentiment Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Positive',
            analysisData['positive'],
            AppColors.success,
          ),
          _buildProgressBar(
            'Neutral',
            analysisData['neutral'],
            AppColors.warning,
          ),
          _buildProgressBar(
            'Negative',
            analysisData['negative'],
            AppColors.error,
          ),
          const SizedBox(height: 24),
          const Text(
            'Key Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...(analysisData['insights'] as List<String>)
              .map(_buildInsightTile)
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Caller: $caller',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: $date',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: $duration',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    final gradient = LinearGradient(
      colors: [color.withOpacity(0.7), color],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              color: AppColors.border,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
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
        ],
      ),
    );
  }

  Widget _buildInsightTile(String text) {
    return ListTile(
      leading: const Icon(Icons.insights_rounded, color: AppColors.primary),
      title: Text(
        text,
        style: const TextStyle(fontSize: 15, color: AppColors.secondaryText),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
