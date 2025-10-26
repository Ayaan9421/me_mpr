import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:me_mpr/models/therapy_recommendation.dart';
import 'package:me_mpr/utils/app_colors.dart';

class TherapyGuidePage extends StatelessWidget {
  final TherapyRecommendation recommendation;
  final List<String> steps; // Pass the steps for this specific therapy

  const TherapyGuidePage({
    super.key,
    required this.recommendation,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recommendation.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: recommendation.iconColor.withOpacity(0.15),
                  child: Icon(
                    recommendation.icon,
                    color: recommendation.iconColor,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    recommendation.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'How to Practice:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              steps.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Simple completion feedback
                  Fluttertoast.showToast(
                    msg: "${recommendation.title} marked as complete!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppColors.success,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  // TODO: Add gamification logic here
                  Navigator.pop(context);
                },
                child: const Text('Mark as Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
