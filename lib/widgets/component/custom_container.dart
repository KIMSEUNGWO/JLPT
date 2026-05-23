import 'package:flutter/material.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';

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

  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.radius,
    this.child,
    this.padding,
    this.constraints,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(15),
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(12),
        color: backgroundColor ?? colorScheme.surface,
        border: border,
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}
