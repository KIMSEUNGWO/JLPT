import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jlpt_app/component/snack_bar.dart';
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
      // POST 요청 생성
      final response = await http.post(
        Uri.parse(formURL),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'entry.669046772': widget.word.toString(), // 오류 데이터
          'entry.2020093175': _textEditingController.text, // 사용자 설명
        },
      );

      if (response.statusCode == 200) {
        // 성공적으로 제출됨
        print('오류 신고가 성공적으로 제출되었습니다');
        _complete();
      } else {
        print('오류 신고 제출에 실패했습니다: ${response.statusCode}');
        _fail(response.statusCode);
      }
    } catch (e) {
      print('오류 발생: $e');
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    children: [
                      Text(widget.word.word,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.word.hiragana,
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8,),
                          Text(widget.word.korean,
                            style: TextStyle(
                                fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onPrimary
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _textEditingController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                  ),
                  decoration: InputDecoration(
                    border: _inputBorder,
                    focusedBorder: _inputBorder,
                    enabledBorder: _inputBorder,
                    fillColor: Color(0xFFF8F9FD),
                    filled: true,
                    hintText: '잘못된 내용을 적어주세요.',
                    hintStyle: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                    )
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 16),

                Text('1인 개발자로서 부족한점이 많습니다.\n도움을 주셔서 감사합니다.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _send,
                    style: TextButton.styleFrom(
                      backgroundColor: (_sending) ? const Color(0xFFF1F3F5) : Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (_sending)
                      ? CupertinoActivityIndicator()
                      : Text('보내기',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                          color: Colors.white,
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

final OutlineInputBorder _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(
    color: Color(0xFFF8F9FD)
  ),
);
