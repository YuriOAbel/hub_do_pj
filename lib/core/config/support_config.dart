import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Support contact from `.env` (flutter_dotenv).
class SupportConfig {
  SupportConfig._();

  static String get phone =>
      dotenv.env['SUPPORT_WHATSAPP_PHONE']?.trim() ?? '';

  static String get email => dotenv.env['SUPPORT_EMAIL']?.trim() ?? '';

  static String get phoneDigits => phone.replaceAll(RegExp(r'\D'), '');

  static bool get hasEmail => email.isNotEmpty;

  static String? get mailtoUrl {
    final value = email;
    if (value.isEmpty) return null;
    return Uri(
      scheme: 'mailto',
      path: value,
    ).toString();
  }

  static String? get whatsappUrl {
    final digits = phoneDigits;
    if (digits.isEmpty) return null;
    return 'https://wa.me/$digits';
  }

  static String whatsappUrlWithText(String text) {
    final digits = phoneDigits;
    if (digits.isEmpty) return '';
    return Uri.https('wa.me', '/$digits', {
      if (text.isNotEmpty) 'text': text,
    }).toString();
  }
}
