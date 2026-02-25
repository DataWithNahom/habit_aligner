import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/use_cases/compute_streak_use_case.dart';

import 'support_test_helpers.dart';

void main() {
  test('streak increments across consecutive qualifying days and resets on abandonment', () {
    final useCase = ComputeStreakUseCase();
    final now = DateTime.now();
    DateTime day(int offset) {
      final d = now.add(Duration(days: offset));
      return DateTime(d.year, d.month, d.day, 10);
    }

    final sessions = [
      entry(id: 'today1', start: day(0), actual: 25),
      entry(id: 'y1', start: day(-1), actual: 24),
      entry(
        id: 'y2',
        start: day(-2),
        actual: 40,
        status: LogStatus.abandoned,
        reason: 'fatigue',
      ),
    ];

    expect(useCase(sessions), 2);
  });
}
