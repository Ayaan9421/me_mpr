import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/call_analysis_model.dart';
import 'package:me_mpr/failure/call_analysis_report.dart';
import 'package:me_mpr/failure/call_recording_model.dart';
import 'package:me_mpr/screens/call_detail_page.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/services/call_analysis_queue_service.dart';
import 'package:me_mpr/services/call_finder_service.dart';
import 'package:me_mpr/services/call_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/calls/unanalyzed_calls_sheet.dart';
import 'package:me_mpr/widgets/main_bottom_nav_bar.dart';
import 'home_page.dart';
import 'daily_diaries_page.dart';
import 'create_diary_page.dart';

class CallAnalysisPage extends StatefulWidget {
  const CallAnalysisPage({super.key});

  @override
  State<CallAnalysisPage> createState() => _CallAnalysisPageState();
}

class _CallAnalysisPageState extends State<CallAnalysisPage> {
  int _selectedIndex = 2;
  final CallStorageService _storageService = CallStorageService();
  late Future<List<CallAnalysis>> _analysesFuture;
  final CallFinderService _callFinderService =
      CallFinderService(); // Add finder service
  final CallAnalysisQueueService _queueService = CallAnalysisQueueService();

  @override
  void initState() {
    super.initState();
    _refreshAnalyses();
  }

  // --- NEW METHOD to find and select unanalyzed calls ---
  Future<void> _findAndSelectUnanalyzedCalls() async {
    try {
      // 1. Get the list of calls already analyzed
      final analyzedCalls = await _storageService.getAllAnalyses();
      // 2. Find all recordings in the folder that are NOT in the analyzed list
      final unanalyzedCalls = await _callFinderService.findAllUnanalyzedCalls(
        analyzedCalls,
      );

      if (mounted) {
        // 3. Show the new bottom sheet
        showModalBottomSheet<List<CallRecording>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => UnanalyzedCallsSheet(recordings: unanalyzedCalls),
        ).then((selectedCalls) {
          if (selectedCalls != null && selectedCalls.isNotEmpty) {
            // 4. Add selected calls to the queue
            _queueService.addCallsToQueue(selectedCalls);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Starting analysis of ${selectedCalls.length} calls in the background.',
                ),
              ),
            );
            // Optionally refresh the list after a short delay
            Future.delayed(const Duration(seconds: 2), _refreshAnalyses);
          }
        });
      }
    } on DirectoryNotSetException {
      if (mounted) {
        await _promptForDirectory(); // If directory isn't set, ask again
      }
    } catch (e) {
      print("Failed to find unanalyzed calls: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find calls: ${e.toString()}')),
        );
      }
    }
  }

  // --- Reusing the directory prompt logic ---
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

    // If they selected a folder, try the scan again
    if (didSelect == true) {
      _findAndSelectUnanalyzedCalls();
    }
  }

  void _refreshAnalyses() {
    setState(() {
      _analysesFuture = _storageService.getAllAnalyses();
    });
  }

  Future<void> _refreshData() async {
    // Use Future.wait to run both refresh operations concurrently
    await Future.wait([_storageService.getAllAnalyses()]);
    // Trigger rebuild after both futures complete
    if (mounted) {
      setState(() {
        _analysesFuture = _storageService.getAllAnalyses();
      });
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DailyDairiesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Call Analysis'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_ic_call_rounded),
              tooltip: 'Analyze Unanalyzed Calls',
              onPressed: _findAndSelectUnanalyzedCalls,
            ),
          ],
        ),
        body: Stack(
          children: [
            FutureBuilder<List<CallAnalysis>>(
              future: _analysesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final analyses = snapshot.data!;
                analyses.sort((a, b) => b.callDate.compareTo(a.callDate));

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = analyses[index];
                    return _buildCallCard(
                      caller: analysis.fileName,
                      date: DateFormat(
                        'MMM dd, yyyy',
                      ).format(analysis.callDate),
                      duration: _formatDuration(analysis.durationInSeconds),
                      analysisReport: analysis.report,
                    );
                  },
                );
              },
            ),

            // 👇 Your Positioned FAB (Chat Button)
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'chat_fab',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_call, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Call Analyses Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'New call recordings will be automatically detected and can be analyzed from the Home screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallCard({
    required String caller,
    required String date,
    required String duration,
    required CallAnalysisReport analysisReport,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caller,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$date  •  $duration',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  // --- FIX: Made this async ---
                  // --- FIX: Await the result from the detail page ---
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallDetailPage(
                        caller: caller,
                        date: date,
                        duration: duration,
                        analysisReport: analysisReport,
                      ),
                    ),
                  );
                  // --- FIX: If result is true, refresh the list ---
                  if (result == true && mounted) {
                    _refreshAnalyses();
                  }
                },
                child: const Text('View Call Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
