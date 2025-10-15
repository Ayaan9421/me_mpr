import 'package:flutter/material.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/calls/call_analysis_card.dart';
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

  // Predefined analysis data for variety
  final List<Map<String, dynamic>> analysisData = [
    {
      'positive': 0.8,
      'neutral': 0.1,
      'negative': 0.1,
      'insights': [
        'The user sounded relaxed and thankful.',
        'Good engagement throughout the call.',
        'Keywords: “helpful”, “better”, “thanks”.',
      ],
    },
    {
      'positive': 0.6,
      'neutral': 0.3,
      'negative': 0.1,
      'insights': [
        'The tone was polite but slightly uncertain.',
        'Some hesitation detected in responses.',
        'Keywords: “maybe”, “try”, “okay”.',
      ],
    },
    {
      'positive': 0.5,
      'neutral': 0.3,
      'negative': 0.2,
      'insights': [
        'Conversation contained mixed emotions.',
        'User mentioned stress multiple times.',
        'Keywords: “stress”, “tired”, “busy”.',
      ],
    },
    {
      'positive': 0.9,
      'neutral': 0.05,
      'negative': 0.05,
      'insights': [
        'Very positive and uplifting conversation.',
        'User expressed satisfaction and happiness.',
        'Keywords: “awesome”, “grateful”, “amazing”.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Analysis')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final caller = index % 2 == 0 ? 'Dr. Smith' : 'Support Line';
          final duration = '${10 + index * 2} min';
          final date = 'Oct ${10 - index}, 2025';
          final data = analysisData[index % analysisData.length];

          return CallAnalysisCard(
            caller: caller,
            date: date,
            duration: duration,
            analysisData: data,
          );
        },
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
