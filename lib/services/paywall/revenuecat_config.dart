class RevenueCatConfig {
  static const String apiKey = String.fromEnvironment('RC_API_KEY');
  static const String offeringId = 'default';
  static const String premiumEntitlementId = 'premium';
  static const bool isDebug =
      bool.fromEnvironment('RC_DEBUG', defaultValue: false);
  static bool get useMock => apiKey.isEmpty;
}
