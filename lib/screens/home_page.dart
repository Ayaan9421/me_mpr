import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Colors ---
  static const Color backgroundColor = Color(0xFFF1F8E9);
  static const Color fabColor = Color(0xFFFFC107);

  // --- State for Bottom Navigation Bar ---
  int _selectedIndex = 0; // 0 for Home, 1 for Stats, 2 for Notifs, 3 for Profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped on button index: $index')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'MindEase',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.black87),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  await FirebaseAuth.instance.signOut();
                  break;
                case 'settings':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Settings clicked")),
                  );
                  break;
                case 'update_profile':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Update Profile clicked")),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Logout'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.blueGrey),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'update_profile',
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.orange),
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
              decoration: BoxDecoration(
                color: Color(0xFFB3E5FC),
              ),
              child: Text(
                'MindEase Menu',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Call Analysis'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Blogs'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // BODY WRAPPED IN STACK FOR FLOATING BUTTONS
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                  const SizedBox(height: 100), // Extra space at bottom
                ],
              ),
            ),
          ),

          // 💬 Chatbot FAB (fixed bottom-right)
          Positioned(
            bottom: 90, // stays above bottom bar
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chatbot clicked!")),
                );
              },
              backgroundColor: fabColor,
              elevation: 6,
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),

      // ➕ Center '+' FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New journal entry clicked!")),
          );
        },
        backgroundColor: const Color(0xFF009688),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ⬇️ Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.white,
        elevation: 8,
        notchMargin: 8.0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.home_filled,
                      color: _selectedIndex == 0 ? Colors.teal : Colors.grey),
                  onPressed: () => _onItemTapped(0)),
              IconButton(
                  icon: Icon(Icons.bar_chart,
                      color: _selectedIndex == 1 ? Colors.teal : Colors.grey),
                  onPressed: () => _onItemTapped(1)),
              const SizedBox(width: 48), // space for FAB
              IconButton(
                  icon: Icon(Icons.notifications_none,
                      color: _selectedIndex == 2 ? Colors.teal : Colors.grey),
                  onPressed: () => _onItemTapped(2)),
              IconButton(
                  icon: Icon(Icons.person_outline,
                      color: _selectedIndex == 3 ? Colors.teal : Colors.grey),
                  onPressed: () => _onItemTapped(3)),
            ],
          ),
        ),
      ),
    );
  }

  // 🌤 Mood Tracker
  Widget _buildMoodTracker() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Mood',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('5-day streak', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const Text('😊', style: TextStyle(fontSize: 40)),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFA5D6A7),
                      child: Text(day,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
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
        _buildDiaryEntry('😌', 'Feeling Calm', 'Oct 07, 8:15 PM'),
      ],
    );
  }

  Widget _buildDiaryEntry(String emoji, String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 26)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
      String emoji, String caller, String time, String duration) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 26)),
      title: Text(caller,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle:
          Text('$time  •  $duration', style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.call, color: Colors.green),
      onTap: () {},
    );
  }

  // 📰 Blogs Section
  Widget _buildBlogsSection() {
    return _buildSectionCard(
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
                fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  // 🚨 SOS Section
  Widget _buildSosSection() {
    return _buildSectionCard(
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
  }

  // 🔹 Reusable Section Builder
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
              child: const Text('View more'),
            ),
          ),
        ]),
      ),
    );
  }
}
