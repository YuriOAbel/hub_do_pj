import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analytics events registry is valid and matches helper', () {
    final jsonFile = File('assets/config/analytics_events.json');
    final helperFile = File('lib/core/helpers/firebase_analytics_helper.dart');

    expect(jsonFile.existsSync(), isTrue);
    expect(helperFile.existsSync(), isTrue);

    final json = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
    final events = json['events'] as Map<String, dynamic>;
    expect(events, isNotEmpty);

    final helperSource = helperFile.readAsStringSync();
    final usedKeys = <String>{};
    final regex = RegExp(r"eventKey:\s*'([^']+)'");
    for (final match in regex.allMatches(helperSource)) {
      usedKeys.add(match.group(1)!);
    }

    final names = <String>{};
    for (final entry in events.entries) {
      final key = entry.key;
      final event = entry.value as Map<String, dynamic>;
      expect(event['name'], key);
      expect(event['description'], isNotEmpty);
      expect(event['parameters'], isA<List>());
      expect(names.contains(event['name']), isFalse);
      names.add(event['name'] as String);
    }

    for (final key in usedKeys) {
      expect(events.containsKey(key), isTrue, reason: 'Missing registry key: $key');
    }
  });
}
