import 'package:flutter/material.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/screens/home_page.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/custom_bottom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/create_diary_page.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/custom_bottom_appbar.dart';

class CallAnalysisPage extends StatefulWidget {
  const CallAnalysisPage({super.key});

  @override
  State<CallAnalysisPage> createState() => _CallAnalysisPageState();
}

class _CallAnalysisPageState extends State<CallAnalysisPage> {
  static const Color backgroundColor = Color(0xFFF1F8E9);
  static const Color fabColor = Color(0xFFFFC107);

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Call Analysis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 10,
            itemBuilder: (context, index) {
              final caller = index % 2 == 0 ? 'Dr. Smith' : 'Support Line';
              final duration = '${10 + index * 2} min';
              final date = 'Oct ${10 - index}, 2025';

              // Pick a different analysis pattern for each call
              final data = analysisData[index % analysisData.length];

              return _buildCallAnalysisCard(
                caller,
                date,
                duration,
                data['positive'],
                data['neutral'],
                data['negative'],
                data['insights'],
              );
            },
          ),

          // 💬 Chatbot Floating Button
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              ),
              backgroundColor: const Color(0xFF4F8EF7),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
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

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCallAnalysisCard(
    String caller,
    String date,
    String duration,
    double positive,
    double neutral,
    double negative,
    List<String> insights,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // The "Call Analysis" button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallDetailPage(
                        caller: caller,
                        date: date,
                        duration: duration,
                        positive: positive,
                        neutral: neutral,
                        negative: negative,
                        insights: insights,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.teal,
                  side: BorderSide(color: Colors.teal.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Call Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📊 Detailed Analysis Page
// -----------------------------------------------------------------------------
class CallDetailPage extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;
  final double positive;
  final double neutral;
  final double negative;
  final List<String> insights;

  const CallDetailPage({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
    required this.positive,
    required this.neutral,
    required this.negative,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Detailed Call Analysis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧾 Call Summary
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caller: $caller',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Date: $date',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Duration: $duration',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Call Sentiment Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildProgressBar('Positive', positive, Colors.green),
              _buildProgressBar('Neutral', neutral, Colors.orange),
              _buildProgressBar('Negative', negative, Colors.red),

              const SizedBox(height: 30),

              const Text(
                'Key Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...insights.map(_buildInsightTile).toList(),

              const Spacer(),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "Back",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(String text) {
    return ListTile(
      leading: const Icon(Icons.insights, color: Colors.teal),
      title: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}
