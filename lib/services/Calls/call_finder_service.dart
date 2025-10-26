import 'dart:io';
import 'package:me_mpr/models/call_analysis_model.dart';
import 'package:me_mpr/models/call_recording_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A custom exception to signal that the directory hasn't been set yet.
class DirectoryNotSetException implements Exception {
  final String message =
      "Call recording directory has not been selected by the user.";
  @override
  String toString() => message;
}

class CallFinderService {
  static const _lastCheckedKey = 'last_call_check_timestamp';
  static const _directoryPathKey = 'call_directory_path';

  /// Prompts the user to select their call recording directory after checking permissions.
  /// Returns true if a directory was successfully selected and saved.
  Future<bool> selectAndSaveDirectory() async {
    // 1. Request permission right before showing the picker.
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        throw Exception(
          'Storage permission is required to select a directory.',
        );
      }
    }

    // 2. Show the directory picker.
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_directoryPathKey, directoryPath);
      print("Saved call recording directory: $directoryPath");
      return true;
    }
    return false;
  }

  Future<List<CallRecording>> findNewCallRecordings() async {
    // Get the saved directory path from SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final directoryPath = prefs.getString(_directoryPathKey);

    // If the path is null, throw our custom exception to tell the UI to ask the user.
    if (directoryPath == null) {
      throw DirectoryNotSetException();
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      print('Saved call recording directory not found at $directoryPath');
      // The saved directory might have been deleted. Ask the user again.
      throw DirectoryNotSetException();
    }

    // Get the last time we checked for files.
    final lastCheckedMillis = prefs.getInt(_lastCheckedKey) ?? 0;
    final lastCheckedDate = DateTime.fromMillisecondsSinceEpoch(
      lastCheckedMillis,
    );

    // Access the directory and find new files.
    final List<CallRecording> newRecordings = [];
    final files = await directory.list().toList();

    for (var entity in files) {
      if (entity is File) {
        // Simple check for common audio extensions
        final path = entity.path.toLowerCase();
        if (path.endsWith('.wav') ||
            path.endsWith('.m4a') ||
            path.endsWith('.mp3') ||
            path.endsWith('.amr')) {
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
    }

    // Update the timestamp for the next time we check.
    await prefs.setInt(_lastCheckedKey, DateTime.now().millisecondsSinceEpoch);

    newRecordings.sort((a, b) => b.modified.compareTo(a.modified));
    return newRecordings;
  }

  Future<List<CallRecording>> findAllUnanalyzedCalls(
    List<CallAnalysis> existingAnalyses,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final directoryPath = prefs.getString(_directoryPathKey);
    if (directoryPath == null) throw DirectoryNotSetException();

    final directory = Directory(directoryPath);
    if (!await directory.exists()) throw DirectoryNotSetException();

    final List<CallRecording> unanalyzedRecordings = [];
    final files = await directory.list().toList();
    final analyzedFileNames = existingAnalyses.map((a) => a.fileName).toSet();

    for (var entity in files) {
      if (entity is File) {
        final path = entity.path.toLowerCase();
        final fileName = entity.path.split('/').last;

        if ((path.endsWith('.wav') ||
                path.endsWith('.m4a') ||
                path.endsWith('.mp3') ||
                path.endsWith('.amr')) &&
            !analyzedFileNames.contains(fileName)) {
          // Check if NOT already analyzed
          final stat = await entity.stat();
          unanalyzedRecordings.add(
            CallRecording(
              path: entity.path,
              name: fileName,
              modified: stat.modified,
            ),
          );
        }
      }
    }
    unanalyzedRecordings.sort((a, b) => b.modified.compareTo(a.modified));
    return unanalyzedRecordings;
  }
}
