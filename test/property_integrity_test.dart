import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/services/invariant_repair_engine.dart';

void main() {
  test('property-like random logs repaired to at most one active', () {
    final random = Random(42);
    final engine = InvariantRepairEngine(now: DateTime.now);

    for (var i = 0; i < 50; i++) {
      final logs = List.generate(20, (idx) {
        final active = random.nextBool();
        return LogEntry(
          id: '${i}_$idx',
          label: 'L$idx',
          kind: BehaviorKind.intentionalAction,
          startedAt: DateTime.now().subtract(
            Duration(minutes: random.nextInt(500)),
          ),
          expectedDurationMinutes: 30,
          status: active ? LogStatus.active : LogStatus.completed,
          schemaVersion: 3,
          endedAt: active ? null : DateTime.now(),
        );
      });

      final repaired = engine.repair(logs).logs;
      expect(
        repaired.where((e) => e.status == LogStatus.active).length,
        lessThanOrEqualTo(1),
      );
    }
  });
}
