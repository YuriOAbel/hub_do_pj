/// Store / compliance URLs. Set before App Store submission.
class LegalUrls {
  LegalUrls._();

  /// Published privacy policy URL (must match App Store Connect).
  /// Empty until you paste the real URL — privacy button stays hidden.
  static const privacyPolicy = '';

  /// Published terms of use URL.
  /// Empty until you paste the real URL.
  static const termsOfService = '';

  static const receitaFederal = 'https://www.gov.br/receitafederal';

  static bool get hasPrivacyPolicy => privacyPolicy.trim().isNotEmpty;

  static bool get hasTermsOfService => termsOfService.trim().isNotEmpty;
}
