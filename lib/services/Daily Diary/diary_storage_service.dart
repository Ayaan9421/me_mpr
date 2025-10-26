import 'dart:convert';
import 'package:me_mpr/models/diary_entry.dart';
import 'package:me_mpr/services/Calls/call_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryStorageService {
  static const _storageKey = 'diary_entries';

  final CallStorageService _callStorageService = CallStorageService();
  Future<List<DiaryEntry>> getDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diariesString = prefs.getString(_storageKey);
    if (diariesString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(diariesString);
      List<DiaryEntry> entries = jsonList
          .map((json) => DiaryEntry.fromJson(json as Map<String, dynamic>))
          .toList();
      // Sort by date, newest first
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return entries;
    } catch (e) {
      print("Error decoding diaries: $e");
      await prefs.remove(_storageKey); // Clear corrupted data
      return [];
    }
  }

  Future<void> saveDiary(DiaryEntry newEntry) async {
    final diaries = await getDiaries();
    // --- FIX: Update logic ---
    // Remove existing entry with the same timestamp before adding the new/updated one
    diaries.removeWhere((entry) => entry.dateTime == newEntry.dateTime);
    diaries.add(newEntry);
    await _persistDiaries(diaries);
  }

  Future<void> deleteDiary(DateTime dateTime) async {
    final diaries = await getDiaries();
    diaries.removeWhere((entry) => entry.dateTime == dateTime);
    await _persistDiaries(diaries);
  }

  Future<void> _persistDiaries(List<DiaryEntry> diaries) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = diaries
        .map((e) => e.toJson())
        .toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // --- NEW METHODS for Mood Tracking ---

  /// Gets diaries logged within the last N days.
  Future<List<DiaryEntry>> getDiariesFromLastDays(int days) async {
    final allDiaries = await getDiaries();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allDiaries
        .where((entry) => entry.dateTime.isAfter(cutoffDate))
        .toList();
  }

  /// Calculates the average depression score from diaries in the last 7 days.
  /// Returns null if no analyzed diaries are found in that period.
  // --- UPDATED METHOD to include Call Analysis ---
  Future<double?> getAverageWeeklyMoodScore() async {
    // 1. Get recent diaries AND recent call analyses
    final weeklyDiaries = await getDiariesFromLastDays(7);
    final weeklyCalls = await _callStorageService.getAnalysesFromLastDays(7);

    // 2. Filter both lists for entries that HAVE a report
    final analyzedDiaries = weeklyDiaries
        .where((d) => d.report != null)
        .toList();
    // Calls store the report directly, filter out processing/failed ones
    final analyzedCalls = weeklyCalls
        .where((c) => c.report != null && !c.isProcessing)
        .toList();

    // 3. Combine the scores
    List<int> allScores = [];
    allScores.addAll(analyzedDiaries.map((d) => d.report!.depressionScore));
    allScores.addAll(analyzedCalls.map((c) => c.report!.depressionScore));

    // 4. Calculate average if any scores exist
    if (allScores.isEmpty) {
      return null; // No analyzed data in the last week
    }

    double totalScore = allScores.fold(0, (sum, score) => sum + score);
    return totalScore / allScores.length;
  }

  /// Calculates the current journaling streak (consecutive days with entries).
  Future<int> getCurrentJournalingStreak() async {
    final allDiaries =
        await getDiaries(); // Assumes diaries are sorted newest first
    if (allDiaries.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(
      today.year,
      today.month,
      today.day,
    ); // Normalize to start of day
    DateTime? lastEntryDate;

    Set<DateTime> entryDates = allDiaries
        .map((e) => DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day))
        .toSet(); // Get unique dates

    // Check if there's an entry for today
    bool hasEntryToday = entryDates.contains(currentDate);
    if (hasEntryToday) {
      streak = 1;
      lastEntryDate = currentDate;
    } else {
      // Check if there's an entry for yesterday
      DateTime yesterday = currentDate.subtract(const Duration(days: 1));
      bool hasEntryYesterday = entryDates.contains(yesterday);
      if (!hasEntryYesterday)
        return 0; // Streak broken if no entry today or yesterday
      streak = 1; // Start streak from yesterday
      lastEntryDate = yesterday;
    }

    // Iterate backwards from the last entry date found
    while (true) {
      DateTime previousDay = lastEntryDate!.subtract(const Duration(days: 1));
      if (entryDates.contains(previousDay)) {
        streak++;
        lastEntryDate = previousDay;
      } else {
        break; // Streak broken
      }
    }

    return streak;
  }

  /// Returns a set of weekdays (0=Mon, 6=Sun) for the last 7 days where entries exist.
  Future<Set<int>> getWeekdaysWithEntries() async {
    final weeklyDiaries = await getDiariesFromLastDays(7);
    Set<int> days = {};
    DateTime today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime checkDate = today.subtract(Duration(days: i));
      // Normalize checkDate to start of day for comparison
      DateTime normalizedCheckDate = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      // Check if any diary entry exists for this normalized date
      bool entryExists = weeklyDiaries.any((diary) {
        DateTime diaryDate = DateTime(
          diary.dateTime.year,
          diary.dateTime.month,
          diary.dateTime.day,
        );
        return diaryDate == normalizedCheckDate;
      });

      if (entryExists) {
        // DateTime.weekday returns 1 for Monday, 7 for Sunday. Adjust to 0-6.
        days.add(checkDate.weekday - 1);
      }
    }
    return days;
  }
}
