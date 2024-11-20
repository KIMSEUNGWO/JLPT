
import 'package:flutter/material.dart';

class TitleAndWidget extends StatelessWidget {

  final String title;
  final EdgeInsets? titlePadding;
  final Widget child;
  final TextStyle? textStyle;

  const TitleAndWidget({super.key, required this.title, this.titlePadding, this.textStyle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: titlePadding ?? const EdgeInsets.only(left: 5),
          child: Text(title,
            style: textStyle ?? TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary
            ),
          ),
        ),

        const SizedBox(height: 10,),

        child
      ],
    );
  }
}
