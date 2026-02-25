import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';

import 'support_test_helpers.dart';

void main() {
  test('randomized offline behavioral sequences preserve invariants', () async {
    final random = Random(1337);
    final repo = InMemoryLogRepository();
    final controller = LogController(repository: repo);
    await controller.initialize();

    for (var i = 0; i < 300; i++) {
      final active = controller.activeLog;
      final action = random.nextInt(5);

      if (active == null) {
        final expected = random.nextInt(90) + 1;
        await controller.startLog(
          label: 'random-$i',
          kind: randomBehaviorKind(random),
          expectedDurationMinutes: expected,
          transitionCategory: randomTransition(random),
          parentId: controller.logs.isEmpty ? null : controller.logs.first.id,
        );
      } else {
        switch (action) {
          case 0:
            await controller.completeActiveLog();
            break;
          case 1:
            await controller.pauseActiveLog();
            break;
          case 2:
            await controller.abandonActiveLog('reason-$i');
            break;
          case 3:
            await controller.startLog(
              label: 'ignored-$i',
              kind: BehaviorKind.intentionalAction,
              expectedDurationMinutes: 5,
            );
            break;
          default:
            await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      }

      expect(
        () => expectControllerInvariants(controller.logs),
        returnsNormally,
      );
      final timeline = controller.todayTimeline;
      for (var j = 1; j < timeline.length; j++) {
        expect(
          timeline[j - 1].startedAt.isAfter(timeline[j].startedAt),
          isFalse,
        );
      }
      final metrics = controller.todayMetrics;
      expect(metrics.plannedVsActualAccuracy.isFinite, isTrue);
      expect(metrics.deviationFrequency.isFinite, isTrue);
      expect(metrics.reactionRatio.isFinite, isTrue);
      expect(metrics.interruptionDensity.isFinite, isTrue);
    }
  });
}
