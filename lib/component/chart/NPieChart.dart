

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

class NPieChart extends StatefulWidget {

  final double radius;
  final int win;
  final int draw;
  final int loss;
  final double textSize;
  final double strokeWidth;
  final double scale;

  const NPieChart({super.key, required this.radius, required this.win, required this.draw, required this.loss, required this.textSize, required this.strokeWidth, this.scale = 1,});



  @override
  State<NPieChart> createState() => _NPieChartState();
}

class _NPieChartState extends State<NPieChart> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _win;
  late Animation<double> _draw;
  late Animation<double> _loss;

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

    final total = (widget.win + widget.draw + widget.loss) / 360;
    _win = Tween<double>(
      begin: 0,
      end: widget.win / total
    ).animate(curvedAnimation);
    _draw = Tween<double>(
      begin: 0,
      end: (widget.win + widget.draw) / total
    ).animate(curvedAnimation);
    _loss = Tween<double>(
      begin: 0,
      end: (widget.win + widget.draw + widget.loss) / total
    ).animate(curvedAnimation);

    print('_win.value : ${widget.win / total}');
    print('_win.value : ${_win.value}');
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
                winProgress: _win.value,
                drawProgress: _draw.value,
                lossProgress: _loss.value
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  VerticalStat(label: 'W', value: widget.win.toString(), textSize: 16),
                  VerticalStat(label: 'D', value: widget.win.toString(), textSize: 16),
                  VerticalStat(label: 'L', value: widget.win.toString(), textSize: 16),
                ],
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
  final double winProgress;
  final double drawProgress;
  final double lossProgress;

  _ProgressPainter({super.repaint, required this.strokeWidth, required this.winProgress, required this.drawProgress, required this.lossProgress});


  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint winPaint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

    Paint drawPaint = Paint()
        ..color = Colors.black38
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;


    Paint lossPaint = Paint()
      ..color = Colors.black26
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    print('winProgress : $winProgress');
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), // 기본값이 3시 방향이기때문에 우리는 12시 기준으로 바꾼것임
        math.radians(winProgress),
        false,
        winPaint
    );

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), // 기본값이 3시 방향이기때문에 우리는 12시 기준으로 바꾼것임
        math.radians(drawProgress),
        false,
        drawPaint
    );

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), // 기본값이 3시 방향이기때문에 우리는 12시 기준으로 바꾼것임
        math.radians(lossProgress),
        false,
        lossPaint
    );
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

