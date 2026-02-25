import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/services/invariant_repair_engine.dart';

import 'support_test_helpers.dart';

void main() {
  test(
    'repair engine enforces single active session, fixes parent and duplicate IDs',
    () {
      final engine = InvariantRepairEngine(
        now: () => DateTime(2026, 1, 10, 12),
      );
      final logs = [
        entry(
          id: 'dup',
          start: DateTime(2026, 1, 10, 9),
          status: LogStatus.active,
        ),
        entry(
          id: 'dup',
          start: DateTime(2026, 1, 10, 11),
          status: LogStatus.active,
        ),
        entry(
          id: 'child',
          start: DateTime(2026, 1, 10, 8),
          parentId: 'missing',
        ),
      ];

      final result = engine.repair(logs);
      final activeCount = result.logs
          .where((e) => e.status == LogStatus.active)
          .length;

      expect(activeCount, 1);
      expect(result.logs.map((e) => e.id).toSet().length, result.logs.length);
      expect(
        result.logs.firstWhere((e) => e.label == 'Task child').parentId,
        isNull,
      );
      expect(result.events, contains('duplicate_id_regenerated'));
      expect(result.events, contains('multiple_active_resolved'));
    },
  );
}
