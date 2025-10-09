import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/depression_report.dart';
import 'package:me_mpr/failure/diary_entry.dart';
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

  bool _isLoading = false;
  DepressionReport? _analysisReport;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {}); // To update character count
    });
  }

  Future<void> _saveAndAnalyzeDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something in your diary to save.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Get analysis from the API
      final report = await _analysisService.analyzeText(
        _contentController.text,
      );

      // 2. Create a complete DiaryEntry object with the analysis summary
      final newEntry = DiaryEntry(
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : 'Untitled Diary',
        content: _contentController.text,
        dateTime: DateTime.now(),
        emoji: _getEmojiForScore(report.depressionScore),
        analysis: report.description, // Save the summary
      );

      // 3. Save the complete entry to local storage
      await _storageService.saveDiary(newEntry);

      // 4. Update the UI to show the analysis report
      setState(() {
        _analysisReport = report;
      });
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getEmojiForScore(int score) {
    if (score <= 3) return '😊'; // Low score
    if (score <= 6) return '😐'; // Medium score
    return '😔'; // High score
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _analysisReport == null ? 'Create Diary' : 'Diary Analysis',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
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
              onPressed: () {
                // Placeholder for voice recording
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice recording not implemented yet.'),
                  ),
                );
              },
              child: const Icon(Icons.mic, color: Colors.white),
            )
          : null,
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
        // --- Save Button ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndAnalyzeDiary,
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
            iconColor: AppColors.moodGood,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
