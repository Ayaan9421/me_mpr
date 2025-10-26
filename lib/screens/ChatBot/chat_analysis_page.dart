import 'package:flutter/material.dart';
import 'package:me_mpr/models/depression_report.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/Daily%20Diary/emotion_bar_chart.dart';
import 'package:me_mpr/widgets/Daily%20Diary/risk_and_advice_section.dart';
import 'package:me_mpr/widgets/analysis_summary_card.dart';

class ChatAnalysisPage extends StatelessWidget {
  final DepressionReport report;

  const ChatAnalysisPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Analysis Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AnalysisSummaryCard(
              score: report.depressionScore,
              description: report.description,
            ),
            const SizedBox(height: 16),
            if (report.emotions.isNotEmpty) ...[
              EmotionBarChart(emotions: report.emotions),
              const SizedBox(height: 16),
            ],
            RiskAndAdviceSection(
              title: 'Potential Risks Identified',
              items: report.risks,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.error,
            ),
            const SizedBox(height: 16),
            RiskAndAdviceSection(
              title: 'Helpful Advice Suggested',
              items: report.advice,
              icon: Icons.lightbulb_outline_rounded,
              iconColor: AppColors.success,
            ),
            const SizedBox(height: 24),
            // Optionally display the full transcript if needed
            if (report.transcript != null && report.transcript!.isNotEmpty) ...[
              const Text(
                'Full Conversation Analyzed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.background, // Slightly different background
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    report.transcript!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
