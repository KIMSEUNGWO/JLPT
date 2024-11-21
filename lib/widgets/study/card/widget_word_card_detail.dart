
import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';
import 'package:jlpt_app/widgets/study/card/widget_chinese_char.dart';

class WordCardDetailWidget extends StatefulWidget {

  final Word word;

  const WordCardDetailWidget({super.key, required this.word});

  @override
  State<WordCardDetailWidget> createState() => _WordCardDetailWidgetState();
}

class _WordCardDetailWidgetState extends State<WordCardDetailWidget> {

  late final List<ChineseChar> chineseChars;

  @override
  void initState() {
    chineseChars = ChineseCharController.instance.findChars(widget.word.word);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 21),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Column(
        children: [
          (chineseChars.isNotEmpty) ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('한자 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize
                  ),
                ),
                const SizedBox(height: 12,),
                ...ChineseCharController.instance.toWidget(chineseChars, (char) => ChineseCharWidget(char: char),),
              ],
            ) :
            Text('한자 정보가 없습니다.'),
        ],
      ),
    );
  }
}
