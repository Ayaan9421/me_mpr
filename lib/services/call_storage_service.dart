import 'dart:convert';
import 'package:me_mpr/failure/call_analysis_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallStorageService {
  static const _storageKey = 'call_analysis_storage';

  Future<void> saveAnalysis(CallAnalysis analysis) async {
    final analyses = await getAllAnalyses();
    // Avoid duplicates
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
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CallAnalysis.fromJson(json)).toList();
  }

  Future<void> _persist(List<CallAnalysis> analyses) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = analyses
        .map((a) => a.toJson())
        .toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<void> deleteCall(String fileNameToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final analyses = await getAllAnalyses();

    analyses.removeWhere((analysis) => analysis.fileName == fileNameToDelete);

    await prefs.setString(
      _storageKey,
      json.encode(analyses.map((a) => a.toJson()).toList()),
    );
  }
}
