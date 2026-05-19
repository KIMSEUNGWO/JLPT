import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/study_options_notifier.dart';
import 'package:jlpt_app/widgets/component/audio_button.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/speaker.dart';
import 'package:jlpt_app/widgets/component/speaker_tts.dart';
import 'package:jlpt_app/widgets/modal/report_problem.dart';
import 'package:jlpt_app/widgets/study/card/widget_word_card_detail.dart';

class WordCardWidget extends ConsumerStatefulWidget {
  final Word word;

  /// 테스트 hook — production 에서는 null (자체 [SpeakerTTS] 생성).
  final Speaker? speaker;

  const WordCardWidget({super.key, required this.word, this.speaker});

  @override
  ConsumerState<WordCardWidget> createState() => _WordCardWidgetState();
}

class _WordCardWidgetState extends ConsumerState<WordCardWidget> {
  late final Speaker _speaker;

  /// 비동기 자동 발음 콜백이 발화 직전에 비교할 word id.
  /// 같은 State 가 유지되며 word 만 바뀌는 경우까지 방어한다.
  late final int _capturedWordId;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _capturedWordId = widget.word.id;
    _speaker = widget.speaker ?? SpeakerTTS();

    // autoPlay 는 ref.read 로 initState 시점 1회만 캡처.
    // 학습 중에 토글을 ON 으로 바꿔도 *현재* 카드는 자동 재생하지 않는다
    // (예상치 못한 발화 방지). 다음 카드부터 적용.
    final opts = ref.read(studyOptionsProvider);
    if (opts.autoPlayPronunciation) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
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
    final opts = ref.watch(studyOptionsProvider);
    final optsNotifier = ref.read(studyOptionsProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      widget.word.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      opts.showHiragana ? widget.word.hiragana : '',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.displaySmall!.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opts.showKorean ? widget.word.korean : '',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.displaySmall!.fontSize,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AudioWaveAnimation(
                      word: widget.word.word,
                      title: '발음 듣기',
                      speaker: _speaker,
                    ),
                    _isOpen
                        ? const SizedBox(height: 31)
                        : const SizedBox(height: 10),
                    _isOpen
                        ? WordCardDetailWidget(word: widget.word)
                        : const SizedBox(),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
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
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '오류신고',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontSize: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .fontSize,
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
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OptionToggle(
                  label: '한국어',
                  isOn: opts.showKorean,
                  onTap: optsNotifier.toggleKorean,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionToggle(
                  label: '히라가나',
                  isOn: opts.showHiragana,
                  onTap: optsNotifier.toggleHiragana,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionToggle(
                  label: '🔊 자동',
                  isOn: opts.autoPlayPronunciation,
                  onTap: optsNotifier.toggleAutoPlay,
                ),
              ),
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
        backgroundColor:
            isOn ? Theme.of(context).colorScheme.primary : Colors.white,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
            color: isOn ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
