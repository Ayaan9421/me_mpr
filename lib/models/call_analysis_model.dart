import 'package:me_mpr/models/call_analysis_report.dart';

class CallAnalysis {
  final String fileName;
  final DateTime callDate;
  // Report is now nullable for the processing state
  final CallAnalysisReport? report;
  final int durationInSeconds;
  // --- NEW: Flag to indicate processing status ---
  final bool isProcessing;

  CallAnalysis({
    required this.fileName,
    required this.callDate,
    this.report, // Nullable
    required this.durationInSeconds,
    this.isProcessing = false, // Default to false
  });

  factory CallAnalysis.fromJson(Map<String, dynamic> json) => CallAnalysis(
    fileName: json["fileName"],
    callDate: DateTime.parse(json["callDate"]),
    // Handle null report during processing
    report: json["report"] == null
        ? null
        : CallAnalysisReport.fromJson(json["report"]),
    durationInSeconds: json["durationInSeconds"] ?? 0,
    // Read the processing flag, default to false if missing
    isProcessing: json["isProcessing"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "fileName": fileName,
    "callDate": callDate.toIso8601String(),
    // Handle null report
    "report": report?.toJson(),
    "durationInSeconds": durationInSeconds,
    "isProcessing": isProcessing,
  };
}
