import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:me_mpr/utils/app_colors.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});
  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with SingleTickerProviderStateMixin {
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 7;
  static const int _exhaleSeconds = 8;
  static const int _totalCycles = 5; // Number of breath cycles

  int _currentCycle = 0;
  int _secondsInPhase = _inhaleSeconds;
  BreathPhase _currentPhase = BreathPhase.inhale;
  Timer? _timer;
  bool _isRunning = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // animation speed
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _getInstruction() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return 'Inhale...';
      case BreathPhase.hold:
        return 'Hold...';
      case BreathPhase.exhale:
        return 'Exhale...';
    }
  }

  Color _getIndicatorColor() {
    switch (_currentPhase) {
      case BreathPhase.inhale:
        return AppColors.success.withOpacity(0.7);
      case BreathPhase.hold:
        return AppColors.warning.withOpacity(0.7);
      case BreathPhase.exhale:
        return AppColors.primary.withOpacity(0.7);
    }
  }

  void _animatePhase() {
    _animationController.duration = Duration(
      seconds: _currentPhase == BreathPhase.inhale
          ? _inhaleSeconds
          : _currentPhase == BreathPhase.exhale
          ? _exhaleSeconds
          : _holdSeconds,
    );

    if (_currentPhase == BreathPhase.inhale) {
      _animationController.forward(from: 0);
    } else if (_currentPhase == BreathPhase.exhale) {
      _animationController.reverse(from: 1);
    } else {
      _animationController.stop();
    }
  }

  void _startExercise() {
    if (_isRunning) return;
    _resetExercise();
    setState(() => _isRunning = true);
    _animatePhase();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsInPhase--;
        if (_secondsInPhase < 0) {
          // Move to next phase
          switch (_currentPhase) {
            case BreathPhase.inhale:
              _currentPhase = BreathPhase.hold;
              _secondsInPhase = _holdSeconds - 1;
              break;
            case BreathPhase.hold:
              _currentPhase = BreathPhase.exhale;
              _secondsInPhase = _exhaleSeconds - 1;
              break;
            case BreathPhase.exhale:
              _currentPhase = BreathPhase.inhale;
              _secondsInPhase = _inhaleSeconds - 1;
              _currentCycle++;
              if (_currentCycle >= _totalCycles) {
                _stopExercise(completed: true);
                return;
              }
              break;
          }
          _animatePhase();
        }
      });
    });
  }

  void _stopExercise({bool completed = false}) {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isRunning = false);
      _animationController.stop();
      if (completed) {
        Fluttertoast.showToast(
          msg: "Breathing exercise complete! Feel calmer?",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  void _resetExercise() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _currentCycle = 0;
        _currentPhase = BreathPhase.inhale;
        _secondsInPhase = _inhaleSeconds;
        _isRunning = false;
      });
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Box Breathing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIndicatorColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _getIndicatorColor().withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _getInstruction(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isRunning
                    ? '${_secondsInPhase + 1}'
                    : 'Ready?', // Show countdown or Ready
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _isRunning ? 'Cycle ${_currentCycle + 1} of $_totalCycles' : '',
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              if (!_isRunning)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Exercise'),
                  onPressed: _startExercise,
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Exercise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () => _stopExercise(),
                ),
              const SizedBox(
                height: 10,
              ), // Show reset button if started but not running, or if completed
              if (_isRunning ||
                  (_currentCycle >= _totalCycles && !_isRunning) ||
                  _currentCycle > 0)
                TextButton(
                  onPressed: _resetExercise,
                  child: const Text('Reset'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
