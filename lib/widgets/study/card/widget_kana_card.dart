import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/component/audio_button.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';
import 'package:jlpt_app/widgets/component/speaker_tts.dart';

class KanaCardWidget extends ConsumerStatefulWidget {
  const KanaCardWidget({
    super.key,
    required this.word,
    required this.defaults,
    this.speaker,
  });

  final Word word;
  final StudyOptions defaults;
  final Speaker? speaker;

  @override
  ConsumerState<KanaCardWidget> createState() => _KanaCardWidgetState();
}

class _KanaCardWidgetState extends ConsumerState<KanaCardWidget> {
  late final Speaker _speaker;
  late final int _capturedWordId;

  @override
  void initState() {
    super.initState();
    _capturedWordId = widget.word.id;
    _speaker =
        widget.speaker ??
        SpeakerTTS(locale: ref.read(activeCourseProvider).ttsLocale);

    if (widget.defaults.autoPlayPronunciation) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted || widget.word.id != _capturedWordId) return;
        await _speaker.speak(widget.word.word);
      });
    }
  }

  @override
  void dispose() {
    unawaited(_speaker.stopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xl),
      child: CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          children: [
            Text(widget.word.word, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.word.meaning,
              style: context.text.displaySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AudioWaveAnimation(
              word: widget.word.word,
              title: '발음 듣기',
              speaker: _speaker,
            ),
          ],
        ),
      ),
    );
  }
}
