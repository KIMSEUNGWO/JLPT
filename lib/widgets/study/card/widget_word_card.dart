
import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/component/audio_button.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/study/card/widget_word_card_detail.dart';

class WordCardWidget extends StatefulWidget {

  final Word word;
  const WordCardWidget({super.key, required this.word});

  @override
  State<WordCardWidget> createState() => _WordCardWidgetState();
}

class _WordCardWidgetState extends State<WordCardWidget> with TickerProviderStateMixin {

  bool _toggleHiragana = false;
  bool _toggleKorean = false;

  bool _isOpen = false;

  _setToggleHiragana() {
    setState(() {
      _toggleHiragana = !_toggleHiragana;
    });

  }

  _setToggleKorean() {
    setState(() {
      _toggleKorean = !_toggleKorean;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CustomContainer(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      widget.word.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 12,),
                    Text(_toggleHiragana ? widget.word.hiragana : '',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8,),
                    Text(_toggleKorean ? widget.word.korean : '',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                    const SizedBox(height: 26,),
                    const AudioWaveAnimation(audioLink: '23487.mp3', title: '발음 듣기',),
                    _isOpen ? const SizedBox(height: 31,) : const SizedBox(height: 10,),
                    _isOpen ? WordCardDetailWidget(word: widget.word) : const SizedBox(),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0, right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isOpen = !_isOpen;
                      });
                    },
                    child: Container(
                      width: 60,
                      decoration: const BoxDecoration(),
                      child: Icon(_isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_outlined,
                        color: Theme.of(context).colorScheme.onTertiary,
                      )
                    ),
                  ),
                ),
              )
            ]
          ),
          const SizedBox(height: 16,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                    onTap: _setToggleKorean,
                    child: CustomContainer(
                      backgroundColor: _toggleKorean ? Theme.of(context).colorScheme.primary : Colors.white,
                      child: Text('한국어',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                          color: _toggleKorean ? Colors.white : null,
                        ),
                      ),
                    )
                ),
              ),
              const SizedBox(width: 21,),
              Expanded(
                child: GestureDetector(
                  onTap: _setToggleHiragana,
                  child: CustomContainer(
                    backgroundColor: _toggleHiragana ? Theme.of(context).colorScheme.primary : Colors.white,
                    child: Text('히라가나',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        color: _toggleHiragana ? Colors.white : null,
                      ),
                    ),
                  )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
