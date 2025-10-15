import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/analysis_summary_card.dart';
import 'package:me_mpr/widgets/emotion_bar_chart.dart';
import 'package:me_mpr/widgets/risk_and_advice_section.dart';

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryDetailPage({super.key, required this.entry});

  // --- METHOD TO HANDLE DELETION ---
  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Diary'),
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
      await DiaryStorageService().deleteDiary(entry.dateTime);
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
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Diary Content Section ---
            Text(
              '${DateFormat.yMMMMd().format(entry.dateTime)} at ${DateFormat.jm().format(entry.dateTime)}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const Divider(height: 24),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // --- Analysis Section (if it exists) ---
            if (entry.report != null) ...[
              const Text(
                'AI Analysis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AnalysisSummaryCard(
                score: entry.report!.depressionScore,
                description: entry.report!.description,
              ),
              const SizedBox(height: 16),
              if (entry.report!.emotions.isNotEmpty) ...[
                EmotionBarChart(emotions: entry.report!.emotions),
                const SizedBox(height: 16),
              ],
              RiskAndAdviceSection(
                title: 'Potential Risks',
                items: entry.report!.risks,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.error,
              ),
              const SizedBox(height: 16),
              RiskAndAdviceSection(
                title: 'Helpful Advice',
                items: entry.report!.advice,
                icon: Icons.lightbulb_outline_rounded,
                iconColor: AppColors.success,
              ),
            ] else ...[
              const Center(
                child: Text('No analysis available for this entry.'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
