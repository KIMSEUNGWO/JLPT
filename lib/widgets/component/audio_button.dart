import 'package:flutter/material.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';

import 'package:audioplayers/audioplayers.dart';

class AudioWaveAnimation extends StatefulWidget {
  final String? title;
  final String audioLink;
  const AudioWaveAnimation({super.key, this.title, required this.audioLink});

  @override
  State<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<AudioWaveAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  bool isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  playAudio() async {
    setState(() {
      isPlaying = true;
      _controller.repeat();
    });
    await _audioPlayer.play(AssetSource('audio/${widget.audioLink}'));
    return await _audioPlayer.getDuration();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      double startPoint = index * 0.125; // 0, 0.125, 0.25, 0.375
      double endPoint = 0.5 + (index * 0.125); // 0.5, 0.625, 0.75, 0.875

      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.3, end: 0.6),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.6, end: 0.3),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startPoint,
            endPoint,
            curve: Curves.easeInOut,
          ),
          reverseCurve: Interval(endPoint, startPoint)
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void togglePlaying() async {
    Duration? duration = await playAudio();
    if (duration != null) {
      Future.delayed(duration, () {
        setState(() {
          isPlaying = false;
          _controller.stop();
          _controller.reset();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlaying,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            radius: BorderRadius.circular(100),
            backgroundColor: isPlaying ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 25, // 고정 높이 설정
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Container(
                          width: 3,
                          height: _animations[index].value * 30,
                          decoration: BoxDecoration(
                            color: isPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (widget.title != null) ...[
                  const SizedBox(width: 8),
                  Text(widget.title!,
                    style: TextStyle(
                      color: isPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}