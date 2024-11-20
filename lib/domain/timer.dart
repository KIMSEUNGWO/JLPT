
import 'dart:async';

import 'package:flutter/material.dart';


class CustomTimer extends StatefulWidget {

  final Function(int seconds) getSeconds;

  const CustomTimer({super.key, required this.getSeconds});

  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {

  late final Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    },);
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