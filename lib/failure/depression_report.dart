import 'dart:convert';

// Helper function to decode the JSON string if necessary
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

  factory DepressionReport.fromJson(Map<String, dynamic> json) =>
      DepressionReport(
        transcript: json["transcript"],
        depressionScore: json["depression_score"],
        description: json["description"],
        risks: List<String>.from(json["risks"].map((x) => x)),
        advice: List<String>.from(json["advice"].map((x) => x)),
        emotions: List<EmotionDetail>.from(
          json["emotions"].map((x) => EmotionDetail.fromJson(x)),
        ),
      );
}

class EmotionDetail {
  final String label;
  final double score;

  EmotionDetail({required this.label, required this.score});

  factory EmotionDetail.fromJson(Map<String, dynamic> json) =>
      EmotionDetail(label: json["label"], score: json["score"]?.toDouble());
}
