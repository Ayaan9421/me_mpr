import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(content)));
}

/// Returns the emoji corresponding to the depression score (1-10).
String getEmojiForDepressionScore(int score) {
  if (score <= 2) return '😌'; // Minimal depression
  if (score <= 4) return '😕'; // Mild depression
  if (score <= 6) return '🥺'; // Moderate depression
  if (score <= 8) return '😟'; // High depression
  return '😔'; // Severe depression
}

/// Returns a descriptive label corresponding to the depression score (1-10).
String getLabelForDepressionScore(int score) {
  if (score <= 2) return 'Minimal Depression';
  if (score <= 4) return 'Mild Depression';
  if (score <= 6) return 'Moderate Depression';
  if (score <= 8) return 'High Depression';
  return 'Severe Depression';
}

/// Returns a descriptive label for the average weekly mood.
String getWeeklyMoodLabel(double? averageScore) {
  if (averageScore == null) return 'No data yet';
  // Use the same mapping as the single score, rounding the average
  return getLabelForDepressionScore(averageScore.round());
}

// --- Contact Parsing and Launching Logic (with launch fix) ---
Map<String, String?> parseContactInfo(String contactString) {
  String? website;
  String? phone;
  final parts = contactString.split('/');

  for (var part in parts) {
    final trimmedPart = part.trim();
    if (trimmedPart.isEmpty) continue;

    // Basic check for phone number (allows optional +, spaces, hyphens, min 7 digits)
    if (RegExp(r'^\+?[\d\s-]{7,}$').hasMatch(trimmedPart)) {
      phone ??= trimmedPart; // Assign only if phone hasn't been found yet
    }
    // Basic check for website (contains '.', doesn't look like just numbers/symbols)
    else if (trimmedPart.contains('.') &&
        !RegExp(r'^[\d\s-]+$').hasMatch(trimmedPart)) {
      website ??= trimmedPart; // Assign only if website hasn't been found yet
    }
  }
  return {'website': website, 'phone': phone};
}

/// Safely attempts to launch a given URL string (web or phone).
Future<void> launchUniversalLink(String urlString) async {
  Uri? uri;
  String formattedUrl = urlString.trim();

  // Check if it looks like a phone number
  if (RegExp(
    r'^\+?[\d\s-]{7,}$',
  ).hasMatch(formattedUrl.replaceAll(RegExp(r'\D'), ''))) {
    uri = Uri.tryParse('tel:${formattedUrl.replaceAll(RegExp(r'\D'), '')}');
    print("Attempting to launch phone: $uri");
  }
  // Check if it looks like a web URL
  else if (formattedUrl.contains('.') && !formattedUrl.startsWith('http')) {
    // --- FIX: Reliably add https:// if scheme is missing ---
    uri = Uri.tryParse('https://$formattedUrl');
    print("Attempting to launch website (added https): $uri");
  }
  // Assume it's a correctly formatted URL already
  else {
    uri = Uri.tryParse(formattedUrl);
    print("Attempting to launch URL as is: $uri");
  }

  if (uri != null && await canLaunchUrl(uri)) {
    try {
      await launchUrl(uri);
    } catch (e) {
      print('Error launching $uri: $e');
      Fluttertoast.showToast(msg: 'Could not launch link: ${e.toString()}');
    }
  } else {
    print('Could not launch $urlString (URI: $uri)');
    Fluttertoast.showToast(msg: 'Could not launch: $urlString');
  }
}

void showContactOptions(BuildContext context, String contactInfo) {
  final contactParts = parseContactInfo(contactInfo);
  final website = contactParts['website'];
  final phone = contactParts['phone'];

  List<Widget> options = [];

  if (website != null) {
    options.add(
      ListTile(
        leading: const Icon(Icons.language_rounded),
        title: const Text('Open Website'),
        onTap: () {
          Navigator.pop(context);
          launchUniversalLink(website);
        },
      ),
    );
  }

  if (phone != null) {
    options.add(
      ListTile(
        leading: const Icon(Icons.phone_outlined),
        title: Text('Call $phone'),
        onTap: () {
          Navigator.pop(context);
          launchUniversalLink(phone);
        },
      ),
    );
  }

  if (options.isEmpty) {
    Fluttertoast.showToast(msg: "No valid contact information found.");
    return;
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(child: Wrap(children: options));
    },
  );
}
