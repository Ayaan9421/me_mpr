import 'dart:async';
import 'package:flutter/material.dart';
import 'package:me_mpr/services/Daily%20Diary/audio_recorder_service.dart';
import 'package:me_mpr/utils/app_colors.dart';

class VoiceRecorderView extends StatefulWidget {
  final AudioRecorderService recorderService;

  const VoiceRecorderView({super.key, required this.recorderService});

  @override
  State<VoiceRecorderView> createState() => _VoiceRecorderViewState();
}

class _VoiceRecorderViewState extends State<VoiceRecorderView>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _duration = Duration.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startRecording();
  }

  void _startRecording() async {
    try {
      await widget.recorderService.startRecording();
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not start recording: $e')));
    }
  }

  void _stopRecordingAndSubmit() async {
    _timer?.cancel();
    final filePath = await widget.recorderService.stopRecording();
    if (mounted && filePath != null) {
      Navigator.of(context).pop(filePath);
    } else if (mounted) {
      // Handle cases where the recording was too short
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording was too short. Please try again.'),
        ),
      );
      Navigator.of(context).pop(); // Close the modal
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    // Ensure recording is stopped if the user dismisses the modal
    widget.recorderService.stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recording...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // Pulsing recording icon
          FadeTransition(
            opacity: _animationController,
            child: const Icon(Icons.mic, color: AppColors.error, size: 80),
          ),
          const SizedBox(height: 20),
          Text(
            _formatDuration(_duration),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 30),
          FloatingActionButton.large(
            onPressed: _stopRecordingAndSubmit,
            backgroundColor: AppColors.error,
            child: const Icon(Icons.stop, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 10),
          const Text('Tap to Stop & Analyze'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
