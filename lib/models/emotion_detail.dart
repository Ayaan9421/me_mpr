class EmotionDetail {
  final String label;
  final double score;

  EmotionDetail({required this.label, required this.score});

  factory EmotionDetail.fromJson(Map<String, dynamic> json) => EmotionDetail(
    label: json["label"] ?? "",
    score: (json["score"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {"label": label, "score": score};
}
