import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';
import 'package:jlpt_app/widgets/component/speaker_tts.dart';

class AudioWaveAnimation extends ConsumerStatefulWidget {
  final String? title;
  final String word;

  /// 외부에서 [Speaker] 를 주입하면 그 인스턴스를 공유 (예: WordCardWidget 의
  /// 자동 발음용 speaker 와 동일). null 이면 자체 생성하고 lifecycle 도 자체 관리.
  final Speaker? speaker;

  /// 카드 메인 발음 버튼 대비 인라인용으로 한 단계 더 작은 사이즈 — 예문 row 옆 등.
  final bool compact;

  const AudioWaveAnimation({
    super.key,
    this.title,
    required this.word,
    this.speaker,
    this.compact = false,
  });

  @override
  ConsumerState<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends ConsumerState<AudioWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late final Speaker _speaker;

  bool isPlaying = false;

  bool get _ownsSpeaker => widget.speaker == null;

  Future<void> play() async {
    if (isPlaying) return;
    setState(() => isPlaying = true);
    unawaited(_controller.repeat());
    await _speaker.speak(widget.word);
  }

  Future<void> _initSpeaker() async {
    await _speaker.init(
      completionHandler: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => isPlaying = false);
            _controller.reset();
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _speaker = widget.speaker ??
        SpeakerTTS(locale: ref.read(activeCourseProvider).ttsLocale);
    // init() 은 idempotent (SpeakerTTS 가 `_initFuture ??= ...` 로 가드).
    // 첫 호출자가 completionHandler 를 등록하므로 AudioWaveAnimation 이 항상
    // 먼저 init 하면 자체 애니메이션 종료 콜백이 보장된다.
    unawaited(_initSpeaker());
    _controller = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      double startPoint = index * 0.125;
      double endPoint = 0.5 + (index * 0.125);

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
          curve: Interval(startPoint, endPoint, curve: Curves.easeInOut),
          reverseCurve: Interval(endPoint, startPoint),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsSpeaker) {
      unawaited(_speaker.stopped());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final padding = compact
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          );
    final waveHeight = compact ? 16.0 : 25.0;
    final barWidth = compact ? 2.0 : 3.0;
    final barMaxHeight = compact ? 18.0 : 30.0;
    final barHPad = compact ? 1.0 : 1.5;
    final activeBarColor = context.colors.onPrimary;
    final idleBarColor = context.colors.primary;

    return GestureDetector(
      onTap: play,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomContainer(
            padding: padding,
            radius: BorderRadius.circular(100),
            backgroundColor: isPlaying
                ? context.colors.primary
                : context.colors.secondary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: waveHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: barHPad),
                        child: Container(
                          width: barWidth,
                          height: _animations[index].value * barMaxHeight,
                          decoration: BoxDecoration(
                            color: isPlaying ? activeBarColor : idleBarColor,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (widget.title != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.title!,
                    style: context.text.bodyMedium?.copyWith(
                      color: isPlaying ? activeBarColor : idleBarColor,
                      fontWeight: FontWeight.w500,
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
