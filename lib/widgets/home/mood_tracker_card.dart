import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/utils/utils.dart'; // Import utils

class MoodTrackerCard extends StatelessWidget {
  final double? averageMoodScore; // Nullable if no data
  final int streakCount;
  final Set<int> daysWithEntries; // Weekdays (0=Mon, 6=Sun)

  const MoodTrackerCard({
    super.key,
    required this.averageMoodScore,
    required this.streakCount,
    required this.daysWithEntries,
  });

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Use helper functions ---
    final displayEmoji = getEmojiForDepressionScore(
      averageMoodScore?.round() ?? 5,
    ); // Default to mid-range if null
    final displayLabel = getWeeklyMoodLabel(averageMoodScore);
    // ---

    final weekDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayWeekday = DateTime.now().weekday - 1; // 0=Mon, 6=Sun

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9CECFB), Color(0xFF65C7F7), Color(0xFF0052D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  displayEmoji,
                  style: const TextStyle(fontSize: 42),
                ), // Use dynamic emoji
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You’re on a $streakCount-day streak! Keep going 💪',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                int dayIndex = (todayWeekday - (6 - index) + 7) % 7;
                bool hasEntry = daysWithEntries.contains(dayIndex);
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: hasEntry
                      ? AppColors.success.withOpacity(0.9)
                      : Colors.white.withOpacity(0.25),
                  child: Text(
                    weekDayLabels[dayIndex],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: hasEntry
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
