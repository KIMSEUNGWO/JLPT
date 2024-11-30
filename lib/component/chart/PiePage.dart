

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/chart/Data.dart';
import 'package:jlpt_app/component/chart/GapPieChart.dart';
import 'package:jlpt_app/component/chart/NPieChart2.dart';

class PiePage extends StatelessWidget {
  const PiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('테스트'),
      ),
      body: Center(
        child: GapPieChart(
          strokeWidth: 20,
          dataset: dataset,
          gapDegrees: 20,
        ),
      ),
    );
  }
}
