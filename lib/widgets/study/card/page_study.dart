import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/study_session_notifier.dart';
import 'package:jlpt_app/settings/settings.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/modal/next_modal.dart';
import 'package:jlpt_app/widgets/study/card/widget_word_card.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key, required this.args});
  final StudyGroupArgs args;

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  final TimerController _timerController = TimerController();

  late List<Word> _allWords; // 이 그룹 전체 단어 (불변)
  late List<Word> _innerWords; // 현재 라운드에 보여줄 셔플된 단어
  final Set<int> _readIds = {}; // 이번 페이지 진입 후 읽음 처리한 id들
  late bool _initiallyCompleted;
  int _currentIndex = 0;
  bool _recordedTime = false;

  /// 학습 화면 진입 시점의 옵션 스냅샷. 카드 화면에서는 설정을 변경할 수
  /// 없으므로 watch 가 아닌 read 로 1회만 캡처하여 자식 카드에 전달한다.
  late final StudyOptions _options;

  /// 카드 key 에 포함시켜 라운드 재시작 시에도 [WordCardWidget] 인스턴스가
  /// 새로 생성되도록 강제 (자동 발음은 initState 시점 트리거).
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _options = ref.read(studyOptionsProvider);
    final all = ref
        .read(wordsByLevelProvider)
        .maybeWhen(
          data: (m) => m[widget.args.level] ?? const <Word>[],
          orElse: () => const <Word>[],
        );
    _allWords = all.sublist(
      widget.args.startIndex,
      widget.args.endIndex.clamp(0, all.length),
    );
    _initiallyCompleted = _allWords.every((w) => w.isRead);
    _innerWords = _pickUnread();
  }

  List<Word> _pickUnread() {
    _round++;
    final unread = _allWords.where((w) => !_isRead(w)).toList();
    final pool = unread.isEmpty ? _allWords : unread;
    return [...pool]..shuffle();
  }

  bool _isRead(Word w) => w.isRead || _readIds.contains(w.id);

  bool _hasAllRead() => _allWords.every(_isRead);

  void _recordStudyTime([int? seconds]) {
    if (_recordedTime) return;
    final elapsed = seconds ?? _timerController.getTime();
    if (elapsed <= 0) return;
    _recordedTime = true;
    ref
        .read(studySessionProvider.notifier)
        .recordSeconds(widget.args.level, elapsed);
  }

  Future<void> _select(Word word) async {
    setState(() => _readIds.add(word.id));
    await ref.read(studySessionProvider.notifier).markWordRead(word.id);
    _showNextCard();
  }

  void _popAfterRecording() {
    _recordStudyTime();
    Navigator.of(context).pop();
  }

  void _showNextCard() {
    if (_currentIndex < _innerWords.length - 1) {
      setState(() => _currentIndex++);
      return;
    }
    if (_initiallyCompleted || !_hasAllRead()) {
      setState(() {
        _innerWords = _pickUnread();
        _currentIndex = 0;
      });
      return;
    }
    _recordStudyTime();
    _timerController.stop();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NextModal(
        wordsLearned: _allWords.length,
        studyHours: 2.5,
        onNextLevelTap: () {
          Navigator.of(ctx).pop();
          _popAfterRecording();
        },
        onViewTestTap: () {
          _timerController.restart();
          Navigator.of(ctx).pop();
          setState(() {
            _initiallyCompleted = true;
            _round++;
            _innerWords = [..._allWords]..shuffle();
            _currentIndex = 0;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep the autoDispose notifier alive while this page is mounted.
    ref.watch(studySessionProvider);
    final course = ref.watch(activeCourseProvider);
    final readCount = _allWords.where(_isRead).length;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popAfterRecording();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${course.displayName} ${widget.args.level.label} 단어 '
            '${widget.args.startIndex + 1}-${widget.args.endIndex}',
          ),
          centerTitle: false,
          backgroundColor: context.colors.surface,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: context.colors.primary, size: 12),
                  const SizedBox(width: AppSpacing.xs),
                  CustomTimer(
                    controller: _timerController,
                    getSeconds: _recordStudyTime,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              height: 60,
              child: CustomProgressBar(
                topWidget: (current, total, percent) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '진행률',
                      style: context.text.bodySmall?.copyWith(
                        color: context.feedback.textTertiary,
                      ),
                    ),
                    Text(
                      '$current/$total',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                current: readCount,
                total: _allWords.length,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
            child: _innerWords.isEmpty
                ? const SizedBox.shrink()
                : WordCardWidget(
                    key: ValueKey<String>(
                      '${widget.args.level.code}-'
                      '${_innerWords[_currentIndex].id}-'
                      '$_currentIndex-$_round',
                    ),
                    word: _innerWords[_currentIndex],
                    defaults: _options,
                  ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showNextCard,
                        child: CustomContainer(
                          height: 50,
                          backgroundColor: context.colors.surface,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                color: context.colors.primary,
                                size: 15,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '잘 모르겠음',
                                style: context.text.bodyLarge?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _innerWords.isEmpty
                            ? null
                            : _select(_innerWords[_currentIndex]),
                        child: CustomContainer(
                          height: 50,
                          backgroundColor: context.colors.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: context.colors.onPrimary,
                                size: 15,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '이해했음',
                                style: context.text.bodyLarge?.copyWith(
                                  color: context.colors.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SimpleBannerAd(width: double.infinity, height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
