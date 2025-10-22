import 'package:just_audio/just_audio.dart';
import 'package:me_mpr/failure/call_analysis_model.dart';
import 'package:me_mpr/failure/call_recording_model.dart';
import 'package:me_mpr/services/diary_analysis_service.dart';
import 'package:me_mpr/services/call_storage_service.dart';

/// A singleton service to manage the queue of calls to be analyzed.
class CallAnalysisQueueService {
  static final CallAnalysisQueueService _instance =
      CallAnalysisQueueService._internal();
  factory CallAnalysisQueueService() => _instance;

  CallAnalysisQueueService._internal();

  final _analysisService = DiaryAnalysisService();
  final _storageService = CallStorageService();

  bool _isProcessing = false;

  void addCallsToQueue(List<CallRecording> calls) {
    if (_isProcessing || calls.isEmpty) {
      return;
    }
    _isProcessing = true;
    _processQueue(List.from(calls)); // Process a copy
  }

  Future<void> _processQueue(List<CallRecording> queue) async {
    print('Starting background analysis of ${queue.length} calls...');
    final audioPlayer = AudioPlayer();
    for (final call in queue) {
      try {
        final duration = await audioPlayer.setFilePath(call.path);
        final durationInSeconds = duration?.inSeconds ?? 0;

        print('Analyzing call: ${call.name}...');
        final report = await _analysisService.analyzeCalls(call.path);

        final analysis = CallAnalysis(
          fileName: call.name,
          callDate: call.modified,
          report: report,
          durationInSeconds: durationInSeconds,
        );

        print(analysis.fileName);
        print(analysis.callDate);
        print(analysis.report.summary);
        print(analysis.durationInSeconds);

        await _storageService.saveAnalysis(analysis);
        print('Successfully analyzed and saved: ${call.name}');
      } catch (e) {
        print('Failed to analyze ${call.name}: $e');
        // Optionally, implement retry logic or log to an error state
      }
    }

    audioPlayer.dispose();
    print('Background analysis queue finished.');
    _isProcessing = false;
  }
}
