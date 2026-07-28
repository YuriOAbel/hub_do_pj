import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Store / compliance URLs from `.env` (flutter_dotenv).
class LegalUrls {
  LegalUrls._();

  /// Published privacy policy URL (must match App Store Connect).
  static String get privacyPolicy =>
      dotenv.env['LEGAL_PRIVACY_URL']?.trim() ?? '';

  /// Published terms of use URL.
  static String get termsOfService =>
      dotenv.env['LEGAL_TERMS_URL']?.trim() ?? '';

  static const receitaFederal = 'https://www.gov.br/receitafederal';

  static bool get hasPrivacyPolicy => privacyPolicy.isNotEmpty;

  static bool get hasTermsOfService => termsOfService.isNotEmpty;

  static bool get hasAnyLegalUrl =>
      hasPrivacyPolicy || hasTermsOfService;
}
