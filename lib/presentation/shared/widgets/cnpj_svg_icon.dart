import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders legacy SVG icons with consistent sizing and optional tint.
class CnpjSvgIcon extends StatelessWidget {
  const CnpjSvgIcon(
    this.asset, {
    super.key,
    this.width = 24,
    this.height = 24,
    this.color,
  });

  final String asset;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// White icon for purple CTA buttons (search, filter).
class CnpjButtonIcon extends StatelessWidget {
  const CnpjButtonIcon(this.asset, {super.key, this.size = 20});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CnpjSvgIcon(
      asset,
      width: size,
      height: size,
      color: Colors.white,
    );
  }
}
