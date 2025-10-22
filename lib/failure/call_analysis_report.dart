import 'dart:convert';

import 'package:me_mpr/failure/emotion_detail.dart';

CallAnalysisReport depressionReportFromJson(String str) {
  final jsonData = json.decode(str);
  return CallAnalysisReport.fromJson(jsonData);
}

class CallAnalysisReport {
  final String? summary;
  final int depressionScore;
  final String description;
  final List<String> risks;
  final List<String> advice;
  final List<EmotionDetail> emotions;

  CallAnalysisReport({
    this.summary,
    required this.depressionScore,
    required this.description,
    required this.risks,
    required this.advice,
    required this.emotions,
  });

  factory CallAnalysisReport.fromJson(Map<String, dynamic> json) {
    return CallAnalysisReport(
      summary: json["summary"],
      depressionScore: json["depression_score"],
      description: json["description"],
      risks: (json["risks"] as List?)?.map((x) => x.toString()).toList() ?? [],
      advice:
          (json["advice"] as List?)?.map((x) => x.toString()).toList() ?? [],
      emotions:
          (json["emotions"] as List?)
              ?.map((x) => EmotionDetail.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "summary": summary,
    "depression_score": depressionScore,
    "description": description,
    "risks": risks,
    "advice": advice,
    "emotions": emotions.map((x) => x.toJson()).toList(),
  };
}
