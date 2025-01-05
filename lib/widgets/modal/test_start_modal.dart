import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jlpt_app/component/snack_bar.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/study/test/test_page.dart';

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

  bool _loading = false;
  final List<int> _mounts = [
    25, 50, 75, 100
  ];
  int _currentIndex = 0;

  _select(int mount) {
    setState(() {
      _currentIndex = mount;
    });
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('단어 테스트를 시작하시겠습니까?'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // 2열
                  crossAxisSpacing: 8, // 가로 간격
                  mainAxisSpacing: 8, // 세로 간격
                  mainAxisExtent: 45, // 각 항목의 높이
                ),
                itemCount: _mounts.length,
                itemBuilder: (context, index) {
                  int mount = _mounts[index];
                  return SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _select(index);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _currentIndex == index
                            ? Color(0xFFEAEAFF)
                            : Color(0xFFF9FAFD),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('$mount 문제',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16,),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TestPage<Word>(
                        type: widget.type,
                        level: widget.level,
                        mount: _mounts[_currentIndex],
                      );
                    },));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (_loading)
                    ? CupertinoActivityIndicator()
                    : Text('테스트 시작',
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
    );
  }
}

final OutlineInputBorder _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(
    color: Color(0xFFF8F9FD)
  ),
);
