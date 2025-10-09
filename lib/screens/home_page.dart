import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:me_mpr/screens/chat_screen.dart';
import 'package:me_mpr/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =
      0; // 0 for Home, 1 for Stats, 2 for Notifs, 3 for Profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Placeholder for navigation or other actions
  }

  @override
  Widget build(BuildContext context) {
    // Get colors from the theme for consistency
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        // Properties are now set by the global theme in main.dart
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('MindEase'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  await FirebaseAuth.instance.signOut();
                  break;
                case 'settings':
                  // Navigate to settings page
                  break;
                case 'update_profile':
                  // Navigate to profile page
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text('Logout'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: AppColors.secondaryText),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'update_profile',
                child: ListTile(
                  leading: Icon(Icons.edit, color: AppColors.accentYellow),
                  title: Text('Update Profile'),
                ),
              ),
            ],
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
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                120,
              ), // Padding for FABs
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMoodTracker(),
                  const SizedBox(height: 24),
                  _buildDailyDairies(),
                  const SizedBox(height: 24),
                  _buildCalls(),
                  const SizedBox(height: 24),
                  _buildBlogsSection(),
                  const SizedBox(height: 24),
                  _buildSosSection(),
                ],
              ),
            ),
          ),
          // 💬 Chatbot FAB (fixed bottom-right)
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Navigate to the ChatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              // Color is from global theme
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new journal entry
        },
        backgroundColor: colorScheme.primary, // Use primary accent (teal)
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_filled,
                index: 0,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                icon: Icons.bar_chart,
                index: 1,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 48), // space for FAB
              _buildNavItem(
                icon: Icons.notifications_none,
                index: 2,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                index: 3,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for BottomAppBar items to reduce repetition
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? colorScheme.primary : AppColors.secondaryText,
        size: isSelected ? 30 : 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  // 🌤 Mood Tracker
  Widget _buildMoodTracker() {
    return Card(
      // Uses global CardTheme
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mood',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '5-day streak',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ],
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
                      backgroundColor: AppColors.moodGood,
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

  // 📔 Daily Diaries
  Widget _buildDailyDairies() {
    return _buildSectionCard(
      title: 'Daily Diaries',
      icon: Icons.menu_book_rounded,
      children: [
        _buildDiaryEntry('😄', 'Great Day!', 'Oct 09, 2:30 PM'),
        _buildDiaryEntry('😐', 'A bit stressed', 'Oct 08, 9:00 AM'),
      ],
    );
  }

  Widget _buildDiaryEntry(String emoji, String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 26)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.secondaryText,
      ),
      onTap: () {},
    );
  }

  // ☎️ Calls
  Widget _buildCalls() {
    return _buildSectionCard(
      title: 'Recent Calls',
      icon: Icons.call_rounded,
      children: [
        _buildCallEntry('😊', 'Dr. Smith', 'Yesterday, 4:00 PM', '15 min'),
        _buildCallEntry('😟', 'Support Line', 'Oct 06, 11:20 AM', '25 min'),
      ],
    );
  }

  Widget _buildCallEntry(
    String emoji,
    String caller,
    String time,
    String duration,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 26)),
      title: Text(
        caller,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        '$time  •  $duration',
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      trailing: const Icon(Icons.call, color: AppColors.moodGood),
      onTap: () {},
    );
  }

  // 📰 Blogs & 🚨 SOS Sections
  Widget _buildBlogsSection() => _buildSectionCard(
    title: 'Mindfulness Blogs',
    icon: Icons.article_outlined,
    children: [
      Container(
        height: 120,
        alignment: Alignment.center,
        child: const Text(
          '✨ “A calm mind brings inner strength.” ✨',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ],
  );

  Widget _buildSosSection() => _buildSectionCard(
    title: 'Emergency Contacts',
    icon: Icons.emergency_rounded,
    children: [
      Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          '📞 24x7 Support: 1800-123-HELP',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );

  // 🔹 Reusable Section Builder
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ), // Use theme color
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('View more'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
