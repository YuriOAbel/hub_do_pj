/// Store / compliance URLs. Set [privacyPolicy] before App Store submission.
class LegalUrls {
  LegalUrls._();

  /// Published privacy policy URL (must match App Store Connect).
  /// Empty until you paste the real URL — privacy button stays hidden.
  static const privacyPolicy = '';

  static const receitaFederal = 'https://www.gov.br/receitafederal';

  static bool get hasPrivacyPolicy => privacyPolicy.trim().isNotEmpty;
}
