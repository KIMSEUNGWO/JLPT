import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

import 'package:jlpt_app/core/theme/theme_x.dart';

class PieChart extends StatefulWidget {
  final double radius;
  final double scale;
  final double strokeWidth;
  final double totalSize;
  final double currentSize;
  final Widget? child;

  const PieChart({
    super.key,
    this.radius = 100,
    this.scale = 1.0,
    this.strokeWidth = 20,
    this.child,
    required this.totalSize,
    required this.currentSize,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _current;

  void _updateAnimation() {
    final total = widget.totalSize / 360;
    if (total <= 0) return;  // 0으로 나누기 방지

    _current = Tween<double>(
        begin: _current.value,  // 현재 값에서 시작
        end: widget.currentSize / total
    ).animate(_controller);

    if (!_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // totalSize나 currentSize가 변경되었을 때만 애니메이션 업데이트
    if (oldWidget.totalSize != widget.totalSize ||
        oldWidget.currentSize != widget.currentSize) {
      _updateAnimation();
    }
  }

  Duration _calculateDuration() {

    int maxAnimation = 1000;
    // 백분율 계산 (0.0 ~ 1.0)
    double percentage = widget.currentSize / widget.totalSize;

    // 1000ms를 기준으로 duration 계산
    int duration = (percentage * maxAnimation).round();

    // 최소값과 최대값 제한
    return Duration(milliseconds: duration.clamp(500, maxAnimation));
  }
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: _calculateDuration()
    );

    final total = widget.totalSize / 360;
    _current = Tween<double>(
        begin: 0,
        end: widget.currentSize / total
    ).animate(_controller);

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
              painter: _ProgressBar(
                context: context,
                strokeWidth: widget.strokeWidth,
                currentProgress: _current.value,
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}


class _ProgressBar extends CustomPainter {

  final double strokeWidth;
  final BuildContext context;
  final double currentProgress;

  _ProgressBar({required this.strokeWidth, required this.context, required this.currentProgress});




  @override
  void paint(Canvas canvas, Size size) {

    Offset center = Offset(size.width / 2, size.height / 2);

    Paint defaultPaint = Paint()
      ..color = context.feedback.inactiveChart
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint currentPaint = Paint()
        ..color = context.colors.primary
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(360),
        false,
        defaultPaint
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      math.radians(-90),
      math.radians(currentProgress),
      false,
      currentPaint
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}