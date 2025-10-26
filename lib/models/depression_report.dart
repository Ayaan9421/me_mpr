import 'dart:convert';

import 'package:me_mpr/models/emotion_detail.dart';

DepressionReport depressionReportFromJson(String str) {
  final jsonData = json.decode(str);
  return DepressionReport.fromJson(jsonData);
}

class DepressionReport {
  final String? transcript;
  final int depressionScore;
  final String description;
  final List<String> risks;
  final List<String> advice;
  final List<EmotionDetail> emotions;

  DepressionReport({
    this.transcript,
    required this.depressionScore,
    required this.description,
    required this.risks,
    required this.advice,
    required this.emotions,
  });

  factory DepressionReport.fromJson(Map<String, dynamic> json) {
    return DepressionReport(
      transcript: json["transcript"],
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
    "transcript": transcript,
    "depression_score": depressionScore,
    "description": description,
    "risks": risks,
    "advice": advice,
    "emotions": emotions.map((x) => x.toJson()).toList(),
  };
}
