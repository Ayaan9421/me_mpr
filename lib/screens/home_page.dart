import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/screens/daily_diaries_page.dart';
import 'package:me_mpr/utils/app_colors.dart';
import 'package:me_mpr/widgets/custom_bottom_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0 for Home, 1 for Diaries, 2 for Calls, 3 for SOS

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Placeholder for future navigation
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('MindEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {
              // Simple dialog to show profile options
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
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryBlue),
              child: Text(
                'MindEase Menu',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Call Analysis'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodTracker(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Daily Diaries'),
                  const SizedBox(height: 12),
                  _buildDailyDairies(),
                  _buildSectionHeader('Recent Calls'),
                  const SizedBox(height: 12),
                  _buildCalls(),
                ],
              ),
            ),
          ),
          // --- AI Chat FAB ---
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              backgroundColor: colorScheme.secondary,
              child: const Icon(Icons.chat_bubble, color: Colors.white),
            ),
          ),
        ],
      ),
      // --- Center "Add" FAB ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle new entry action
        },
        backgroundColor: colorScheme.primary, // Teal color
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // --- Using the new reusable Bottom App Bar ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Reusable header for sections like "Daily Diaries"
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  // 🌤 Mood Tracker (Updated UI)
  Widget _buildMoodTracker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mood',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '5-day streak',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                const Text('😊', style: TextStyle(fontSize: 40)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.moodGood.withOpacity(0.7),
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
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

  // 📔 Daily Diaries (Updated UI with navigation)
  Widget _buildDailyDairies() {
    return Column(
      children: [
        _buildDiaryEntry(
          '😄',
          'Had a Great Day!',
          'Oct 09, 2:30 PM',
          isReversed: false,
        ),
        const SizedBox(height: 12),
        _buildDiaryEntry(
          '😐',
          'A bit stressed today',
          'Oct 08, 9:00 AM',
          isReversed: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyDairiesPage()),
              );
            },
            child: const Text('View more'),
          ),
        ),
      ],
    );
  }

  // ☎️ Calls (Updated UI)
  Widget _buildCalls() {
    return Column(
      children: [
        _buildCallEntry(
          '😊',
          'Dr. Smith',
          'Yesterday, 4:00 PM',
          '15 min',
          isReversed: false,
        ),
        const SizedBox(height: 12),
        _buildCallEntry(
          '😟',
          'Support Line',
          'Oct 06, 11:20 AM',
          '25 min',
          isReversed: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              /* Navigate to full call log */
            },
            child: const Text('View more'),
          ),
        ),
      ],
    );
  }

  // Reusable card for diary entries on the home page (with spacing fix)
  Widget _buildDiaryEntry(
    String emoji,
    String title,
    String time, {
    bool isReversed = false,
  }) {
    final emojiWidget = Text(emoji, style: const TextStyle(fontSize: 32));
    final detailsWidget = Column(
      crossAxisAlignment: isReversed
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: AppColors.secondaryText)),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: isReversed
              ? [
                  Expanded(child: detailsWidget),
                  const SizedBox(width: 16),
                  emojiWidget,
                ]
              : [
                  emojiWidget,
                  const SizedBox(width: 16),
                  Expanded(child: detailsWidget),
                ],
        ),
      ),
    );
  }

  // Reusable card for call entries on the home page (with spacing fix)
  Widget _buildCallEntry(
    String emoji,
    String caller,
    String time,
    String duration, {
    bool isReversed = false,
  }) {
    final emojiWidget = Text(emoji, style: const TextStyle(fontSize: 32));
    final detailsWidget = Column(
      crossAxisAlignment: isReversed
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          caller,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '$time  •  $duration',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: isReversed
              ? [
                  Expanded(child: detailsWidget),
                  const SizedBox(width: 16),
                  emojiWidget,
                ]
              : [
                  emojiWidget,
                  const SizedBox(width: 16),
                  Expanded(child: detailsWidget),
                ],
        ),
      ),
    );
  }
}
