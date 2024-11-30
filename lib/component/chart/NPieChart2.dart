

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/chart/Data.dart';
import 'package:vector_math/vector_math.dart' as math;

final pieColors = [
  Colors.black,
  Colors.black38,
  Colors.black26,
  Colors.black12
];

class ArcData {
  final Color color;
  final Animation<double> sweepAngle;

  ArcData({required this.color, required this.sweepAngle});
}

class NPieChart2 extends StatefulWidget {

  final double radius;
  final double textSize;
  final double strokeWidth;
  final double scale;
  final List<Data> dataset;

  const NPieChart2({super.key, required this.radius, required this.textSize, required this.strokeWidth, this.scale = 1, required this.dataset,});



  @override
  State<NPieChart2> createState() => _NPieChart2State();
}

class _NPieChart2State extends State<NPieChart2> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late List<ArcData> arcs;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4)
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn
    );

    final total = widget.dataset.fold(0.0, (a, data) => a + data.value) / 360;

    double currentSum = 0.0;
    arcs = widget.dataset.indexed.map((item) {
      final (index, data) = item;
      currentSum += data.value;
      return ArcData(
        color: pieColors[index],
        sweepAngle: Tween<double>(
          begin: 0,
          end: currentSum / total
        ).animate(curvedAnimation)
      );
    }).toList();

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale,
      child: SizedBox.fromSize(
        size: Size.fromRadius(widget.radius),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ProgressPainter(
                strokeWidth: widget.strokeWidth,
                arcs: arcs,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {

  final double strokeWidth;
  final List<ArcData> arcs;

  List<Paint> get paints => arcs.map((arc) {
    return Paint()
      ..color = arc.color
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }).toList();

  _ProgressPainter({super.repaint, required this.strokeWidth, required this.arcs});


  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    arcs.indexed.map((item) {
      final (index, arc) = item;
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: size.width / 2),
          math.radians(-90), // 기본값이 3시 방향이기때문에 우리는 12시 기준으로 바꾼것임
          math.radians(arc.sweepAngle.value),
          false,
          paints[index]
      );
    }).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class VerticalStat extends StatelessWidget {

  final String label;
  final String value;
  final double textSize;

  const VerticalStat({super.key, required this.label, required this.value, required this.textSize});


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          style: TextStyle(fontSize: textSize),
        ),
        Text(value,
          style: TextStyle(fontSize: textSize),
        ),
      ],
    );
  }
}

