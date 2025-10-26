import 'dart:convert';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallStorageService {
  static const _storageKey = 'call_analysis_storage';

  Future<void> saveAnalysis(CallAnalysis analysis) async {
    final analyses = await getAllAnalyses();
    // This correctly removes the old entry (placeholder or completed)
    // before adding the new one.
    analyses.removeWhere((a) => a.fileName == analysis.fileName);
    analyses.add(analysis);
    await _persist(analyses);
  }

  Future<List<CallAnalysis>> getAllAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CallAnalysis.fromJson(json)).toList();
    } catch (e) {
      print("Error decoding call analyses: $e");
      await prefs.remove(_storageKey);
      return [];
    }
  }

  Future<void> deleteCall(String fileNameToDelete) async {
    final analyses = await getAllAnalyses();
    analyses.removeWhere((analysis) => analysis.fileName == fileNameToDelete);
    await _persist(analyses);
    print("Deleted call analysis for: $fileNameToDelete");
  }

  Future<void> _persist(List<CallAnalysis> analyses) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = analyses
        .map((a) => a.toJson())
        .toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<List<CallAnalysis>> getAnalysesFromLastDays(int days) async {
    final allAnalyses = await getAllAnalyses();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allAnalyses
        .where((analysis) => analysis.callDate.isAfter(cutoffDate))
        .toList();
  }
}
