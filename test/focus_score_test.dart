import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/use_cases/compute_focus_score_use_case.dart';

import 'support_test_helpers.dart';

void main() {
  test(
    'focus score rewards adherence and penalizes interruptions/reactivity/drift',
    () {
      final useCase = ComputeFocusScoreUseCase();
      final good = [
        entry(id: '1', start: fixedNow(), expected: 45, actual: 44),
        entry(id: '2', start: fixedNow(), expected: 30, actual: 31),
      ];
      final poor = [
        entry(
          id: '3',
          start: fixedNow(),
          expected: 45,
          actual: 15,
          kind: BehaviorKind.drift,
          status: LogStatus.paused,
        ),
        entry(
          id: '4',
          start: fixedNow(),
          expected: 30,
          actual: 10,
          kind: BehaviorKind.correctiveStop,
          status: LogStatus.abandoned,
          reason: 'phone',
        ),
      ];

      final goodScore = useCase(good).score;
      final poorScore = useCase(poor).score;

      expect(goodScore, greaterThan(poorScore));
      expect(goodScore, inInclusiveRange(0, 100));
    },
  );
}
