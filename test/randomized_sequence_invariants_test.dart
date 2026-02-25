import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';

import 'support_test_helpers.dart';

void main() {
  setUpAll(() => logSuiteStart('randomized_sequence_invariants_test'));
  tearDownAll(() => logSuiteEnd('randomized_sequence_invariants_test'));
  setUp(logTestStart);
  tearDown(logTestEnd);

  test('randomized offline behavioral sequences preserve invariants', () async {
    final random = Random(1337);
    final repo = InMemoryLogRepository();
    final controller = LogController(repository: repo);
    await runLoggedControllerAction(
      action: 'initialize',
      operation: controller.initialize,
      controller: controller,
      repository: repo,
    );

    for (var i = 0; i < 300; i++) {
      final active = controller.activeLog;
      final action = random.nextInt(5);

      if (active == null) {
        final expected = random.nextInt(90) + 1;
        await runLoggedControllerAction(
          action: 'startLog:random_$i',
          operation: () => controller.startLog(
            label: 'random-$i',
            kind: randomBehaviorKind(random),
            expectedDurationMinutes: expected,
            transitionCategory: randomTransition(random),
            parentId: controller.logs.isEmpty ? null : controller.logs.first.id,
          ),
          controller: controller,
          repository: repo,
        );
      } else {
        switch (action) {
          case 0:
            await runLoggedControllerAction(
              action: 'completeActiveLog:$i',
              operation: controller.completeActiveLog,
              controller: controller,
              repository: repo,
            );
            break;
          case 1:
            await runLoggedControllerAction(
              action: 'pauseActiveLog:$i',
              operation: controller.pauseActiveLog,
              controller: controller,
              repository: repo,
            );
            break;
          case 2:
            await runLoggedControllerAction(
              action: 'abandonActiveLog:$i',
              operation: () => controller.abandonActiveLog('reason-$i'),
              controller: controller,
              repository: repo,
            );
            break;
          case 3:
            await runLoggedControllerAction(
              action: 'startLog:ignored_$i',
              operation: () => controller.startLog(
                label: 'ignored-$i',
                kind: BehaviorKind.intentionalAction,
                expectedDurationMinutes: 5,
              ),
              controller: controller,
              repository: repo,
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
      if (i % 50 == 0) {
        logRepositoryState('loop_checkpoint_$i', repo);
      }
      final metrics = controller.todayMetrics;
      expect(metrics.plannedVsActualAccuracy.isFinite, isTrue);
      expect(metrics.deviationFrequency.isFinite, isTrue);
      expect(metrics.reactionRatio.isFinite, isTrue);
      expect(metrics.interruptionDensity.isFinite, isTrue);
    }
  });
}
