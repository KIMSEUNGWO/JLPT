
import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharWidget extends StatelessWidget {

  final ChineseChar char;

  const ChineseCharWidget({super.key, required this.char});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Text(char.char,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.displayLarge!.fontSize,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('음독 : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                Text(char.soundReading.isEmpty ? '-' : char.soundReading.join(' · '),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text('훈독 : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                Text(char.meanReading.isEmpty ? '-' : char.meanReading.join(' · '),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text('한국한자 : ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
                Text(char.koreanChar,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
