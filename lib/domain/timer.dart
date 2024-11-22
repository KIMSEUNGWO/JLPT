
import 'dart:async';

import 'package:flutter/material.dart';


class CustomTimer extends StatefulWidget {

  final TimerController? controller;
  final Function(int seconds) getSeconds;

  const CustomTimer({super.key, required this.getSeconds, this.controller});

  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {

  late Timer _timer;
  int _seconds = 0;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    },);
  }
  void timerStop() {
    _timer.cancel();
  }
  void restart() {
    start();
  }

  @override
  void initState() {
    start();
    widget.controller?.stop = timerStop;
    widget.controller?.restart = restart;
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    Future(() => widget.getSeconds(_seconds) );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(formatTime(_seconds),
      style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
          fontWeight: FontWeight.w500
      ),
    );
  }
}

String formatTime(int second) {
  int hours = second ~/ 3600;
  int minutes = (second % 3600) ~/ 60;
  int seconds = second % 60;
  if (hours == 0) return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class TimerController {

  late void Function() stop;
  late void Function() restart;
}