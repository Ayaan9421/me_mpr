import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/screens/diary_detail_page.dart';

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
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final recentDiaries = snapshot.data!.take(3).toList();

        return Column(
          children: [
            ...recentDiaries.map((entry) {
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailPage(entry: entry),
                    ),
                  );
                  onRefresh(); // Refresh when returning
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildDiaryEntryCard(entry),
                ),
              );
            }),
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

  Widget _buildDiaryEntryCard(DiaryEntry entry) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
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
        leading: Text(entry.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('MMM dd, h:mm a').format(entry.dateTime),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
