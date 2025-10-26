import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:me_mpr/models/call_recording_model.dart';
import 'package:me_mpr/models/diary_entry.dart';
import 'package:me_mpr/screens/Home/about_page.dart';
import 'package:me_mpr/screens/Calls/call_analysis_page.dart';
import 'package:me_mpr/screens/ChatBot/chat_screen.dart';
import 'package:me_mpr/screens/Daily%20Diary/create_diary_page.dart';
import 'package:me_mpr/screens/Daily%20Diary/daily_diaries_page.dart';
import 'package:me_mpr/screens/Therapies/therapy_and_support.dart';
import 'package:me_mpr/services/Calls/call_analysis_queue_service.dart';
import 'package:me_mpr/services/Calls/call_finder_service.dart';
import 'package:me_mpr/services/Calls/call_storage_service.dart';
import 'package:me_mpr/services/ChatBot/chat_storage_service.dart';
import 'package:me_mpr/services/Daily%20Diary/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/Calls/new_calls_sheet.dart';
import 'package:me_mpr/widgets/Home/home_section_header.dart';
import 'package:me_mpr/widgets/Home/mood_tracker_card.dart';
import 'package:me_mpr/widgets/Home/recent_calls_section.dart';
import 'package:me_mpr/widgets/Home/recent_diaries_section.dart';
import 'package:me_mpr/widgets/Home/select_reset_chat_hour.dart';
import 'package:me_mpr/widgets/main_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final DiaryStorageService _storageService = DiaryStorageService();
  late Future<List<DiaryEntry>> _diariesFuture;
  final CallFinderService _callFinderService = CallFinderService();
  final CallAnalysisQueueService _queueService = CallAnalysisQueueService();
  final CallStorageService _callStorageService = CallStorageService();
  final ChatStorageService _chatStorageService = ChatStorageService();
  late Future<List<CallAnalysis>> _callAnalysesFuture;
  final user =
      FirebaseAuth.instance.currentUser!.displayName ??
      FirebaseAuth.instance.currentUser!.email ??
      'User';

  // --- NEW: State for Mood Data ---
  late Future<double?> _avgMoodFuture;
  late Future<int> _streakFuture;
  late Future<Set<int>> _daysWithEntriesFuture;

  @override
  void initState() {
    super.initState();
    _diariesFuture = _storageService.getDiaries();
    _refreshAllData();
    // Check for new calls shortly after the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewCalls();
      _promptForChatResetHourIfNeeded();
    });
  }

  // --- NEW: Check and prompt for chat reset hour ---
  Future<void> _promptForChatResetHourIfNeeded() async {
    final hasSetHour = await _chatStorageService.hasSetResetHour();
    if (!hasSetHour && mounted) {
      final int? selectedHour = await showDialog<int>(
        context: context,
        barrierDismissible: false, // User must choose
        builder: (context) => const SelectResetHourDialog(),
      );
      if (selectedHour != null) {
        await _chatStorageService.setResetHour(selectedHour);
        Fluttertoast.showToast(
          msg: "Chat reset time set to $selectedHour:00 daily.",
        );
      } else {
        // User might have dismissed somehow, default to 3 AM
        await _chatStorageService.setResetHour(3);
        Fluttertoast.showToast(
          msg: "Chat reset time defaulted to 3:00 AM daily.",
        );
      }
    }
  }

  Future<void> _refreshAllData() async {
    // Use setState to immediately show loading for mood data too
    setState(() {
      _diariesFuture = _storageService.getDiaries();
      _callAnalysesFuture = _callStorageService.getAllAnalyses();
      _avgMoodFuture = _storageService.getAverageWeeklyMoodScore();
      _streakFuture = _storageService.getCurrentJournalingStreak();
      _daysWithEntriesFuture = _storageService.getWeekdaysWithEntries();
    });
    // Wait for all futures to complete for RefreshIndicator
    await Future.wait([
      _diariesFuture,
      _callAnalysesFuture,
      _avgMoodFuture,
      _streakFuture,
      _daysWithEntriesFuture,
    ]);
  }

  void _refreshDiaries() {
    setState(() {
      _diariesFuture = _storageService.getDiaries();
    });
  }

  void _refreshCalls() {
    setState(() {
      _callAnalysesFuture = _callStorageService.getAllAnalyses();
    });
  }

  Future<void> _checkForNewCalls() async {
    try {
      final newCalls = await _callFinderService.findNewCallRecordings();
      if (newCalls.isNotEmpty && mounted) {
        showModalBottomSheet<List<CallRecording>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => NewCallsSheet(recordings: newCalls),
        ).then((selectedCalls) {
          if (selectedCalls != null && selectedCalls.isNotEmpty) {
            _queueService.addCallsToQueue(selectedCalls);
            Fluttertoast.showToast(
              msg:
                  "Starting analysis of ${selectedCalls.length} calls in the background.",
            );
            // Refresh calls list slightly later to allow queue processing to start
            Future.delayed(const Duration(seconds: 1), _refreshAllData);
          }
        });
      }
    } on DirectoryNotSetException {
      // Directory not set, optionally prompt the user to select one
      if (mounted) {
        await _promptForDirectory();
      }
    } catch (e) {
      print("Failed to check for new calls: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not check for calls: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _promptForDirectory() async {
    final didSelect = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => AlertDialog(
        title: const Text('Select Call Recording Folder'),
        content: const Text(
          'To automatically find new calls, please select the folder where your phone saves call recordings. This is a one-time setup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Later'),
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

    // If they successfully selected a folder, immediately try checking again.
    if (didSelect == true) {
      _checkForNewCalls();
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DailyDairiesPage()),
      ).then((_) => _refreshAllData());
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CallAnalysisPage()),
      ).then((_) => _refreshAllData());
    } else if (index == 3) {
      // Profile or Settings Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TherapyPage()),
      ).then((_) => _refreshAllData());
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('MindEase'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 28),
          onPressed: _showProfileDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: const Text('Profile options would go here.'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7BDCB5), Color(0xFF4F8EF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              'MindEase User',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(user.toString()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black54, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text('Call Analysis'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CallAnalysisPage(),
                ),
              ).then((_) => _refreshCalls());
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Journal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyDairiesPage(),
                ),
              ).then((_) => _refreshDiaries());
            },
          ),
          ListTile(
            // --- ADDED About Page Link ---
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About MindEase'),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Made with ❤️ by Aayush',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              // Ensures scroll even if content fits screen
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicMoodTracker(),
                  const SizedBox(height: 28),
                  const HomeSectionHeader(title: '✨ Daily Diaries'),
                  const SizedBox(height: 12),
                  RecentDiariesSection(
                    diariesFuture: _diariesFuture,
                    onRefresh: _refreshDiaries,
                  ),
                  const SizedBox(height: 20),
                  const HomeSectionHeader(title: '📞 Recent Calls'),
                  const SizedBox(height: 12),
                  RecentCallsSection(
                    analysesFuture: _callAnalysesFuture,
                    onRefresh: _refreshCalls,
                  ),
                ],
              ),
            ),
          ),
        ),
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
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // --- NEW: Wrapper for MoodTrackerCard using FutureBuilders ---
  Widget _buildDynamicMoodTracker() {
    return FutureBuilder(
      // Use Future.wait to load all mood data together
      future: Future.wait([
        _avgMoodFuture,
        _streakFuture,
        _daysWithEntriesFuture,
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a placeholder while loading
          return const SizedBox(
            height: 180, // Estimate height of the card
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (snapshot.hasError) {
          print("Error loading mood data: ${snapshot.error}");
          // Show a simple state on error, maybe with a retry option?
          return MoodTrackerCard(
            averageMoodScore: null,
            streakCount: 0,
            daysWithEntries: const {},
          );
        }
        if (snapshot.hasData) {
          final double? avgMood = snapshot.data![0] as double?;
          final int streak = snapshot.data![1] as int;
          final Set<int> days = snapshot.data![2] as Set<int>;

          return MoodTrackerCard(
            averageMoodScore: avgMood,
            streakCount: streak,
            daysWithEntries: days,
          );
        }
        // Default empty state
        return MoodTrackerCard(
          averageMoodScore: null,
          streakCount: 0,
          daysWithEntries: const {},
        );
      },
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      heroTag: 'add_fab',
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const CreateDiaryPage()),
        );
        if (result == true && mounted) {
          _refreshAllData();
        }
      },
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
