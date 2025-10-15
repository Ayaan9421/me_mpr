import 'package:flutter/material.dart';
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

  String _getEmojiForScore(int score) {
    if (score <= 3) return '😊';
    if (score <= 6) return '😐';
    return '😔';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(_diaryWasSaved);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _analysisReport == null ? 'Create Diary' : 'Diary Analysis',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(_diaryWasSaved),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing your entry...'),
                  ],
                ),
              )
            : _analysisReport != null
            ? _buildAnalysisView()
            : _buildEditorView(),
        floatingActionButton: _analysisReport == null
            ? FloatingActionButton(
                onPressed: _startVoiceRecording, // <-- Connect to new function
                child: const Icon(Icons.mic, color: Colors.white),
              )
            : null,
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
                  maxLines: null,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  _saveAndAnalyze(), // Call without parameters for text
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Save & Analyze'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisView() {
    final report = _analysisReport!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          AnalysisSummaryCard(
            score: report.depressionScore,
            description: report.description,
          ),
          const SizedBox(height: 16),
          if (report.emotions.isNotEmpty) ...[
            EmotionBarChart(emotions: report.emotions),
            const SizedBox(height: 16),
          ],
          RiskAndAdviceSection(
            title: 'Potential Risks',
            items: report.risks,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,
          ),
          const SizedBox(height: 16),
          RiskAndAdviceSection(
            title: 'Helpful Advice',
            items: report.advice,
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recorderService.dispose(); // Dispose the recorder
    super.dispose();
  }
}
