import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';

void main() {
  test('legacy map fields migrate into current log entry schema', () {
    final legacy = {
      'id': 'legacy-1',
      'description': 'Legacy session',
      'type': 'start',
      'startTime': '2026-01-10T10:00:00.000',
      'endTime': '2026-01-10T10:20:00.000',
      'durationSeconds': 1200,
      'resolved': true,
    };

    final entry = LogEntry.fromMap(legacy);

    expect(entry.id, 'legacy-1');
    expect(entry.label, 'Legacy session');
    expect(entry.kind, BehaviorKind.intentionalAction);
    expect(entry.status, LogStatus.completed);
    expect(entry.expectedDurationMinutes, 20);
    expect(entry.schemaVersion, 1);
  });
}
