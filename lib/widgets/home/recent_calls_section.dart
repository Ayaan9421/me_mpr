import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:me_mpr/screens/Calls/call_analysis_page.dart';
import 'package:me_mpr/screens/Calls/call_detail_page.dart';
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

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '';
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds min';
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
    final bool isProcessing = analysis.isProcessing;
    final String displayEmoji = isProcessing
        ? '⏳'
        : _getEmojiForScore(
            analysis.report?.depressionScore ?? 5,
          ); // Default emoji if report is somehow null

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (analysis.report != null) {
          // Only navigate if report exists
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallDetailPage(
                caller: analysis.fileName,
                date: DateFormat('MMM dd, yyyy').format(analysis.callDate),
                duration: _formatDuration(analysis.durationInSeconds),
                analysisReport:
                    analysis.report!, // We know report is not null here
              ),
            ),
          );
        } else {
          // Handle case where it finished processing but failed (report is null)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Analysis failed for this call.')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isProcessing
              ? Colors.grey.shade100
              : Colors.white, // Lighter background if processing
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
            displayEmoji, // Use the determined emoji
            style: const TextStyle(fontSize: 30),
          ),
          title: Text(
            analysis.fileName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isProcessing
                  ? AppColors.secondaryText
                  : AppColors.primaryText, // Dim text if processing
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            // Show "Processing..." instead of date/duration if processing
            isProcessing
                ? 'Analysis in progress...'
                : '${DateFormat('MMM dd, h:mm a').format(analysis.callDate)}  •  ${_formatDuration(analysis.durationInSeconds)}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  // Show spinner if processing
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 26,
                ),
        ),
      ),
    );
  }
}
