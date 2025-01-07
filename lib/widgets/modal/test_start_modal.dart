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
              ..._mounts.map((mount) {
                return SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      _select(mount);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _currentMount == mount
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
              }),
              const SizedBox(height: 16,),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TestPage<Word>(
                        type: widget.type,
                        level: widget.level,
                        mount: _currentMount,
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
