import 'package:flutter/material.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/widgets/dairy_entry_card.dart';

class DailyDairiesPage extends StatelessWidget {
  DailyDairiesPage({super.key});

  // --- Mock Data for display ---
  final List<DiaryEntry> _diaryEntries = [
    DiaryEntry(
      emoji: '😄',
      title: 'A Fantastic Day!',
      dateTime: DateTime.parse('2025-10-09T14:30:00Z'),
      analysis:
          'Today was filled with positive moments. You mentioned feeling accomplished after finishing your project, which suggests a strong sense of pride and competence. Keep embracing these feelings of success.',
    ),
    DiaryEntry(
      emoji: '😐',
      title: 'A bit stressed',
      dateTime: DateTime.parse('2025-10-08T09:00:00Z'),
      analysis:
          'Work stress seems to be a recurring theme. You noted feeling overwhelmed by deadlines. It might be helpful to break down tasks into smaller, more manageable steps to reduce anxiety.',
    ),
    DiaryEntry(
      emoji: '😌',
      title: 'Feeling Calm',
      dateTime: DateTime.parse('2025-10-07T20:15:00Z'),
      analysis:
          'Your evening walk brought a sense of peace. Describing the sunset and cool breeze indicates a connection with nature, which is a great coping mechanism for stress. Consider making this a regular habit.',
    ),
    DiaryEntry(
      emoji: '😊',
      title: 'Lunch with a friend',
      dateTime: DateTime.parse('2025-10-06T13:00:00Z'),
      analysis:
          'Social interaction had a very positive impact. You described laughing and feeling connected. Spending time with loved ones is a powerful mood booster that strengthens your support system.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Diaries'),
        // The back button is automatically added by Flutter's Navigator
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: _diaryEntries.length,
        itemBuilder: (context, index) {
          final entry = _diaryEntries[index];
          // Use the index to alternate the layout
          return DiaryEntryCard(
            entry: entry,
            isReversed: index.isOdd, // index 1, 3, 5... will be reversed
          );
        },
      ),
    );
  }
}
