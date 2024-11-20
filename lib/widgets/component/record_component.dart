
import 'package:flutter/material.dart';

class RecordComponent extends StatelessWidget {

  final RecordData data;
  final double? titleSize;
  final double? valueSize;

  const RecordComponent({super.key, required this.data, this.titleSize, this.valueSize});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(data.value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: valueSize ?? Theme.of(context).textTheme.displaySmall!.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4,),
        Text(data.title,
          style: TextStyle(
            fontSize: titleSize
          ),
        )
      ],
    );
  }
}

class RecordData {
  final String title;
  final String value;

  RecordData({required this.title, required this.value});
}
