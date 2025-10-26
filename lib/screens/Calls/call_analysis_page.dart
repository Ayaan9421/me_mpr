import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:me_mpr/models/call_recording_model.dart';
import 'package:me_mpr/screens/Calls/call_detail_page.dart';
import 'package:me_mpr/screens/ChatBot/chat_screen.dart';
import 'package:me_mpr/screens/Therapies/therapy_and_support.dart';
import 'package:me_mpr/services/Calls/call_analysis_queue_service.dart';
import 'package:me_mpr/services/Calls/call_finder_service.dart';
import 'package:me_mpr/services/Calls/call_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart'; // Import AppColors
import 'package:me_mpr/widgets/Calls/unanalyzed_calls_sheet.dart';
import 'package:me_mpr/widgets/main_bottom_nav_bar.dart';
import '../Home/home_page.dart';
import '../Daily Diary/daily_diaries_page.dart';
import '../Daily Diary/create_diary_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CallAnalysisPage extends StatefulWidget {
  const CallAnalysisPage({super.key});

  @override
  State<CallAnalysisPage> createState() => _CallAnalysisPageState();
}

class _CallAnalysisPageState extends State<CallAnalysisPage> {
  int _selectedIndex = 2;
  final CallStorageService _storageService = CallStorageService();
  final CallFinderService _callFinderService = CallFinderService();
  final CallAnalysisQueueService _queueService = CallAnalysisQueueService();
  late Future<List<CallAnalysis>> _analysesFuture;

  @override
  void initState() {
    super.initState();
    _refreshAnalyses();
  }

  Future<void> _refreshAnalyses() async {
    setState(() {
      _analysesFuture = _storageService.getAllAnalyses();
    });
    await _analysesFuture;
  }

  Future<void> _findAndSelectUnanalyzedCalls() async {
    try {
      final analyzedCalls = await _storageService.getAllAnalyses();
      final unanalyzedCalls = await _callFinderService.findAllUnanalyzedCalls(
        analyzedCalls,
      );

      if (mounted) {
        showModalBottomSheet<List<CallRecording>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => UnanalyzedCallsSheet(recordings: unanalyzedCalls),
        ).then((selectedCalls) {
          if (selectedCalls != null && selectedCalls.isNotEmpty) {
            _queueService.addCallsToQueue(selectedCalls); // No await needed
            Fluttertoast.showToast(
              msg:
                  "Starting analysis of ${selectedCalls.length} calls in the background.",
            );
            // Refresh immediately to show placeholders
            _refreshAnalyses();
          }
        });
      }
    } on DirectoryNotSetException {
      if (mounted) {
        await _promptForDirectory();
      }
    } catch (e) {
      print("Failed to find unanalyzed calls: $e");
      if (mounted) {
        Fluttertoast.showToast(msg: 'Could not find calls: ${e.toString()}');
      }
    }
  }

  Future<void> _promptForDirectory() async {
    final didSelect = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Call Recording Folder'),
        content: const Text(
          'Please select the folder where your phone saves call recordings to analyze them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _callFinderService.selectAndSaveDirectory();
              if (mounted) Navigator.of(context).pop(success);
            },
            child: const Text('Select Folder'),
          ),
        ],
      ),
    );
    if (didSelect == true) {
      _findAndSelectUnanalyzedCalls();
    }
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '';
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds min';
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DailyDairiesPage()),
      );
    } else if (index == 2) {
    } else if (index == 3) {
      // Profile or Settings Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TherapyPage()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_ic_call_rounded), // Changed Icon
            tooltip: 'Analyze Unanalyzed Calls',
            onPressed: _findAndSelectUnanalyzedCalls,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshAnalyses, // Correctly references the method
            child: FutureBuilder<List<CallAnalysis>>(
              future: _analysesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Center(
                      heightFactor: 5,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          alignment: Alignment.center,
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    },
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          alignment: Alignment.center,
                          child: _buildEmptyState(),
                        ),
                      );
                    },
                  );
                }

                final analyses = snapshot.data!;
                analyses.sort((a, b) => b.callDate.compareTo(a.callDate));

                // --- FIX: Removed the nested ListView.builder ---
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = analyses[index];
                    // Directly return the card widget here
                    return _buildCallCard(
                      analysis: analysis, // Pass the whole object
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'chat_fab_call',
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDiaryPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_ic_call_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Call Analyses Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the call button in the top right to find and analyze calls from your selected folder.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _findAndSelectUnanalyzedCalls,
              icon: const Icon(Icons.add_ic_call_rounded),
              label: const Text('Find Unanalyzed Calls'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallCard({required CallAnalysis analysis}) {
    final bool isProcessing = analysis.isProcessing;

    final String formattedDate = DateFormat(
      'MMM dd, yyyy',
    ).format(analysis.callDate);
    final String formattedDuration = _formatDuration(
      analysis.durationInSeconds,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isProcessing ? Colors.grey[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analysis.fileName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isProcessing
                    ? AppColors.secondaryText
                    : AppColors.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isProcessing
                  ? 'Analysis in progress...'
                  : '$formattedDate ${formattedDuration.isNotEmpty ? ' • $formattedDuration' : ''}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (isProcessing || analysis.report == null)
                    ? null
                    : () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallDetailPage(
                              caller: analysis.fileName,
                              date: formattedDate,
                              duration: formattedDuration,
                              analysisReport: analysis.report!,
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          _refreshAnalyses();
                        }
                      },
                child: isProcessing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('View Call Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
