import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/notifier/startup_notifier.dart';
import 'package:jlpt_app/widgets/page_main.dart';
import 'package:jlpt_app/widgets/update_prompt.dart';

/// 앱 진입 게이트. `startupProvider` 가 완료될 때까지 [_SplashView] 를 보여주고,
/// 완료되면 [MainPage] 를, 실패하면 [_StartupErrorView] 를 보여준다.
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(startupProvider);
    return async.when(
      loading: () => const _SplashView(),
      error: (e, st) => _StartupErrorView(error: e),
      data: (report) => switch (report) {
        SyncReportFailed() => _StartupErrorView(error: report.error),
        SyncReportUpToDate() ||
        SyncReportSynced() =>
          const _MainWithUpdatePrompt(),
      },
    );
  }
}

class _MainWithUpdatePrompt extends StatelessWidget {
  const _MainWithUpdatePrompt();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        MainPage(),
        // 비차단 업데이트 안내. 데이터는 이미 정상 로드된 상태.
        UpdatePromptListener(),
      ],
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'JLPT GO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(color: color),
              const SizedBox(height: 16),
              const Text('데이터를 준비하는 중…'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupErrorView extends ConsumerWidget {
  const _StartupErrorView({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                '데이터를 불러오지 못했습니다',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(startupProvider.notifier).retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
