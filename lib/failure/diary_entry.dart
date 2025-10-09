import 'dart:convert';
import 'package:me_mpr/failure/depression_report.dart';

List<DiaryEntry> diaryEntryFromJson(String str) =>
    List<DiaryEntry>.from(json.decode(str).map((x) => DiaryEntry.fromJson(x)));

String diaryEntryToJson(List<DiaryEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiaryEntry {
  final String emoji;
  final String title;
  final String content;
  final DateTime dateTime;
  final DepressionReport? report; // Store the full report object

  DiaryEntry({
    required this.emoji,
    required this.title,
    required this.content,
    required this.dateTime,
    this.report,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    emoji: json["emoji"],
    title: json["title"],
    content: json["content"],
    dateTime: DateTime.parse(json["dateTime"]),
    // Decode the nested report object if it exists
    report: json["report"] == null
        ? null
        : DepressionReport.fromJson(json["report"]),
  );

  Map<String, dynamic> toJson() => {
    "emoji": emoji,
    "title": title,
    "content": content,
    "dateTime": dateTime.toIso8601String(),
    // Encode the nested report object if it exists
    "report": report?.toJson(),
  };
}
