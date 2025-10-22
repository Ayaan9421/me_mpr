import 'package:me_mpr/failure/call_analysis_report.dart';

class CallAnalysis {
  final String fileName;
  final DateTime callDate;
  final CallAnalysisReport report;
  final int durationInSeconds;

  CallAnalysis({
    required this.fileName,
    required this.callDate,
    required this.report,
    required this.durationInSeconds,
  });

  factory CallAnalysis.fromJson(Map<String, dynamic> json) => CallAnalysis(
    fileName: json["fileName"],
    callDate: DateTime.parse(json["callDate"]),
    report: CallAnalysisReport.fromJson(json["report"]),
    durationInSeconds: json["durationInSeconds"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "fileName": fileName,
    "callDate": callDate.toIso8601String(),
    "report": report.toJson(),
    "durationInSeconds": durationInSeconds,
  };
}
