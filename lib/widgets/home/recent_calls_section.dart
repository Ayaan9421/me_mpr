import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/call_analysis_model.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/call_detail_page.dart';
import 'package:me_mpr/utils/app_colors.dart';

class RecentCallsSection extends StatelessWidget {
  final Future<List<CallAnalysis>> analysesFuture;
  final VoidCallback onRefresh;

  const RecentCallsSection({
    super.key,
    required this.analysesFuture,
    required this.onRefresh,
  });

  String _getEmojiForScore(int score) {
    if (score <= 3) return '😊';
    if (score <= 6) return '😐';
    return '😔';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CallAnalysis>>(
      future: analysesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load calls.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text(
              'No call analyses yet. New calls will be found automatically.',
              style: TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          );
        }

        final recentAnalyses = snapshot.data!;
        recentAnalyses.sort((a, b) => b.callDate.compareTo(a.callDate));

        return Column(
          children: [
            ...recentAnalyses.take(3).map((analysis) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCallEntry(context, analysis),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CallAnalysisPage(),
                    ),
                  );
                  onRefresh();
                },
                child: const Text('View All →'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallEntry(BuildContext context, CallAnalysis analysis) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallDetailPage(
              caller: analysis.fileName,
              date: DateFormat('MMM dd, yyyy').format(analysis.callDate),
              duration: '${analysis.durationInSeconds.toString()} seconds',
              analysisReport: analysis.report,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Text(
            _getEmojiForScore(analysis.report.depressionScore),
            style: const TextStyle(fontSize: 30),
          ),
          title: Text(
            analysis.fileName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('MMM dd, h:mm a').format(analysis.callDate),
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 26,
          ),
        ),
      ),
    );
  }
}
