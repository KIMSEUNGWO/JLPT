

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/chart/Data.dart';
import 'package:vector_math/vector_math.dart' as math;

final pieColors = [
  Colors.blue,
  Colors.greenAccent,
  Colors.pinkAccent,
  Colors.deepOrangeAccent
];

class ArcData {
  final Color color;
  final Animation<double> sweepAngle;
  final double startAngle;

  ArcData({required this.color, required this.sweepAngle, required this.startAngle});

}

class GapPieChart extends StatefulWidget {

  final double radius;
  final double textSize;
  final double strokeWidth;
  final double scale;
  final List<Data> dataset;
  final double gapDegrees;

  const GapPieChart({
    super.key,
    this.radius = 100,
    this.textSize = 20,
    this.strokeWidth = 10,
    this.scale = 1,
    required this.dataset,
    required this.gapDegrees
});



  @override
  State<GapPieChart> createState() => _GapPieChartState();
}

class _GapPieChartState extends State<GapPieChart> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late List<ArcData> arcs;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1 * widget.dataset.length)
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn
    );

    final remainingDegrees = 360 - (widget.dataset.length * widget.gapDegrees);
    final total = widget.dataset.fold(0.0, (a, data) => a + data.value) / remainingDegrees;

    double currentSum = 0.0;
    arcs = widget.dataset.indexed.map((item) {
      final (index, data) = item;
      final startAngle = currentSum + (index * widget.gapDegrees);
      currentSum += data.value / total;
      final intervalGap = 1 / widget.dataset.length;
      return ArcData(
        color: pieColors[index],
        startAngle: -90 + startAngle,
        sweepAngle: Tween<double>(
          begin: 0,
          end: data.value / total
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * intervalGap,
            (index + 1) * intervalGap,
          ),
        ))
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
      ..strokeCap = StrokeCap.round
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
          math.radians(arc.startAngle),
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

