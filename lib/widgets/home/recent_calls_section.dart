import 'package:flutter/material.dart';
import 'package:me_mpr/screens/call_analysis_page.dart';

class RecentCallsSection extends StatelessWidget {
  const RecentCallsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCallEntry(
          context,
          '😊',
          'Dr. Smith',
          'Yesterday, 4:00 PM',
          '15 min',
        ),
        const SizedBox(height: 12),
        _buildCallEntry(
          context,
          '😟',
          'Support Line',
          'Oct 06, 11:20 AM',
          '25 min',
        ),
        const SizedBox(height: 12),
        _buildCallEntry(context, '😟', 'Aayush', 'Oct 06, 11:20 AM', '25 min'),
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
    BuildContext context,
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
