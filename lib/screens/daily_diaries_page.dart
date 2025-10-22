import 'package:flutter/material.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/create_diary_page.dart';
import 'package:me_mpr/screens/diary_detail_page.dart';
import 'package:me_mpr/screens/home_page.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/dairy_entry_card.dart';
import 'package:me_mpr/widgets/main_bottom_nav_bar.dart';

class DailyDairiesPage extends StatefulWidget {
  const DailyDairiesPage({super.key});

  @override
  State<DailyDairiesPage> createState() => _DailyDairiesPageState();
}

class _DailyDairiesPageState extends State<DailyDairiesPage> {
  late Future<List<DiaryEntry>> _loadDiariesFuture;
  final DiaryStorageService _storageService = DiaryStorageService();
  int _selectedIndex = 1;

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

  Future<void> _refreshData() async {
    // Use Future.wait to run both refresh operations concurrently
    await Future.wait([_storageService.getDiaries()]);
    // Trigger rebuild after both futures complete
    if (mounted) {
      setState(() {
        _loadDiariesFuture = _storageService.getDiaries();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDiariesFuture = _storageService.getDiaries();
  }

  void _refreshDiaries() {
    setState(() {
      _loadDiariesFuture = _storageService.getDiaries();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Daily Diaries Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "No recent diaries. Tap '+' to create one!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Daily Diaries')),
        body: Stack(
          children: [
            FutureBuilder<List<DiaryEntry>>(
              future: _loadDiariesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final diaryEntries = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: diaryEntries.length,
                  itemBuilder: (context, index) {
                    return DiaryEntryCard(
                      entry: diaryEntries[index],
                      isReversed: index.isOdd,
                      onTap: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DiaryDetailPage(entry: diaryEntries[index]),
                          ),
                        );

                        if (result == true) {
                          _refreshDiaries();
                        }
                      },
                    );
                  },
                );
              },
            ),

            // 👇 Chat FAB positioned at bottom-right corner
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'chat_fab',
                backgroundColor: colorScheme.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // existing main FAB (for creating a diary)
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: colorScheme.primary,
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
}
