import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart'; // <-- Using the new package

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder(); // <-- New recorder instance
  String? _filePath;

  // We can't get decibels easily, but we can check if it's recording.
  Future<bool> isRecording() => _recorder.isRecording();

  Future<void> init() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<void> startRecording() async {
    await init(); // Ensure permissions are set

    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/voice_diary.wav';

    // Start recording using the 'record' package's syntax
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, // Use the WAV encoder
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _filePath!,
    );
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;

    // This returns the path where the file was saved.
    final path = await _recorder.stop();

    if (path == null) {
      print("Recorder stopped but file path is null.");
      return null;
    }

    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      print("Recorded file: $path (${size / 1024} KB)");

      // A valid WAV header is ~44 bytes. Only return if we have actual audio data.
      if (size > 1024) {
        // Check if file is larger than 1KB
        return path;
      } else {
        print("File is too small to be a valid recording. Discarding.");
        await file.delete(); // Clean up the invalid file
        return null;
      }
    }

    return null;
  }

  void dispose() {
    _recorder.dispose();
  }
}
