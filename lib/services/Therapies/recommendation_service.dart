import 'package:flutter/material.dart';
import 'package:me_mpr/models/therapist.dart';
import 'package:me_mpr/models/therapy_recommendation.dart';
import 'package:me_mpr/utils/app_colors.dart';

class RecommendationService {
  // Mock data - replace with actual fetching logic later
  final List<TherapyRecommendation> _allTherapies = [
    // Acceptance (score 0-2) – Feeling Calm 😌
    TherapyRecommendation(
      title: 'Guided Meditation',
      description: 'Follow a 5-minute guided session to calm your mind.',
      icon: Icons.self_improvement_rounded,
      iconColor: Colors.purple.shade300,
    ),
    TherapyRecommendation(
      title: 'Positive Affirmations',
      description: 'Repeat positive statements to boost self-esteem.',
      icon: Icons.favorite_border_rounded,
      iconColor: AppColors.accent,
    ),

    // Denial (score 3-4) – Feeling Conflicted 🤔
    TherapyRecommendation(
      title: 'Mindful Walking',
      description: 'Take a short walk and focus on your senses.',
      icon: Icons.directions_walk_rounded,
      iconColor: Colors.green.shade400,
    ),
    TherapyRecommendation(
      title: 'Visualization Exercise',
      description: 'Imagine a calm and safe place to reduce inner tension.',
      icon: Icons.landscape_rounded,
      iconColor: Colors.orange.shade300,
    ),

    // Bargaining (score 5-6) – Feeling Worried 🥺
    TherapyRecommendation(
      title: 'Journal Prompts',
      description: 'Explore guided prompts to understand your feelings.',
      icon: Icons.edit_note_rounded,
      iconColor: AppColors.accentYellow,
    ),
    TherapyRecommendation(
      title: 'Box Breathing Exercise',
      description: 'Practice structured breathing to regain focus.',
      icon: Icons.air_rounded,
      iconColor: Colors.lightBlue.shade300,
    ),

    // Anger (score 7-8) – Feeling Agitated 😠
    TherapyRecommendation(
      title: 'Physical Activity / Exercise',
      description: 'Release pent-up energy through short physical exercises.',
      icon: Icons.fitness_center_rounded,
      iconColor: Colors.red.shade400,
    ),
    TherapyRecommendation(
      title: 'Cold Water Splash / Relaxation Technique',
      description: 'Use a quick grounding technique to reduce anger spikes.',
      icon: Icons.water_rounded,
      iconColor: Colors.blue.shade300,
    ),

    // Depression (score 9-10) – Feeling Down 😔
    TherapyRecommendation(
      title: 'Listen to Uplifting Music',
      description: 'Engage with music that boosts your mood gradually.',
      icon: Icons.music_note_rounded,
      iconColor: Colors.pink.shade300,
    ),
    TherapyRecommendation(
      title: 'Connect with a Friend or Family Member',
      description: 'Reach out to someone you trust to share your feelings.',
      icon: Icons.people_rounded,
      iconColor: Colors.teal.shade300,
    ),
  ];

