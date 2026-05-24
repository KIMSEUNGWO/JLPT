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
import 'package:jlpt_app/widgets/modal/report_problem.dart';
import 'package:jlpt_app/widgets/study/card/widget_word_card_detail.dart';

class WordCardWidget extends ConsumerStatefulWidget {
  final Word word;

  /// 학습 화면 진입 시점에 캡처된 옵션 스냅샷. 카드의 표시/자동발음 default 로
  /// 사용되며, 카드 내부의 토글은 이 값을 변경하지 않는다 (로컬 state 만 변경).
  final StudyOptions defaults;

  /// 테스트 hook — production 에서는 null (자체 [SpeakerTTS] 생성).
  final Speaker? speaker;

  const WordCardWidget({
    super.key,
    required this.word,
    required this.defaults,
    this.speaker,
  });

  @override
  ConsumerState<WordCardWidget> createState() => _WordCardWidgetState();
}

class _WordCardWidgetState extends ConsumerState<WordCardWidget> {
  late final Speaker _speaker;

  /// 비동기 자동 발음 콜백이 발화 직전에 비교할 word id.
  /// 같은 State 가 유지되며 word 만 바뀌는 경우까지 방어한다.
  late final int _capturedWordId;

  bool _isOpen = false;

  /// 카드별 로컬 표시 state. 진입 시 [WordCardWidget.defaults] 로 초기화되고,
  /// 카드 토글은 이 값만 바꾼다. 카드를 넘기면 새 State 가 생기며 default 로 리셋.
  late bool _showMeaning;
  late bool _showReading;

  @override
  void initState() {
    super.initState();
    _capturedWordId = widget.word.id;
    _speaker = widget.speaker ??
        SpeakerTTS(locale: ref.read(activeCourseProvider).ttsLocale);
    _showMeaning = widget.defaults.showMeaning;
    _showReading = widget.defaults.showReading;

    if (widget.defaults.autoPlayPronunciation) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // StudyPage 의 AnimatedSwitcher 전환(400ms)이 끝난 뒤 재생한다.
        // 이전 카드 dispose 의 TTS stop 이 새 카드 자동 발음을 끊는 것을 방지.
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted || widget.word.id != _capturedWordId) return;
        await _speaker.speak(widget.word.word);
      });
    }
  }

  @override
  void dispose() {
    // dispose 는 await 불가 → fire-and-forget.
    // SpeakerTTS 의 _initFuture null-guard 가 init 전/중/후 모두 안전 보장.
    unawaited(_speaker.stopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryStyle = context.text.displaySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Container(
      margin: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Stack(
            children: [
              CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Column(
                  children: [
                    Text(widget.word.word, style: context.text.headlineLarge),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _showReading ? (widget.word.reading ?? '') : '',
                      style: secondaryStyle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _showMeaning ? widget.word.meaning : '',
                      style: secondaryStyle,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AudioWaveAnimation(
                      word: widget.word.word,
                      title: '발음 듣기',
                      speaker: _speaker,
                    ),
                    SizedBox(
                      height: _isOpen ? AppSpacing.xxxl : AppSpacing.md,
                    ),
                    _isOpen
                        ? WordCardDetailWidget(word: widget.word)
                        : const SizedBox(),
                  ],
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ReportProblemModal(word: widget.word);
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        color: context.feedback.textTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '오류신고',
                        style: context.text.bodyMedium?.copyWith(
                          color: context.feedback.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isOpen = !_isOpen;
                      });
                    },
                    child: Container(
                      width: 60,
                      decoration: const BoxDecoration(),
                      child: Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_outlined,
                        color: context.feedback.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 카드별 로컬 표시 state. 설정값을 default 로 쓰고, 카드를 넘기면
          // 새 State 가 생성되어 default 로 다시 초기화된다. 설정값은 mutate 하지 않는다.
          Row(
            children: [
              Expanded(
                child: _OptionToggle(
                  label: '한국어',
                  isOn: _showMeaning,
                  onTap: () => setState(() => _showMeaning = !_showMeaning),
                ),
              ),
              // reading 이 있는 코스만 발음 표기 토글을 노출.
              if (ref.watch(activeCourseProvider).readingLabel != null) ...[
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: _OptionToggle(
                    label: ref.watch(activeCourseProvider).readingLabel!,
                    isOn: _showReading,
                    onTap: () => setState(() => _showReading = !_showReading),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionToggle extends StatelessWidget {
  const _OptionToggle({
    required this.label,
    required this.isOn,
    required this.onTap,
  });

  final String label;
  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        backgroundColor: isOn ? context.colors.primary : context.colors.surface,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isOn
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
