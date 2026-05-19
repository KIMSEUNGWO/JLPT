import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/notifier/study_options_notifier.dart';

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
      appBar: AppBar(
        title: const Text('환경설정'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader('학습 카드 표시'),
            SwitchListTile(
              title: const Text('한국어 매번 표시'),
              subtitle: const Text('카드에 항상 한국어 뜻을 보여줍니다.'),
              value: opts.showKorean,
              onChanged: (_) => notifier.toggleKorean(),
            ),
            SwitchListTile(
              title: const Text('히라가나 매번 표시'),
              subtitle: const Text('카드에 항상 히라가나 발음을 보여줍니다.'),
              value: opts.showHiragana,
              onChanged: (_) => notifier.toggleHiragana(),
            ),
            const Divider(height: 1),
            const _SectionHeader('발음'),
            SwitchListTile(
              title: const Text('자동 발음 듣기'),
              subtitle: const Text('새 카드가 열리면 자동으로 발음을 재생합니다.'),
              value: opts.autoPlayPronunciation,
              onChanged: (_) => notifier.toggleAutoPlay(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
