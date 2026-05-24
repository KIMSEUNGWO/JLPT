import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';

class TestStartModal extends StatefulWidget {

  final PracticeType type;
  final Level? level;
  const TestStartModal({
    super.key,
    required this.type,
    required this.level
  });

  @override
  State<TestStartModal> createState() => _TestStartModalState();
}

class _TestStartModalState extends State<TestStartModal> {

  final List<int> _mounts = [
    25, 50, 75, 100
  ];
  late int _currentMount;

  _select(int mount) {
    setState(() {
      _currentMount = mount;
    });
  }
  @override
  void initState() {
    _currentMount = _mounts[0];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('단어 테스트를 시작하시겠습니까?'),
            const SizedBox(height: AppSpacing.md),
            ..._mounts.map((mount) {
              final selected = _currentMount == mount;
              return SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _select(mount);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selected
                        ? context.colors.primaryContainer
                        : context.colors.surfaceContainerHigh,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    '$mount 문제',
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 모달 닫기
                  context.push(
                    AppRoutes.test,
                    extra: TestArgs(
                      type: widget.type,
                      level: widget.level,
                      mount: _currentMount,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  '테스트 시작',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
