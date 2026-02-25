import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_aligner/features/logs/data/shared_prefs_log_repository.dart';

void main() {
  test('parses legacy log schema without crashing', () {
    final legacyMap = <String, dynamic>{
      'id': 'legacy-1',
      'description': 'Morning Hygiene',
      'type': 'start',
      'startTime': '2026-01-01T06:00:00.000',
      'endTime': '2026-01-01T06:25:00.000',
      'durationSeconds': 1500,
      'resolved': true,
    };

    final entry = LogEntry.fromMap(legacyMap);

    expect(entry.id, 'legacy-1');
    expect(entry.label, 'Morning Hygiene');
    expect(entry.kind, BehaviorKind.intentionalAction);
    expect(entry.status, LogStatus.completed);
    expect(entry.expectedDurationMinutes, 25);
    expect(entry.endedAt, isNotNull);
  });

  test('repository skips malformed rows and keeps valid legacy rows', () async {
    final validLegacy = jsonEncode(<String, dynamic>{
      'id': 'legacy-2',
      'description': 'Interrupting drift',
      'type': 'stop',
      'startTime': '2026-01-01T07:00:00.000',
      'resolved': false,
    });

    SharedPreferences.setMockInitialValues({
      'behavior_logs': ['not-json', validLegacy],
    });

    final repository = SharedPrefsLogRepository();
    final logs = await repository.loadLogs();

    expect(logs, hasLength(1));
    expect(logs.first.id, 'legacy-2');
    expect(logs.first.kind, BehaviorKind.correctiveStop);
    expect(logs.first.status, LogStatus.active);
  });
}
