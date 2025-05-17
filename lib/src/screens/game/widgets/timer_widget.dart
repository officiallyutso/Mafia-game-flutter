import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int endTime;

  const TimerWidget({
    super.key,
    required this.endTime,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _calculateRemainingTime();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = widget.endTime - now;
    
    setState(() {
      _remainingSeconds = (remaining / 1000).ceil();
      if (_remainingSeconds < 0) {
        _remainingSeconds = 0;
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemainingTime();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = Colors.green;
    
    if (_remainingSeconds < 30) {
      timerColor = Colors.red;
    } else if (_remainingSeconds < 60) {
      timerColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: timerColor, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatTime(_remainingSeconds),
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}