  final List<Therapist> _allTherapists = [
    Therapist(
      name: 'Dr. Rochelle Gomes',
      specialization: 'Counselling Psychologist (CBT & Relationship Therapy)',
      address:
          'Ria Psychological Centre, 36 Turner Road, Bandra West, Mumbai 400050',
      contact: 'riapsychology.com / +91 98207 77917',
      latitude: 19.0598,
      longitude: 72.8296,
    ),
    Therapist(
      name: 'Dr. Harleen Kaur',
      specialization: 'Individual & Couples Psychotherapy',
      address:
          'House of Cure, Linking Road, near DBS Bank, Khar West, Mumbai 400052',
      contact: 'therapywithharleen.com / +91 89297 79967',
      latitude: 19.0615,
      longitude: 72.8362,
    ),
    Therapist(
      name: 'Dr. Alisha Lalljee',
      specialization: 'Clinical Psychologist (Anxiety, Depression & Trauma)',
      address:
          'AVD Residencia, 28 Dr. Ambedkar Road, Bandra West, Mumbai 400050',
      contact: 'alishalalljee.com / +91 98190 58324',
      latitude: 19.0554,
      longitude: 72.8291,
    ),
    Therapist(
      name: 'Ms. Kajal Vora',
      specialization:
          'Counsellor & Mental Wellness Coach (Mindfulness & Self-Growth)',
      address:
          'Giraffe Space by Kajal, Amba Sadan, Linking Road, Khar West, Mumbai 400052',
      contact: 'giraffespacebykajal.com / +91 99305 01548',
      latitude: 19.0609,
      longitude: 72.8358,
    ),
    Therapist(
      name: 'Dr. Aparna Joshi',
      specialization:
          'Child & Adolescent Therapy (Behavioral & Emotional Wellness)',
      address:
          'Better Self – Psychological Wellness Center, Perry Cross Road, Bandra West, Mumbai 400050',
      contact: 'betterself.in / +91 98580 98560',
      latitude: 19.0548,
      longitude: 72.8299,
    ),
    Therapist(
      name: 'Dr. Kenil Shah',
      specialization: 'Child Psychology',
      address: '10 Harmony Rd, Dombivli',
      contact: 'kenil-child.com / 6543210987',
      latitude: 19.2183, // Coordinates for Dombivli
      longitude: 73.0867,
    ),
    Therapist(
      name: 'Ms. Sunita Patil',
      specialization: 'Trauma & PTSD',
      address: '5 Resilience Path, Thane',
      contact: 'sunita-support.org / 5432109876',
      latitude: 19.2184, // Coordinates for Thane
      longitude: 72.9781,
    ),
  ];

  /// Simulates fetching recommendations based on average mood score (0-10)
  Future<Map<String, dynamic>> getRecommendations(double? avgMoodScore) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay

    List<TherapyRecommendation> recommendedTherapies = [];
    // --- FIX: Return ALL therapists for the list view as well ---
    List<Therapist> recommendedTherapists = List.from(
      _allTherapists,
    ); // Use all therapists for the card list

    // --- Therapy recommendation logic (simplified example) ---
    if (avgMoodScore == null) {
      recommendedTherapies = _allTherapies.take(3).toList(); // fallback
    } else if (avgMoodScore <= 2) {
      recommendedTherapies = _allTherapies
          .where(
            (t) =>
                t.title.contains('Guided Meditation') ||
                t.title.contains('Positive Affirmations'),
          )
          .toList();
    } else if (avgMoodScore <= 4) {
      recommendedTherapies = _allTherapies
          .where(
            (t) =>
                t.title.contains('Mindful Walking') ||
                t.title.contains('Visualization Exercise'),
          )
          .toList();
    } else if (avgMoodScore <= 6) {
      recommendedTherapies = _allTherapies
          .where(
            (t) =>
                t.title.contains('Journal Prompts') ||
                t.title.contains('Box Breathing Exercise'),
          )
          .toList();
    } else if (avgMoodScore <= 8) {
      recommendedTherapies = _allTherapies
          .where(
            (t) =>
                t.title.contains('Physical Activity') ||
                t.title.contains('Cold Water Splash'),
          )
          .toList();
    } else {
      recommendedTherapies = _allTherapies
          .where(
            (t) =>
                t.title.contains('Uplifting Music') ||
                t.title.contains('Connect with a Friend'),
          )
          .toList();
    }
    // --- End Therapy recommendation logic ---

    // Pass ALL therapists for the map
    List<Therapist> nearbyTherapists = List.from(_allTherapists);

    return {
      'therapies': recommendedTherapies
          .take(3)
          .toList(), // Limit activities displayed if needed
      'therapists':
          recommendedTherapists, // Now contains all therapists for the list
      'nearby': nearbyTherapists, // Already contains all therapists for the map
    };
  }
}
