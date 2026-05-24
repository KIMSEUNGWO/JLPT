import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';

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
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(AppRadius.md),
        color: backgroundColor ?? context.colors.surface,
        border: border,
        boxShadow: AppShadow.card(context.feedback),
      ),
      child: child,
    );
  }
}
