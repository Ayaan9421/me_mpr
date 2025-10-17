import 'package:me_mpr/failure/depression_report.dart';

class CallAnalysis {
  final String fileName;
  final DateTime callDate;
  final DepressionReport report;

  CallAnalysis({
    required this.fileName,
    required this.callDate,
    required this.report,
  });

  factory CallAnalysis.fromJson(Map<String, dynamic> json) => CallAnalysis(
    fileName: json["fileName"],
    callDate: DateTime.parse(json["callDate"]),
    report: DepressionReport.fromJson(json["report"]),
  );

  Map<String, dynamic> toJson() => {
    "fileName": fileName,
    "callDate": callDate.toIso8601String(),
    "report": report.toJson(),
  };
}
