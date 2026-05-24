import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/study_group_size.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';

class AppSettings {
  const AppSettings({
    this.studyOptions = const StudyOptions(),
    this.studyGroupSize = defaultStudyGroupSize,
  });

  final StudyOptions studyOptions;
  final int studyGroupSize;

  AppSettings copyWith({StudyOptions? studyOptions, int? studyGroupSize}) {
    return AppSettings(
      studyOptions: studyOptions ?? this.studyOptions,
      studyGroupSize: studyGroupSize ?? this.studyGroupSize,
    );
  }
}

/// 앱 전역 설정의 읽기 전용 facade.
///
/// 외부 화면/위젯은 이 provider 또는 아래 selector provider 들만 watch 한다.
/// 설정 변경은 이 파일 내부의 [SettingsPage] UI 를 통해서만 수행한다.
final settingsProvider = Provider<AppSettings>(
  (ref) => ref.watch(_settingsControllerProvider),
);

final studyOptionsProvider = Provider<StudyOptions>(
  (ref) =>
      ref.watch(settingsProvider.select((settings) => settings.studyOptions)),
);

final studyGroupSizeProvider = Provider<int>(
  (ref) =>
      ref.watch(settingsProvider.select((settings) => settings.studyGroupSize)),
);

@Riverpod(keepAlive: true)
class _SettingsController extends _$SettingsController {
  @override
  AppSettings build() {
    final storage = LocalStorage.instance;
    return AppSettings(
      studyOptions: storage.getStudyOptions(),
      studyGroupSize: storage.getStudyGroupSize(),
    );
  }

  void toggleAutoPlay() {
    _updateStudyOptions(
      state.studyOptions.copyWith(
        autoPlayPronunciation: !state.studyOptions.autoPlayPronunciation,
      ),
    );
  }

  void toggleReading() {
    _updateStudyOptions(
      state.studyOptions.copyWith(
        showReading: !state.studyOptions.showReading,
      ),
    );
  }

  void toggleMeaning() {
    _updateStudyOptions(
      state.studyOptions.copyWith(showMeaning: !state.studyOptions.showMeaning),
    );
  }

  void setGroupSize(int value) {
    if (!isAllowedStudyGroupSize(value) || state.studyGroupSize == value) {
      return;
    }
    state = state.copyWith(studyGroupSize: value);
    unawaited(_saveStudyGroupSize(value));
  }

  void _updateStudyOptions(StudyOptions next) {
    state = state.copyWith(studyOptions: next);
    unawaited(_saveStudyOptions(next));
  }

  Future<void> _saveStudyOptions(StudyOptions options) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKey.STUDY_OPTIONS.name,
      jsonEncode(options.toJson()),
    );
  }

  Future<void> _saveStudyGroupSize(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKey.STUDY_GROUP_SIZE.name, value);
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final opts = settings.studyOptions;
    final course = ref.watch(activeCourseProvider);
    final controller = ref.read(_settingsControllerProvider.notifier);
    final readingLabel = course.readingLabel;

    return Scaffold(
      appBar: AppBar(title: const Text('환경설정'), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 21),
          children: [
            _SettingsSection(
              title: '학습 카드',
              children: [
                _SettingToggleRow(
                  icon: Icons.translate_rounded,
                  title: '한국어 뜻 표시',
                  description: '단어 카드에 한국어 뜻을 먼저 보여줍니다',
                  value: opts.showMeaning,
                  onChanged: controller.toggleMeaning,
                ),
                // reading 이 없는 코스(예: 영어)는 토글을 숨긴다.
                if (readingLabel != null) ...[
                  const _SettingDivider(),
                  _SettingToggleRow(
                    icon: Icons.text_fields_rounded,
                    title: '$readingLabel 표시',
                    description: '단어 카드에 $readingLabel 발음을 먼저 보여줍니다',
                    value: opts.showReading,
                    onChanged: controller.toggleReading,
                  ),
                ],
                const _SettingDivider(),
                _StudyGroupSizeSelector(value: settings.studyGroupSize),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: '발음',
              children: [
                _SettingToggleRow(
                  icon: Icons.volume_up_outlined,
                  title: '자동 발음',
                  description: '새 카드로 넘어가면 ${course.termLanguageLabel} 발음을 재생합니다',
                  value: opts.autoPlayPronunciation,
                  onChanged: controller.toggleAutoPlay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomContainer(
          padding: EdgeInsets.zero,
          radius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  const _SettingToggleRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: value
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 46,
              height: 30,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch.adaptive(
                  value: value,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.35),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyGroupSizeSelector extends ConsumerWidget {
  const _StudyGroupSizeSelector({required this.value});

  final int value;

  Future<void> _showPicker(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(_settingsControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          '단어 묶음 크기',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Text(
          '한 묶음에 담을 단어 수를 선택하세요',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          for (final size in studyGroupSizeOptions)
            CupertinoActionSheetAction(
              isDefaultAction: size == value,
              onPressed: () {
                controller.setGroupSize(size);
                Navigator.pop(ctx);
              },
              child: Text(
                '$size개씩',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: size == value ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            '취소',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showPicker(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_module_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '단어 묶음',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '학습 리스트에서 한 묶음에 담을 단어 수를 정합니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$value개씩',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
