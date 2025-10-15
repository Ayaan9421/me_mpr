import 'package:flutter/material.dart';
import 'package:me_mpr/widgets/calls/insights_section.dart';
import 'package:me_mpr/widgets/calls/sentiment_breakdown_chart.dart';
import 'package:me_mpr/widgets/calls/sentiment_summary_card.dart';

class CallDetailPage extends StatelessWidget {
  final String caller;
  final String date;
  final String duration;
  final Map<String, dynamic> analysisData;

  const CallDetailPage({
    super.key,
    required this.caller,
    required this.date,
    required this.duration,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Call Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SentimentSummaryCard(
              caller: caller,
              date: date,
              duration: duration,
            ),
            const SizedBox(height: 16),
            SentimentBreakdownChart(
              positive: analysisData['positive'],
              neutral: analysisData['neutral'],
              negative: analysisData['negative'],
            ),
            const SizedBox(height: 16),
            InsightsSection(insights: analysisData['insights']),
          ],
        ),
      ),
    );
  }
}
