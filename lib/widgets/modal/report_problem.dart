import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/component/snack_bar.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/word.dart';

class ReportProblemModal extends StatefulWidget {

  final Word word;
  const ReportProblemModal({
    super.key,
    required this.word
  });

  @override
  State<ReportProblemModal> createState() => _ReportProblemModalState();
}

class _ReportProblemModalState extends State<ReportProblemModal> {

  late TextEditingController _textEditingController;
  bool _sending = false;

  static const String formURL = 'https://docs.google.com/forms/u/0/d/e/1FAIpQLSfCrIv1QF_QI3L7LQBrMXBVTClwKAPIJsMyUfOYc8nuTIcb5A/formResponse';

  _complete() {
    CustomSnackBar.instance.message(context, '오류 신고가 성공적으로 제출되었습니다');
    Navigator.pop(context);
  }
  _fail(int errorCode) {
    CustomSnackBar.instance.message(context, '오류 신고 제출에 실패했습니다 code : $errorCode');
    setState(() {
      _sending = false;
    });
  }
  _send() async {
    if (_sending) return;
    setState(() {
      _sending = true;
    });
    try {
      final response = await http.post(
        Uri.parse(formURL),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'entry.669046772': widget.word.toString(),
          'entry.2020093175': _textEditingController.text,
        },
      );

      if (response.statusCode == 200) {
        appLogger.d('오류 신고 제출 성공');
        _complete();
      } else {
        appLogger.w('오류 신고 제출 실패: ${response.statusCode}');
        _fail(response.statusCode);
      }
    } catch (e) {
      appLogger.e('오류 신고 제출 예외: $e');
      _fail(500);
    }
    setState(() {
      _sending = false;
    });
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: context.colors.secondary),
    );
    return Dialog(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.word.word,
                      style: context.text.displayMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.word.reading ?? '',
                          style: context.text.displaySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          widget.word.meaning,
                          style: context.text.displaySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _textEditingController,
                style: context.text.bodyLarge,
                decoration: InputDecoration(
                  border: inputBorder,
                  focusedBorder: inputBorder,
                  enabledBorder: inputBorder,
                  fillColor: context.colors.secondary,
                  filled: true,
                  hintText: '잘못된 내용을 적어주세요.',
                  hintStyle: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text(
                '1인 개발자로서 부족한점이 많습니다.\n도움을 주셔서 감사합니다.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _send,
                  style: TextButton.styleFrom(
                    backgroundColor: _sending
                        ? context.colors.surfaceContainerLowest
                        : context.colors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _sending
                      ? const CupertinoActivityIndicator()
                      : Text(
                          '보내기',
                          style: context.text.bodyLarge?.copyWith(
                            color: context.colors.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
