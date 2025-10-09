import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/create_diary_page.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/screens/diary_detail_page.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/custom_bottom_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final DiaryStorageService _storageService = DiaryStorageService();
  late Future<List<DiaryEntry>> _diariesFuture;

  @override
  void initState() {
    super.initState();
    _diariesFuture = _storageService.getDiaries();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'MindEase',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 28,
              color: Colors.black87,
            ),
            onPressed: () {
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
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodTracker(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('✨ Daily Diaries'),
                  const SizedBox(height: 12),
                  _buildDailyDairies(),
                  const SizedBox(height: 5),
                  _buildSectionHeader('📞 Recent Calls'),
                  const SizedBox(height: 12),
                  _buildCalls(),
                ],
              ),
            ),
          ),

          // --- Chat Button ---
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

  Drawer _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7BDCB5), Color(0xFF4F8EF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'MindEase User',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('user@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black54, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
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
            onTap: () => Navigator.pop(context),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  // 🌈 Beautiful Mood Tracker Card
  Widget _buildMoodTracker() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9CECFB), Color(0xFF65C7F7), Color(0xFF0052D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Mood',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text('😊', style: TextStyle(fontSize: 42)),
              ],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You’re on a 5-day streak! Keep going 💪',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 📔 Daily Diaries Section
  Widget _buildDailyDairies() {
    return FutureBuilder<List<DiaryEntry>>(
      future: _diariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load diaries.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text(
              'No recent diaries. Tap "+" to create one!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Take the 2 most recent diaries
        final recentDiaries = snapshot.data!.take(3).toList();

        return Column(
          children: [
            ...recentDiaries.map((entry) {
              return InkWell(
                onTap: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryDetailPage(entry: entry),
                      ),
                    ).then((_) {
                      // Refresh diaries when returning
                      _refreshDiaries();
                    }),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildDiaryEntry(
                    entry.emoji,
                    entry.title,
                    // Format the date nicely
                    DateFormat('MMM dd, h:mm a').format(entry.dateTime),
                  ),
                ),
              );
            }).toList(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  // Await result and refresh if a diary was deleted
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyDairiesPage(),
                    ),
                  );
                  if (result == true && mounted) {
                    _refreshDiaries();
                  }
                },
                child: const Text('View more →'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiaryEntry(String emoji, String title, String time) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  // ☎️ Recent Calls Section
  Widget _buildCalls() {
    return Column(
      children: [
        _buildCallEntry('😊', 'Dr. Smith', 'Yesterday, 4:00 PM', '15 min'),
        const SizedBox(height: 12),
        _buildCallEntry('😟', 'Support Line', 'Oct 06, 11:20 AM', '25 min'),
        const SizedBox(height: 12),
        _buildCallEntry('😟', 'Aayush', 'Oct 06, 11:20 AM', '25 min'),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CallAnalysisPage(),
                ),
              );
            },
            child: const Text('View more →'),
          ),
        ),
      ],
    );
  }

  Widget _buildCallEntry(
    String emoji,
    String caller,
    String time,
    String duration,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallAnalysisPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 30)),
          title: Text(
            caller,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            '$time  •  $duration',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 26,
          ),
        ),
      ),
    );
  }
}
