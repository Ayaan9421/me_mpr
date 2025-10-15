import 'package:flutter/material.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/create_diary_page.dart';
import 'package:me_mpr/screens/diary_detail_page.dart';
import 'package:me_mpr/screens/home_page.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/custom_bottom_appbar.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diaries')),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _loadDiariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t written any diary entries yet.',
                textAlign: TextAlign.center,
              ),
            );
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
                  // --- FIX APPLIED HERE ---
                  // We 'await' the result from the detail page.
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiaryDetailPage(entry: diaryEntries[index]),
                    ),
                  );

                  // If the result is 'true', it means a deletion happened.
                  // So we call _refreshDiaries() to update the list.
                  if (result == true) {
                    _refreshDiaries();
                  }
                },
              );
            },
          );
        },
      ),
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
    );
  }
}
