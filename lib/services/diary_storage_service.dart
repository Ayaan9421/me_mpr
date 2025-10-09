import 'package:me_mpr/failure/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryStorageService {
  static const _diariesKey = 'saved_diaries';

  // Saves a new diary entry by adding it to the existing list
  Future<void> saveDiary(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<DiaryEntry> diaries = await getDiaries();

    // Add the new entry and sort by date (newest first)
    diaries.add(entry);
    diaries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final String encodedData = diaryEntryToJson(diaries);
    await prefs.setString(_diariesKey, encodedData);
  }

  // Retrieves and decodes the list of all saved diary entries
  Future<List<DiaryEntry>> getDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? diariesString = prefs.getString(_diariesKey);
    if (diariesString != null && diariesString.isNotEmpty) {
      return diaryEntryFromJson(diariesString);
    }
    return [];
  }
}
