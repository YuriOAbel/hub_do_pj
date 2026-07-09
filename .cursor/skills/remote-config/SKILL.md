# Skill: Remote Config

Patterns for reading Firebase Remote Config in a type-safe way.

---

## Key Files

| File | Role |
|---|---|
| `lib/services/firebase_config_service.dart` | Singleton wrapper — never use Firebase Remote Config directly |
| `assets/config/remote_config.json` | Local defaults for all Remote Config keys |
| `lib/services/paywall/paywall_offering_config.dart` | Example of the correct typed model pattern |

---

## Golden Rule

**NEVER access Remote Config as a raw `Map<String, dynamic>` in business logic.**
Always parse into a typed model with `fromJson` + `const defaultConfig`.

---

## How to Read a Remote Config Value

### Primitive (string / bool / int)
```dart
// via FirebaseService directly (FirebaseConfigService wraps defaults)
final value = FirebaseService.instance.getString('my_key');
final flag = FirebaseService.instance.getBool('my_flag');
```

### Object (JSON)
```dart
// Always go through FirebaseConfigService.getObj — it decodes + falls back to local default
final raw = FirebaseConfigService.instance.getObj('my_object_key');
// raw is null if key missing or decode fails — handle gracefully
```

---

## Defining a New Remote Config Model

**Step 1** — Add the key + default to `assets/config/remote_config.json`:
```json
{
  "configs": {
    "my_feature_config": {
      "type": "object",
      "default": {
        "enabled": false,
        "threshold": 10
      }
    }
  }
}
```

**Step 2** — Create a typed model (plain class, no Freezed needed):
```dart
class MyFeatureConfig {
  final bool enabled;
  final int threshold;

  const MyFeatureConfig({
    required this.enabled,
    required this.threshold,
  });

  // Hardcoded safe defaults — used when Remote Config is unavailable
  static const defaultConfig = MyFeatureConfig(
    enabled: false,
    threshold: 10,
  );

  factory MyFeatureConfig.fromJson(Map<String, dynamic> json) {
    return MyFeatureConfig(
      enabled: json['enabled'] as bool? ?? defaultConfig.enabled,
      threshold: json['threshold'] as int? ?? defaultConfig.threshold,
    );
  }
}
```

**Step 3** — Read in the service (never in a provider or view):
```dart
MyFeatureConfig _getFeatureConfig() {
  try {
    final raw = FirebaseConfigService.instance.getObj('my_feature_config');
    if (raw == null) return MyFeatureConfig.defaultConfig;
    return MyFeatureConfig.fromJson(raw);
  } catch (e) {
    debugPrint('⚠️ Error parsing my_feature_config: $e');
    return MyFeatureConfig.defaultConfig;
  }
}
```

---

## Reference: PaywallOfferingConfig (real example)

```dart
class PaywallOfferingConfig {
  final String offerName;
  final bool offerRecovery;
  final String offerRecoveryName;

  const PaywallOfferingConfig({
    required this.offerName,
    required this.offerRecovery,
    required this.offerRecoveryName,
  });

  static const defaultConfig = PaywallOfferingConfig(
    offerName: 'SportScan default',
    offerRecovery: false,
    offerRecoveryName: 'SportScan recovery',
  );

  factory PaywallOfferingConfig.fromJson(Map<String, dynamic> json) {
    return PaywallOfferingConfig(
      offerName: json['offer_name'] as String? ?? defaultConfig.offerName,
      offerRecovery: json['offer_recovery'] as bool? ?? defaultConfig.offerRecovery,
      offerRecoveryName: json['offer_recovery_name'] as String? ?? defaultConfig.offerRecoveryName,
    );
  }
}
```

---

## Anti-Patterns

```dart
// ❌ NEVER — raw map in business logic
final raw = FirebaseConfigService.instance.getObj('paywall_offering_config');
final offerName = raw?['offer_name'] as String? ?? 'default';

// ❌ NEVER — access Firebase Remote Config directly in providers/views
final rc = FirebaseRemoteConfig.instance;
final value = rc.getString('some_key');

// ✅ ALWAYS — typed model via service
final config = _getOfferingConfig(); // returns PaywallOfferingConfig
final offerName = config.offerName;
```
