import 'package:flutter/material.dart';
import 'package:me_mpr/models/therapist.dart';
import 'package:me_mpr/models/therapy_recommendation.dart';
import 'package:me_mpr/services/Daily%20Diary/diary_storage_service.dart';
import 'package:me_mpr/services/Therapies/recommendation_service.dart';
import 'package:me_mpr/widgets/Therapies/therapist.dart';
import 'package:me_mpr/widgets/Therapies/therapist_map.dart';
import 'package:me_mpr/widgets/Therapies/therapy.dart';
import 'package:me_mpr/widgets/main_bottom_nav_bar.dart';
// --- FIX: Corrected import path for TherapistMap ---
import '../Home/home_page.dart';
import '../Daily Diary/daily_diaries_page.dart';
import '../Calls/call_analysis_page.dart';
import '../Daily Diary/create_diary_page.dart';

class TherapyPage extends StatefulWidget {
  const TherapyPage({super.key});

  @override
  State<TherapyPage> createState() => _TherapyPageState();
}

class _TherapyPageState extends State<TherapyPage> {
  int _selectedIndex = 3;
  final RecommendationService _recommendationService = RecommendationService();
  final DiaryStorageService _diaryService = DiaryStorageService();
  late Future<Map<String, dynamic>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final avgMood = await _diaryService.getAverageWeeklyMoodScore();
    setState(() {
      _recommendationsFuture = _recommendationService.getRecommendations(
        avgMood,
      );
    });
  }

  Future<void> _refreshRecommendations() async {
    await _loadRecommendations();
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CallAnalysisPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Therapies & Support')),
      body: RefreshIndicator(
        onRefresh: _refreshRecommendations,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _recommendationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading recommendations: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No recommendations found.'));
            }

            final therapies =
                snapshot.data!['therapies'] as List<TherapyRecommendation>;
            final therapists = snapshot.data!['therapists'] as List<Therapist>;
            // --- This list is used for the map ---
            final nearbyTherapistsForMap =
                snapshot.data!['nearby'] as List<Therapist>;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                const Text(
                  'Recommended Activities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (therapies.isEmpty)
                  const Text(
                    'No specific activities recommended right now.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...therapies.map((t) => TherapyCard(recommendation: t)),

                const SizedBox(height: 24),

                const Text(
                  'Suggested Therapists',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (therapists.isEmpty)
                  const Text(
                    'No specific therapists recommended right now.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...therapists.take(2).map((t) => TherapistCard(therapist: t)),

                const SizedBox(height: 24),

                const Text(
                  'Nearby Support',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // --- FIX: Replaced placeholder with the actual map ---
                TherapistMap(therapists: nearbyTherapistsForMap),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
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
}
