import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/models/depression_report.dart';
import 'package:me_mpr/models/diary_entry.dart';
import 'package:me_mpr/screens/Calls/voice_recorder_view.dart';
import 'package:me_mpr/services/Daily%20Diary/audio_recorder_service.dart';
import 'package:me_mpr/services/Daily%20Diary/diary_analysis_service.dart';
import 'package:me_mpr/services/Daily%20Diary/diary_storage_service.dart';
import 'package:me_mpr/services/notification_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/utils/utils.dart';

class CreateDiaryPage extends StatefulWidget {
  const CreateDiaryPage({super.key});

  @override
  State<CreateDiaryPage> createState() => _CreateDiaryPageState();
}

class _CreateDiaryPageState extends State<CreateDiaryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _analysisService = DiaryAnalysisService();
  final _storageService = DiaryStorageService();
  final _recorderService = AudioRecorderService(); // Instance of the recorder
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _recorderService.init(); // Initialize the recorder service
    _contentController.addListener(() {
      setState(() {}); // To update character count
    });
  }

  // --- Renamed and simplified: Only saves initial entry ---
  Future<DiaryEntry?> _saveInitialDiaryEntry({String? contentOverride}) async {
    final content = contentOverride ?? _contentController.text.trim();
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: 'Please write or record something first.');
      return null;
    }

    final newEntry = DiaryEntry(
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : (contentOverride != null
                ? 'Voice Journal - ${DateFormat.yMMMd().format(DateTime.now())}'
                : 'Untitled Diary'),
      content: content,
      dateTime: DateTime.now(), // Use this as the unique ID
      emoji: '⏳', // Placeholder emoji
      // Report is initially null
    );

    await _storageService.saveDiary(newEntry);
    return newEntry;
  }

  // --- NEW: Triggers the background analysis ---
  void _triggerBackgroundAnalysis(DiaryEntry entry, {String? audioPath}) async {
    final notificationId =
        entry.dateTime.millisecondsSinceEpoch %
        2147483647; // Unique ID from timestamp
    final title = entry.title;

    try {
      await _notificationService.showProgressNotification(
        id: notificationId,
        title: title,
        body: 'Analyzing entry...',
        progress: 15, // Start at 15%
        maxProgress: 100,
      );

      // Simulate some delay like Instagram
      await Future.delayed(const Duration(seconds: 2));

      // Perform the actual analysis
      final DepressionReport report;
      if (audioPath != null) {
        report = await _analysisService.analyzeAudio(audioPath);
      } else {
        report = await _analysisService.analyzeText(entry.content);
      }

      // Update progress to 90%
      await _notificationService.showProgressNotification(
        id: notificationId,
        title: title,
        body: 'Finishing analysis...',
        progress: 90,
        maxProgress: 100,
      );
      await Future.delayed(const Duration(seconds: 1)); // Simulate final step

      // Create the updated entry with the report
      final updatedEntry = DiaryEntry(
        title: entry.title,
        content: audioPath != null
            ? (report.transcript ?? entry.content)
            : entry.content, // Update content if it was voice
        dateTime: entry.dateTime, // Keep the original dateTime as ID
        emoji: getEmojiForDepressionScore(report.depressionScore),
        report: report, // Add the report
      );

      // Save the updated entry (overwrites the initial one)
      await _storageService.saveDiary(updatedEntry);

      // Show completion notification
      await _notificationService.showCompletionNotification(
        id: notificationId,
        title: title,
        body: 'Analysis complete!',
      );
    } catch (e) {
      print("Background analysis failed: $e");
      await _notificationService.showErrorNotification(
        id: notificationId,
        title: title,
        body: 'Analysis failed.', // Simpler message
      );
      // Optionally save entry with error state/emoji
      final errorEntry = DiaryEntry(
        title: entry.title,
        content: entry.content,
        dateTime: entry.dateTime,
        emoji: '⚠️', // Error emoji
        report: null, // Or a report indicating error
      );
      await _storageService.saveDiary(
        errorEntry,
      ); // Optionally: update the saved entry with an error status
    }
  }

  Future<void> _handleSaveTextDiary() async {
    final initialEntry = await _saveInitialDiaryEntry();
    if (initialEntry != null) {
      Fluttertoast.showToast(msg: "Saving and starting analysis...");
      // Pop screen immediately, passing true to signal refresh
      if (mounted) Navigator.of(context).pop(true);
      // Trigger background task *after* popping
      _triggerBackgroundAnalysis(initialEntry);
    }
  }

  Future<void> _handleVoiceRecording() async {
    final filePath = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoiceRecorderView(recorderService: _recorderService),
    );

    if (filePath != null) {
      // Get transcript temporarily to save initial entry
      String initialContent = "Processing voice recording...";
      try {
        // We do a quick analysis just to get the transcript for saving
        // Note: This does mean the ASR runs twice if successful later.
        // A more advanced solution might save the audio path and analyze fully later.
        final tempReport = await _analysisService.analyzeAudio(filePath);
        initialContent = tempReport.transcript ?? 'No transcription available.';
      } catch (e) {
        print("Failed initial transcript fetch: $e");
        // Proceed without transcript if initial fetch fails
      }

      final initialEntry = await _saveInitialDiaryEntry(
        contentOverride: initialContent,
      );
      if (initialEntry != null) {
        Fluttertoast.showToast(msg: "Saving and starting analysis...");
        if (mounted) Navigator.of(context).pop(true);
        // Trigger full background analysis with the audio path
        _triggerBackgroundAnalysis(initialEntry, audioPath: filePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No PopScope needed as we pop manually after triggering background task
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Diary'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          // Pop without a result if analysis wasn't started
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      // Body no longer switches view, always shows editor
      body: _buildEditorView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleVoiceRecording,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  Widget _buildEditorView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat.yMMMMd().format(DateTime.now())}  |  ${_contentController.text.length} characters',
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
                const Divider(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Your Diary Title...',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'How are you feeling today?',
                  ),
                  maxLines: null, // Allows infinite lines
                  keyboardType: TextInputType.multiline, // Improves keyboard
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        // Save Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSaveTextDiary, // Use the new handler
              child: const Text('Save & Analyze'),
            ),
          ),
        ),
      ],
    );
  }

  // _buildAnalysisView is no longer needed on this page

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recorderService.dispose();
    super.dispose();
  }
}
