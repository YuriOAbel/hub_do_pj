import 'package:flutter/services.dart';

/// Formats input as Brazilian CNPJ: `00.000.000/0000-00`.
///
/// Accepts typed digits or pasted values with or without punctuation.
class CnpjInputFormatter extends TextInputFormatter {
  const CnpjInputFormatter();

  static const _maxDigits = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > _maxDigits
        ? digits.substring(0, _maxDigits)
        : digits;

    final formatted = _format(truncated);
    final digitOffset = _digitOffsetBeforeCursor(newValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _cursorOffset(formatted, digitOffset),
      ),
    );
  }

  static String _format(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static int _digitOffsetBeforeCursor(TextEditingValue value) {
    final limit = value.selection.baseOffset.clamp(0, value.text.length);
    var count = 0;
    for (var i = 0; i < limit; i++) {
      if (RegExp(r'\d').hasMatch(value.text[i])) count++;
    }
    return count;
  }

  static int _cursorOffset(String formatted, int digitOffset) {
    if (digitOffset <= 0) return 0;

    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsSeen++;
        if (digitsSeen >= digitOffset) return i + 1;
      }
    }
    return formatted.length;
  }
}
