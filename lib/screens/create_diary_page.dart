import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/depression_report.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/voice_recorder_view.dart';
import 'package:me_mpr/services/audio_recorder_service.dart';
import 'package:me_mpr/services/diary_analysis_service.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/analysis_summary_card.dart';
import 'package:me_mpr/widgets/emotion_bar_chart.dart';
import 'package:me_mpr/widgets/risk_and_advice_section.dart';
import 'package:me_mpr/services/notification_service.dart';

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

  bool _isLoading = false;
  DepressionReport? _analysisReport;
  bool _diaryWasSaved = false;

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
        emoji: _getEmojiForScore(report.depressionScore),
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
        body: 'Analysis failed: ${e.toString()}',
      );
      // Optionally: update the saved entry with an error status
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

  // change
  // --- NEW: Handle audio recording and analysis ---
  Future<void> _startVoiceRecording() async {
    final filePath = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoiceRecorderView(recorderService: _recorderService),
    );

    if (filePath != null) {
      setState(() => _isLoading = true);
      try {
        final report = await _analysisService.analyzeAudio(filePath);

        // Use the transcript from the report as the diary content
        _contentController.text =
            report.transcript ?? 'No transcription available.';
        _titleController.text =
            'Voice Journal - ${DateFormat.yMMMd().format(DateTime.now())}';

        // Save and show analysis
        await _saveAndAnalyze(isVoice: true, audioReport: report);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Analysis failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // --- Updated to handle both text and voice ---
  Future<void> _saveAndAnalyze({
    bool isVoice = false,
    DepressionReport? audioReport,
  }) async {
    if (!isVoice && _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something in your diary to save.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the pre-analyzed audio report or get a new one for text
      final report =
          audioReport ??
          await _analysisService.analyzeText(_contentController.text);

      final newEntry = DiaryEntry(
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : 'Untitled Diary',
        content: _contentController.text,
        dateTime: DateTime.now(),
        emoji: _getEmojiForScore(report.depressionScore),
        report: report,
      );

      await _storageService.saveDiary(newEntry);

      setState(() {
        _analysisReport = report;
        _diaryWasSaved = true;
      });
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // change ends

  String _getEmojiForScore(int score) {
    if (score <= 3) return '😊';
    if (score <= 6) return '😐';
    return '😔';
  }

  // @override
  // Widget build(BuildContext context) {
  //   return PopScope(
  //     canPop: !_isLoading,
  //     onPopInvoked: (didPop) {
  //       if (didPop) return;
  //       Navigator.of(context).pop(_diaryWasSaved);
  //     },
  //     child: Scaffold(
  //       appBar: AppBar(
  //         title: Text(
  //           _analysisReport == null ? 'Create Diary' : 'Diary Analysis',
  //         ),
  //         leading: IconButton(
  //           icon: const Icon(Icons.close),
  //           onPressed: () => Navigator.of(context).pop(_diaryWasSaved),
  //         ),
  //       ),
  //       body: _isLoading
  //           ? const Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   CircularProgressIndicator(),
  //                   SizedBox(height: 16),
  //                   Text('Analyzing your entry...'),
  //                 ],
  //               ),
  //             )
  //           : _analysisReport != null
  //           ? _buildAnalysisView()
  //           : _buildEditorView(),
  //       floatingActionButton: _analysisReport == null
  //           ? FloatingActionButton(
  //               onPressed: _startVoiceRecording, // <-- Connect to new function
  //               child: const Icon(Icons.mic, color: Colors.white),
  //             )
  //           : null,
  //     ),
  //   );
  // }

  // Widget _buildEditorView() {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 '${DateFormat.yMMMMd().format(DateTime.now())}  |  ${_contentController.text.length} characters',
  //                 style: const TextStyle(color: AppColors.secondaryText),
  //               ),
  //               const Divider(height: 24),
  //               TextField(
  //                 controller: _titleController,
  //                 decoration: const InputDecoration.collapsed(
  //                   hintText: 'Your Diary Title...',
  //                   hintStyle: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.secondaryText,
  //                   ),
  //                 ),
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               TextField(
  //                 controller: _contentController,
  //                 decoration: const InputDecoration.collapsed(
  //                   hintText: 'How are you feeling today?',
  //                 ),
  //                 maxLines: null,
  //                 style: const TextStyle(fontSize: 16, height: 1.5),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: () =>
  //                 _saveAndAnalyze(), // Call without parameters for text
  //             style: ElevatedButton.styleFrom(
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               textStyle: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             child: const Text('Save & Analyze'),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildAnalysisView() {
  //   final report = _analysisReport!;
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     physics: const BouncingScrollPhysics(),
  //     child: Column(
  //       children: [
  //         AnalysisSummaryCard(
  //           score: report.depressionScore,
  //           description: report.description,
  //         ),
  //         const SizedBox(height: 16),
  //         if (report.emotions.isNotEmpty) ...[
  //           EmotionBarChart(emotions: report.emotions),
  //           const SizedBox(height: 16),
  //         ],
  //         RiskAndAdviceSection(
  //           title: 'Potential Risks',
  //           items: report.risks,
  //           icon: Icons.warning_amber_rounded,
  //           iconColor: AppColors.error,
  //         ),
  //         const SizedBox(height: 16),
  //         RiskAndAdviceSection(
  //           title: 'Helpful Advice',
  //           items: report.advice,
  //           icon: Icons.lightbulb_outline_rounded,
  //           iconColor: AppColors.success,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // @override
  // void dispose() {
  //   _titleController.dispose();
  //   _contentController.dispose();
  //   _recorderService.dispose(); // Dispose the recorder
  //   super.dispose();
  // }

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
