import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/models/diary_entry.dart';
import 'package:me_mpr/screens/Daily%20Diary/daily_diaries_page.dart';
import 'package:me_mpr/screens/Daily%20Diary/diary_detail_page.dart';
import 'package:me_mpr/utils/app_colors.dart'; // Import AppColors

class RecentDiariesSection extends StatelessWidget {
  final Future<List<DiaryEntry>> diariesFuture;
  final VoidCallback onRefresh;

  const RecentDiariesSection({
    super.key,
    required this.diariesFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: diariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load diaries.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text(
              'No recent diaries. Tap "+" to create one!',
              style: TextStyle(color: AppColors.secondaryText), // Use AppColors
            ),
          );
        }

        final recentDiaries = snapshot.data!;
        // Ensure sorting happens correctly here if needed (e.g., newest first)
        recentDiaries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return Column(
          children: [
            // Take up to 3 most recent entries
            ...recentDiaries.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildDiaryEntryCard(context, entry), // Pass context
              );
            }).toList(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyDairiesPage(),
                    ),
                  );
                  onRefresh(); // Refresh when returning
                },
                child: const Text('View more →'),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- UPDATED Card Builder ---
  Widget _buildDiaryEntryCard(BuildContext context, DiaryEntry entry) {
    // Determine if analysis is still processing (report will be null)
    final bool isProcessing = entry.report == null;
    final String displayEmoji = isProcessing ? '⏳' : entry.emoji;

    return InkWell(
      // Disable tap if processing
      onTap: isProcessing
          ? null
          : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryDetailPage(entry: entry),
                ),
              );
              onRefresh(); // Refresh when returning
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Consistent padding
        decoration: BoxDecoration(
          // Lighter background if processing
          color: isProcessing ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Softer shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // Use Row for better alignment control
          children: [
            Text(displayEmoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Make title bold
                      fontSize: 16,
                      // Dim text color if processing
                      color: isProcessing
                          ? AppColors.secondaryText
                          : AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Show "Processing..." if processing
                    isProcessing
                        ? 'Analysis in progress...'
                        : DateFormat(
                            'MMM dd, yyyy  •  h:mm a',
                          ).format(entry.dateTime),
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Show spinner or chevron
            isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondaryText,
                  ),
          ],
        ),
      ),
    );
  }
}
