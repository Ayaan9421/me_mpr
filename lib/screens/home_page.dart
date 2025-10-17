import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:me_mpr/failure/call_recording_model.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/create_diary_page.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/services/call_analysis_queue_service.dart';
import 'package:me_mpr/services/call_finder_service.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/calls/new_calls_sheet.dart';
import 'package:me_mpr/widgets/home/home_section_header.dart';
import 'package:me_mpr/widgets/home/mood_tracker_card.dart';
import 'package:me_mpr/widgets/home/recent_calls_section.dart';
import 'package:me_mpr/widgets/home/recent_diaries_section.dart';
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

  @override
  void initState() {
    super.initState();
    _diariesFuture = _storageService.getDiaries();
    // Check for new calls shortly after the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForNewCalls());
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Starting analysis of ${selectedCalls.length} calls in the background.',
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Failed to check for new calls: $e");
      // Optionally show a SnackBar to the user about the error (e.g., permissions)
    }
  }

  void _refreshDiaries() {
    setState(() {
      _diariesFuture = _storageService.getDiaries();
    });
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CallAnalysisPage()),
      );
    } else if (index == 3) {
      // Profile or Settings Page
      showSnackBar(context, "SOS coming soon!");
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
          const UserAccountsDrawerHeader(
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
            accountEmail: Text('user@example.com'),
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
              );
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
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MoodTrackerCard(),
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
                const RecentCallsSection(),
              ],
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
          _refreshDiaries();
        }
      },
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
