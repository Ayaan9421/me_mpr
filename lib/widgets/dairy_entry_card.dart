import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/utils/app_colors.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isReversed; // To control the alternating layout

  const DiaryEntryCard({
    super.key,
    required this.entry,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to truncate text
    String truncateText(String text, int maxLength) {
      return (text.length <= maxLength)
          ? text
          : '${text.substring(0, maxLength)}...';
    }

    // Main content widgets
    final emojiWidget = Text(entry.emoji, style: const TextStyle(fontSize: 42));
    final detailsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM dd, yyyy  •  h:mm a').format(entry.dateTime),
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top section with spacing fix ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: isReversed
                  ? [
                      Expanded(child: detailsWidget), // Text expands
                      const SizedBox(width: 20),
                      emojiWidget,
                    ]
                  : [
                      emojiWidget,
                      const SizedBox(width: 20),
                      Expanded(child: detailsWidget), // Text expands
                    ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // --- Bottom analysis section ---
            Text(
              'Journal Analysis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              truncateText(entry.analysis, 120),
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
