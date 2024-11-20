import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {

  final SvgPicture svgPicture;

  const SvgIcon.privateConstructor(this.svgPicture, {super.key});

  static SvgIcon asset({required SIcon sIcon, SvgIconStyle? style,}) {
    return _SvgIconBuilder(sIcon: sIcon).build(style);
  }

  @override
  Widget build(BuildContext context) {
    return svgPicture;
  }

}

class SvgIconStyle {

  double? width;
  double? height;
  Color? color;
  BoxFit? fit;
  BlendMode? blendMode;

  SvgIconStyle({this.width, this.height, this.color, this.fit, this.blendMode});

}

class SIcon {

  final String picture;
  final double width;
  final double height;

  const SIcon({required this.picture, required this.width, required this.height});

  static const SIcon circleCheck = SIcon(picture: 'assets/icons/circle_check.svg', width: 24, height: 24);

}

class _SvgIconBuilder {

  final SIcon sIcon;

  _SvgIconBuilder({required this.sIcon});

  SvgIcon build(SvgIconStyle? style) {
    return SvgIcon.privateConstructor(SvgPicture.asset(sIcon.picture,
        width: style?.width ?? sIcon.width,
        height: style?.height ?? sIcon.height,
        fit: style?.fit ?? BoxFit.contain,
        colorFilter: style == null || style.color == null ? null : ColorFilter.mode(style.color!, style.blendMode ?? BlendMode.srcIn),
    ));
  }

}