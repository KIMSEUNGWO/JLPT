
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {

  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;
  final BorderRadius? radius;
  final Color? backgroundColor;
  final BoxBorder? border;

  const CustomContainer({super.key, this.width, this.height, this.margin, this.radius, this.child, this.padding, this.constraints, this.backgroundColor, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(15),
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(12),
        color: backgroundColor ?? Colors.white,
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 4
          )
        ]
      ),
      child: child,
    );
  }
}
