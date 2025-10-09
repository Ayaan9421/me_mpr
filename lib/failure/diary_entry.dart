import 'dart:convert';

// Helper function to decode a list of entries from a JSON string
List<DiaryEntry> diaryEntryFromJson(String str) =>
    List<DiaryEntry>.from(json.decode(str).map((x) => DiaryEntry.fromJson(x)));

// Helper function to encode a list of entries to a JSON string
String diaryEntryToJson(List<DiaryEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DiaryEntry {
  final String emoji;
  final String title;
  final String content;
  final DateTime dateTime;
  final String analysis; // The summary from the API

  DiaryEntry({
    required this.emoji,
    required this.title,
    required this.content,
    required this.dateTime,
    this.analysis = 'No analysis available.',
  });

  // Factory to create an entry from a JSON map
  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    emoji: json["emoji"],
    title: json["title"],
    content: json["content"],
    dateTime: DateTime.parse(json["dateTime"]),
    analysis: json["analysis"],
  );

  // Method to convert an entry to a JSON map
  Map<String, dynamic> toJson() => {
    "emoji": emoji,
    "title": title,
    "content": content,
    "dateTime": dateTime.toIso8601String(),
    "analysis": analysis,
  };
}
