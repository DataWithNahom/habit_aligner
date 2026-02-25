import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/use_cases/drift_analysis_use_case.dart';

import 'support_test_helpers.dart';

void main() {
  test('drift analysis emits human-readable insights', () {
    final useCase = DriftAnalysisUseCase();
    final sessions = [
      entry(
        id: '1',
        start: DateTime(2026, 1, 10, 15),
        actual: 42,
        kind: BehaviorKind.drift,
        status: LogStatus.paused,
      ),
      entry(
        id: '2',
        start: DateTime(2026, 1, 10, 16),
        actual: 41,
        status: LogStatus.abandoned,
        reason: 'notifications',
      ),
    ];

    final insights = useCase(sessions).map((e) => e.message).join('\n');

    expect(insights, contains('drift between'));
    expect(insights, contains('Interruptions increase after'));
    expect(insights, contains('Most common abandonment reason'));
  });
}
