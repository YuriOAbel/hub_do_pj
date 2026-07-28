import 'package:flutter/material.dart';

class AppTypography {
  static const double fontTitle = 16;
  static const double fontSubtitle = 14;
  static const double fontBody = 13;
  static const double fontDisplay = 24;

  static TextStyle title({Color? color, FontWeight? weight}) => TextStyle(
    fontSize: fontTitle,
    fontWeight: weight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle subtitle({Color? color}) => TextStyle(
    fontSize: fontSubtitle,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle caption({Color? color}) =>
      TextStyle(fontSize: fontBody, fontWeight: FontWeight.w400, color: color);

  static TextStyle navTitle({Color? color}) =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color);
}
