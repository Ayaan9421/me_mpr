import 'dart:convert';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryStorageService {
  static const _storageKey = 'diary_entries';

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
}
