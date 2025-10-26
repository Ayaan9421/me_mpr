import 'package:just_audio/just_audio.dart';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:me_mpr/models/call_recording_model.dart';
import 'package:me_mpr/services/Daily%20Diary/diary_analysis_service.dart';
import 'package:me_mpr/services/Calls/call_storage_service.dart';
import 'package:me_mpr/services/notification_service.dart';

/// A singleton service to manage the queue of calls to be analyzed.
class CallAnalysisQueueService {
  static final CallAnalysisQueueService _instance =
      CallAnalysisQueueService._internal();
  factory CallAnalysisQueueService() => _instance;

  CallAnalysisQueueService._internal();

  final _analysisService = DiaryAnalysisService();
  final _storageService = CallStorageService();
  final _notificationService =
      NotificationService(); // Get notification service instance

  bool _isProcessing = false;

  Future<void> addCallsToQueue(List<CallRecording> calls) async {
    // Make async
    if (_isProcessing || calls.isEmpty) {
      return;
    }

    // --- Save placeholders immediately ---
    for (final call in calls) {
      final placeholderAnalysis = CallAnalysis(
        fileName: call.name,
        callDate: call.modified,
        durationInSeconds: 0, // Duration unknown yet
        isProcessing: true, // Mark as processing
        report: null, // No report yet
      );
      await _storageService.saveAnalysis(placeholderAnalysis);
    }

    _isProcessing = true;
    _processQueue(List.from(calls)); // Start background processing
  }

  Future<void> _processQueue(List<CallRecording> queue) async {
    print('Starting background analysis of ${queue.length} calls...');
    final audioPlayer = AudioPlayer();
    for (final call in queue) {
      final notificationId = call.modified.millisecondsSinceEpoch % 2147483647;
      final title = 'Analyzing: ${call.name}'; // Use filename in title

      try {
        await _notificationService.showProgressNotification(
          id: notificationId,
          title: title,
          body: 'Starting analysis...',
          progress: 15,
          maxProgress: 100,
        );
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay

        // --- Actual Analysis ---
        final duration = await audioPlayer.setFilePath(call.path);
        final durationInSeconds = duration?.inSeconds ?? 0;

        print('Analyzing call: ${call.name}...');
        final report = await _analysisService.analyzeCalls(call.path);

        await _notificationService.showProgressNotification(
          id: notificationId,
          title: title,
          body: 'Finishing analysis...',
          progress: 90,
          maxProgress: 100,
        );
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay

        // --- Create FINAL analysis object ---
        final analysis = CallAnalysis(
          fileName: call.name,
          callDate: call.modified,
          report: report,
          durationInSeconds: durationInSeconds,
          isProcessing: false, // Mark as complete
        );
        await _storageService.saveAnalysis(analysis); // Overwrite placeholder
        print('Successfully analyzed and saved: ${call.name}');

        // Show completion notification
        await _notificationService.showCompletionNotification(
          id: notificationId,
          title: call.name, // Just filename for completion
          body: 'Analysis complete!',
        );
        // --- Notification Logic End ---
      } catch (e) {
        print('Failed to analyze ${call.name}: $e');
        // --- Save error state (optional but good) ---
        final errorAnalysis = CallAnalysis(
          fileName: call.name,
          callDate: call.modified,
          durationInSeconds: 0, // Duration might be unknown if it failed early
          isProcessing: false, // Mark as complete (even though failed)
          report: null, // Indicate error, or add a specific error field
        );
        await _storageService.deleteCall(
          errorAnalysis.fileName,
        ); // Overwrite placeholder

        await _notificationService.showErrorNotification(
          id: notificationId,
          title: call.name,
          body: 'Analysis failed.', // Simpler body
        );
        // Optionally, implement retry logic or log to an error state
      }
    }

    audioPlayer.dispose();
    print('Background analysis queue finished.');
    _isProcessing = false;
  }
}
