import 'package:flutter/material.dart';
import 'package:me_mpr/failure/call_analysis_report.dart';
import 'package:me_mpr/services/call_storage_service.dart';
import 'package:me_mpr/widgets/analysis_summary_card.dart';
import 'package:me_mpr/widgets/calls/call_summary_card.dart';
import 'package:me_mpr/widgets/emotion_bar_chart.dart';
import 'package:me_mpr/widgets/risk_and_advice_section.dart';
import 'package:me_mpr/utils/app_colors.dart';

class CallDetailPage extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;
  final CallAnalysisReport analysisReport;

  const CallDetailPage({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
    required this.analysisReport,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete this Call Analysis?'),
          content: const Text(
            'Are you sure you want to delete this entry? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // If user confirmed, delete the diary and pop the screen
      await CallStorageService().deleteCall(caller);
      if (context.mounted) {
        Navigator.of(
          context,
        ).pop(true); // Pop with a result to indicate deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Call Analysis'),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CallSummaryCard(caller: caller, date: date, duration: duration),
            const SizedBox(height: 24),

            // --- NEW: AI Summary Section ---
            if (analysisReport.summary != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        analysisReport.summary!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Reusing the same widgets from the Diary Analysis
            AnalysisSummaryCard(
              score: analysisReport.depressionScore,
              description: analysisReport.description,
            ),
            const SizedBox(height: 16),
            if (analysisReport.emotions.isNotEmpty) ...[
              EmotionBarChart(emotions: analysisReport.emotions),
              const SizedBox(height: 16),
            ],
            RiskAndAdviceSection(
              title: 'Potential Risks',
              items: analysisReport.risks,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.error,
            ),
            const SizedBox(height: 16),
            RiskAndAdviceSection(
              title: 'Helpful Advice',
              items: analysisReport.advice,
              icon: Icons.lightbulb_outline_rounded,
              iconColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
