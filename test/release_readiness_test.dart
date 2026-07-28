import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Expected production identity for Hub do PJ release gate.
const expectedPackageId = 'com.hubdopj.consultaempresas';
const expectedAppName = 'Hub do PJ: Consulta empresas';
const expectedProdOfferingId = 'hub_pj_cp_prod_mensal';
const expectedProdPlanIds = [
  'hub_pj_mensal_app',
  'hub_pj_mensal_cp_lg',
  'hub_pj_mensal_cp_pl',
];

Map<String, String> _parseEnvFile(File file) {
  expect(file.existsSync(), isTrue, reason: '.env missing — copy from .env.example');
  final map = <String, String>{};
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    final key = line.substring(0, eq).trim();
    var value = line.substring(eq + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    map[key] = value;
  }
  return map;
}

bool _envBoolTrue(String? raw) {
  if (raw == null) return false;
  final v = raw.trim().toLowerCase();
  return v == 'true' || v == '1' || v == 'yes';
}

bool _looksPlaceholder(String value) {
  final v = value.trim().toLowerCase();
  if (v.isEmpty) return true;
  return v.contains('...') ||
      v.contains('your_') ||
      v.contains('placeholder') ||
      v.contains('example.com') ||
      v == 'eyj...' ||
      v.contains('your_project');
}

void main() {
  late Map<String, String> env;

  setUpAll(() {
    env = _parseEnvFile(File('.env'));
  });

  group('RevenueCat / env keys', () {
    test('RC_USE_PROD is true (required before store upload)', () {
      expect(
        _envBoolTrue(env['RC_USE_PROD']),
        isTrue,
        reason: 'Set RC_USE_PROD=true in .env before production release',
      );
    });

    test('RC_USE_TEST is not forcing Test Store', () {
      expect(
        _envBoolTrue(env['RC_USE_TEST']),
        isFalse,
        reason: 'RC_USE_TEST must be absent or false for production',
      );
    });

    test('prodOfferingId is production offering', () {
      final source =
          File('lib/services/paywall/revenuecat_config.dart').readAsStringSync();
      expect(
        source.contains("prodOfferingId = '$expectedProdOfferingId'"),
        isTrue,
        reason: 'prodOfferingId must be $expectedProdOfferingId',
      );
    });

    test('forceMockPlans is false', () {
      final source =
          File('lib/services/paywall/revenuecat_config.dart').readAsStringSync();
      expect(
        source.contains('forceMockPlans = false'),
        isTrue,
        reason: 'forceMockPlans must be false for production',
      );
    });

    test('RC store API keys look real', () {
      final ios = env['RC_IOS_API_KEY'] ?? '';
      final android = env['RC_ANDROID_API_KEY'] ?? '';
      expect(ios.startsWith('appl_'), isTrue, reason: 'RC_IOS_API_KEY');
      expect(android.startsWith('goog_'), isTrue, reason: 'RC_ANDROID_API_KEY');
      expect(_looksPlaceholder(ios), isFalse);
      expect(_looksPlaceholder(android), isFalse);
    });
  });

  group('Legal / support / supabase', () {
    test('legal URLs are https and not example.com', () {
      final terms = env['LEGAL_TERMS_URL'] ?? '';
      final privacy = env['LEGAL_PRIVACY_URL'] ?? '';
      for (final url in [terms, privacy]) {
        expect(url.startsWith('https://'), isTrue, reason: url);
        expect(url.toLowerCase().contains('example.com'), isFalse, reason: url);
        expect(_looksPlaceholder(url), isFalse, reason: url);
      }
    });

    test('support contacts are filled', () {
      final phone = env['SUPPORT_WHATSAPP_PHONE'] ?? '';
      final email = env['SUPPORT_EMAIL'] ?? '';
      expect(phone.length, greaterThanOrEqualTo(10));
      expect(email.contains('@'), isTrue);
      expect(_looksPlaceholder(email), isFalse);
    });

    test('Supabase URL is not a placeholder', () {
      final url = env['SUPABASE_URL'] ?? '';
      final anon = env['SUPABASE_ANON_KEY'] ?? '';
      expect(url.startsWith('https://'), isTrue);
      expect(url.contains('YOUR_PROJECT'), isFalse);
      expect(_looksPlaceholder(url), isFalse);
      expect(anon.length, greaterThan(20));
      expect(_looksPlaceholder(anon), isFalse);
    });
  });

  group('App identity', () {
    test('Android applicationId is production package', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(
        gradle.contains('applicationId = "$expectedPackageId"'),
        isTrue,
      );
      expect(gradle.contains('com.example.'), isFalse);
    });

    test('iOS PRODUCT_BUNDLE_IDENTIFIER is production package', () {
      final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
      expect(
        pbx.contains('PRODUCT_BUNDLE_IDENTIFIER = $expectedPackageId;'),
        isTrue,
      );
      expect(RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = com\.example\.').hasMatch(pbx),
          isFalse);
    });

    test('Android and iOS display names match', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(
        manifest.contains('android:label="$expectedAppName"'),
        isTrue,
      );
      expect(
        plist.contains('<string>$expectedAppName</string>'),
        isTrue,
        reason: 'CFBundleDisplayName / CFBundleName',
      );
    });

    test('MainActivity is not under com.example', () {
      final legacy = File(
        'android/app/src/main/kotlin/com/example',
      );
      expect(legacy.existsSync(), isFalse);

      final prod = File(
        'android/app/src/main/kotlin/com/hubdopj/consultaempresas/MainActivity.kt',
      );
      expect(prod.existsSync(), isTrue);
    });

    test('launcher icons exist (Android + iOS)', () {
      final androidIcon = File(
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      );
      final iosIcon = File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
      );
      expect(androidIcon.existsSync(), isTrue);
      expect(androidIcon.lengthSync(), greaterThan(0));
      expect(iosIcon.existsSync(), isTrue);
    });
  });

  group('Plan limits + compliance', () {
    test('plan_limits.json includes production product ids', () {
      final json = jsonDecode(
        File('assets/config/plan_limits.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final id in expectedProdPlanIds) {
        expect(json.containsKey(id), isTrue, reason: 'missing $id');
      }
    });

    test('STORE_COMPLIANCE has no open blockers', () {
      final doc = File('docs/STORE_COMPLIANCE.md').readAsStringSync();
      expect(doc.contains('### Bloqueadores'), isTrue);

      final after = doc.split('### Bloqueadores').skip(1).first;
      final section = after.split('### ').first.toLowerCase();

      final hasNone = section.contains('nenhum');
      final hasOpenItem = RegExp(
        r'^\s*\d+\.\s+\*\*',
        multiLine: true,
      ).hasMatch(after.split('### ').first);

      expect(
        hasNone || !hasOpenItem,
        isTrue,
        reason: 'Open blockers in docs/STORE_COMPLIANCE.md — resolve before release',
      );
    });
  });
}
