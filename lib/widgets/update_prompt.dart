import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/widgets/modal/update_modal.dart';

/// 부팅 게이트 통과 후 한 번 원격 업데이트 가능 여부를 조회하고,
/// 신버전이 있으면 모달을 띄운다. 데이터 sync는 이미 끝난 상태이므로 비차단.
class UpdatePromptListener extends ConsumerStatefulWidget {
  const UpdatePromptListener({super.key});

  @override
  ConsumerState<UpdatePromptListener> createState() =>
      _UpdatePromptListenerState();
}

class _UpdatePromptListenerState extends ConsumerState<UpdatePromptListener> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_checked) return;
    _checked = true;
    final plan = await ref.read(updateServiceProvider).checkForUpdate();
    if (!mounted || plan == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => UpdateModal(plan: plan),
    );
    // 적용이 성공했다면 wordsByLevelProvider 등이 invalidate 되도록 한다.
    ref.invalidate(wordsByLevelProvider);
    ref.invalidate(chineseCharCacheProvider);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
