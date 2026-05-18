import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/study_session_notifier.dart';
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

  @override
  void initState() {
    super.initState();
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
            'JLPT ${widget.args.level.name} 단어 '
            '${widget.args.startIndex + 1}-${widget.args.endIndex}',
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  CustomTimer(
                    controller: _timerController,
                    getSeconds: _recordStudyTime,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
          shape: kAppBarShape,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: 60,
              child: CustomProgressBar(
                topWidget: (current, total, percent) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '진행률',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodySmall!.fontSize,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    Text(
                      '$current/$total',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodySmall!.fontSize,
                        color: Theme.of(context).colorScheme.primary,
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
                    key: ValueKey<int>(_currentIndex),
                    word: _innerWords[_currentIndex],
                  ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showNextCard,
                        child: CustomContainer(
                          height: 50,
                          backgroundColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.primary,
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '잘 모르겠음',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 21),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _innerWords.isEmpty
                            ? null
                            : _select(_innerWords[_currentIndex]),
                        child: CustomContainer(
                          height: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '이해했음',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.fontSize,
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
