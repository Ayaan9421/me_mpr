import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/models/diary_entry.dart';
import 'package:me_mpr/utils/app_colors.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isReversed; // To control the alternating layout
  final VoidCallback? onTap;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    this.isReversed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to truncate text safely, handling nulls
    String truncateText(String? text, int maxLength) {
      if (text == null || text.isEmpty) {
        return 'No analysis available.';
      }
      return (text.length <= maxLength)
          ? text
          : '${text.substring(0, maxLength)}...';
    }

    // --- Main content widgets ---
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
              // --- Analysis Section (only shows if report exists) ---
              if (entry.report != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
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
                  // --- FIX APPLIED HERE ---
                  // Accessing the 'description' from the 'report' object
                  truncateText(entry.report?.description, 120),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
