import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:me_mpr/utils/app_colors.dart';

class MeditationTimerPage extends StatefulWidget {
  const MeditationTimerPage({super.key});

  @override
  State<MeditationTimerPage> createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends State<MeditationTimerPage> {
  static const int _initialDurationSeconds = 5 * 60; // 5 minutes
  int _remainingSeconds = _initialDurationSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _remainingSeconds == 0) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        _stopTimer(completed: true);
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _initialDurationSeconds;
      _isRunning = false;
    });
  }

  void _stopTimer({bool completed = false}) {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isRunning = false);
      if (completed) {
        // Simple completion feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meditation complete! Well done.'),
            backgroundColor: AppColors.success,
          ),
        );
        // TODO: Add gamification logic here (e.g., mark as completed)
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_remainingSeconds / _initialDurationSeconds);

    return Scaffold(
      appBar: AppBar(title: const Text('Guided Meditation Timer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        _formatDuration(_remainingSeconds),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Start/Pause Button
                  FloatingActionButton.large(
                    heroTag: 'start_pause_fab',
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  ),
                  const SizedBox(width: 24),
                  // Reset Button (only show if not initial state)
                  if (_remainingSeconds != _initialDurationSeconds ||
                      _isRunning)
                    FloatingActionButton(
                      heroTag: 'reset_fab',
                      backgroundColor: AppColors.secondaryText.withOpacity(0.5),
                      onPressed: _resetTimer,
                      child: const Icon(Icons.replay),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (!_isRunning && _remainingSeconds == 0)
                ElevatedButton(
                  onPressed: () {
                    _resetTimer(); // Reset after acknowledging completion
                    Fluttertoast.showToast(
                      msg: "Meditation complete! Well done.",
                      toastLength:
                          Toast.LENGTH_LONG, // Longer duration for completion
                      gravity: ToastGravity.CENTER,
                      backgroundColor: AppColors.success,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Complete & Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
