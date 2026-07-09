import 'package:flutter/material.dart';

abstract final class KeyboardUtils {
  static void dismiss(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
  }
}
