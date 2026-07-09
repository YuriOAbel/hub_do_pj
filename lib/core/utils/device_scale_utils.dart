import 'package:flutter/material.dart';

class DeviceScaleUtils {
  static double getScaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 375) return 0.9;
    if (width > 600) return 1.45;
    return 1.0;
  }

  static double getMaxLimit(BuildContext context, double baseMax) {
    return baseMax * getScaleFactor(context);
  }

  static double adaptiveSize(BuildContext context, double base) {
    return base * getScaleFactor(context);
  }
}
