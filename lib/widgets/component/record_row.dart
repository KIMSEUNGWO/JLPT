

import 'package:flutter/material.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';

class RecordRow extends StatelessWidget {

  final List<RecordData> dataList;
  final double? titleSize;
  final double? valueSize;

  const RecordRow({super.key, required this.dataList, this.titleSize, this.valueSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: dataList.map((data) => Expanded(child: RecordComponent(data: data, titleSize: titleSize, valueSize: valueSize,))).toList(),
    );
  }
}
