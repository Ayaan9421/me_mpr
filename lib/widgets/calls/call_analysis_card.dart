import 'package:flutter/material.dart';
import 'package:me_mpr/models/call_analysis_report.dart';
import 'package:me_mpr/screens/Calls/call_detail_page.dart';
import 'package:me_mpr/utils/app_colors.dart';

class CallAnalysisCard extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;
  // --- FIX: Changed the type from Map to DepressionReport ---
  final CallAnalysisReport analysisReport;

  const CallAnalysisCard({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
    required this.analysisReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caller,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$date  •  $duration',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallDetailPage(
                        caller: caller,
                        date: date,
                        duration: duration,
                        // --- FIX: Passed the correct object with the correct name ---
                        analysisReport: analysisReport,
                      ),
                    ),
                  );
                },
                child: const Text('View Call Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
