import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/notifier/study_options_notifier.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';

/// 환경설정 화면 — 학습 카드의 노출/재생 정책을 관리한다.
///
/// 옵션은 [studyOptionsProvider] 의 단일 source 로 관리되고 변경 즉시
/// `LocalStorage` 에 저장되어 앱 재시작 후에도 유지된다. 학습 카드는
/// 이 설정을 watch 만 하고 자체 토글 UI 는 갖지 않는다.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opts = ref.watch(studyOptionsProvider);
    final notifier = ref.read(studyOptionsProvider.notifier);

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
                  value: opts.showKorean,
                  onChanged: notifier.toggleKorean,
                ),
                const _SettingDivider(),
                _SettingToggleRow(
                  icon: Icons.text_fields_rounded,
                  title: '히라가나 표시',
                  description: '단어 카드에 히라가나 발음을 먼저 보여줍니다',
                  value: opts.showHiragana,
                  onChanged: notifier.toggleHiragana,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: '발음',
              children: [
                _SettingToggleRow(
                  icon: Icons.volume_up_outlined,
                  title: '자동 발음',
                  description: '새 카드로 넘어가면 일본어 발음을 재생합니다',
                  value: opts.autoPlayPronunciation,
                  onChanged: notifier.toggleAutoPlay,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
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
