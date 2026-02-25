import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/use_cases/compute_focus_score_use_case.dart';

import 'support_test_helpers.dart';

void main() {
  test('focus score computation scales to large offline dataset', () {
    final sessions = List.generate(
      50000,
      (i) => entry(
        id: '$i',
        start: DateTime(2026, 1, (i % 27) + 1, (i % 24)),
        expected: 30,
        actual: 25 + (i % 10),
      ),
    );

    final sw = Stopwatch()..start();
    final score = ComputeFocusScoreUseCase()(sessions).score;
    sw.stop();

    expect(score, inInclusiveRange(0, 100));
    expect(sw.elapsedMilliseconds, lessThan(300));
  });
}
