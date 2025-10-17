import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:me_mpr/failure/call_recording_model.dart';

class CallFinderService {
  static const _lastCheckedKey = 'last_call_check_timestamp';
  // Note: This path is specific and might not work on all devices.
  final String _recordingsPath =
      '/storage/emulated/0/Music/Recordings/Call Recordings/';

  Future<List<CallRecording>> findNewCallRecordings() async {
    // 1. Check for storage permissions
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        // On Android 11+ you may need MANAGE_EXTERNAL_STORAGE, which is complex.
        // This basic permission may not be enough on newer OS versions.
        throw Exception(
          'Storage permission is required to find call recordings.',
        );
      }
    }

    // 2. Get the last time we checked for files
    final prefs = await SharedPreferences.getInstance();
    final lastCheckedMillis = prefs.getInt(_lastCheckedKey) ?? 0;
    final lastCheckedDate = DateTime.fromMillisecondsSinceEpoch(
      lastCheckedMillis,
    );

    // 3. Access the directory and find new files
    final directory = Directory(_recordingsPath);
    if (!await directory.exists()) {
      print('Call recording directory not found at $_recordingsPath');
      return []; // Directory doesn't exist
    }

    final List<CallRecording> newRecordings = [];
    final files = await directory.list().toList();

    for (var entity in files) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isAfter(lastCheckedDate)) {
          newRecordings.add(
            CallRecording(
              path: entity.path,
              name: entity.path.split('/').last,
              modified: stat.modified,
            ),
          );
        }
      }
    }

    // 4. Update the timestamp for the next time
    await prefs.setInt(_lastCheckedKey, DateTime.now().millisecondsSinceEpoch);

    // Sort by most recent first
    newRecordings.sort((a, b) => b.modified.compareTo(a.modified));
    return newRecordings;
  }
}
