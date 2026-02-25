import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';

import 'support_test_helpers.dart';

void main() {
  setUpAll(() => logSuiteStart('log_controller_lifecycle_test'));
  tearDownAll(() => logSuiteEnd('log_controller_lifecycle_test'));
  setUp(logTestStart);
  tearDown(logTestEnd);

  group('log creation rules and active session behavior', () {
    test('startLog trims label and sets transition metadata', () async {
      final repo = InMemoryLogRepository();
      final controller = LogController(repository: repo);
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
        repository: repo,
      );

      await runLoggedControllerAction(
        action: 'startLog',
        operation: () => controller.startLog(
          label: '  Deep work  ',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 45,
          transitionCategory: TransitionCategory.importantNotUrgent,
          parentId: 'root-1',
        ),
        controller: controller,
        repository: repo,
      );

      final active = controller.activeLog;
      expect(active, isNotNull);
      expect(active!.label, 'Deep work');
      expect(active.expectedDurationMinutes, 45);
      expect(active.parentId, 'root-1');
      expect(active.transitionCategory, TransitionCategory.importantNotUrgent);
      expect(repo.saveCalls, 1);
    });

    test('starting when active log exists is ignored', () async {
      final repo = InMemoryLogRepository();
      final controller = LogController(repository: repo);
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
        repository: repo,
      );

      await runLoggedControllerAction(
        action: 'startLog:first',
        operation: () => controller.startLog(
          label: 'A',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 20,
        ),
        controller: controller,
      );
      final firstId = controller.activeLog!.id;

      await runLoggedControllerAction(
        action: 'startLog:ignored_second',
        operation: () => controller.startLog(
          label: 'B',
          kind: BehaviorKind.drift,
          expectedDurationMinutes: 25,
        ),
        controller: controller,
      );

      expect(controller.logs, hasLength(1));
      expect(controller.activeLog!.id, firstId);
    });

    test('rapid repeated start attempts still keep one active log', () async {
      final controller = LogController(repository: InMemoryLogRepository());
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
      );

      for (var i = 0; i < 20; i++) {
        await runLoggedControllerAction(
          action: 'startLog:rapid_$i',
          operation: () => controller.startLog(
            label: 'task $i',
            kind: BehaviorKind.intentionalBreak,
            expectedDurationMinutes: 5,
          ),
          controller: controller,
        );
      }

      expect(controller.logs, hasLength(1));
      expect(
        controller.logs.where((log) => log.status == LogStatus.active),
        hasLength(1),
      );
    });

    test('active elapsed increases over time while active', () async {
      final startedAt = DateTime.now().subtract(const Duration(seconds: 1));
      final controller = LogController(
        repository: InMemoryLogRepository([
          buildLog(id: 'run', startedAt: startedAt, status: LogStatus.active),
        ]),
      );
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
      );
      final before = controller.activeElapsed;

      await Future<void>.delayed(const Duration(seconds: 2));
      logControllerState('after_wait', controller);

      expect(controller.activeElapsed, greaterThan(before));
      expect(
        controller.activeLog!.expectedDuration,
        const Duration(minutes: 30),
      );
      expect(controller.activeLog!.actualDuration, isA<Duration>());
    });

    test(
      'half-time and planned-duration alerts trigger once and reset',
      () async {
        final now = DateTime.now();
        final controller = LogController(
          repository: InMemoryLogRepository([
            buildLog(
              id: 'short',
              startedAt: now.subtract(const Duration(minutes: 2)),
              expectedMinutes: 2,
              status: LogStatus.active,
            ),
          ]),
        );

        await runLoggedControllerAction(
          action: 'initialize',
          operation: controller.initialize,
          controller: controller,
        );

        expect(controller.halfTimeAlertDue, isTrue);
        expect(controller.plannedDurationAlertDue, isTrue);

        controller.dismissHalfTimeAlert();
        controller.dismissPlannedDurationAlert();
        logControllerState('after_dismiss_alerts', controller);
        expect(controller.halfTimeAlertDue, isFalse);
        expect(controller.plannedDurationAlertDue, isFalse);

        await Future<void>.delayed(const Duration(milliseconds: 1200));
        logControllerState('after_alert_reset_wait', controller);

        expect(controller.halfTimeAlertDue, isTrue);
        expect(controller.plannedDurationAlertDue, isTrue);
      },
    );

    test('alerts are not due after resolution', () async {
      final controller = LogController(repository: InMemoryLogRepository());
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
      );
      await runLoggedControllerAction(
        action: 'startLog',
        operation: () => controller.startLog(
          label: 'session',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 1,
        ),
        controller: controller,
      );

      await runLoggedControllerAction(
        action: 'completeActiveLog',
        operation: controller.completeActiveLog,
        controller: controller,
      );

      expect(controller.activeLog, isNull);
      expect(controller.halfTimeAlertDue, isFalse);
      expect(controller.plannedDurationAlertDue, isFalse);
    });
  });

  group('resolution actions and transition sequences', () {
    test('completeActiveLog resolves and persists', () async {
      final repo = InMemoryLogRepository();
      final controller = LogController(repository: repo);
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
        repository: repo,
      );
      await runLoggedControllerAction(
        action: 'startLog',
        operation: () => controller.startLog(
          label: 'complete me',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 20,
        ),
        controller: controller,
        repository: repo,
      );

      await runLoggedControllerAction(
        action: 'completeActiveLog',
        operation: controller.completeActiveLog,
        controller: controller,
        repository: repo,
      );

      expect(controller.activeLog, isNull);
      expect(controller.logs.single.status, LogStatus.completed);
      expect(controller.logs.single.endedAt, isNotNull);
      expect(repo.snapshot.single.status, LogStatus.completed);
    });

    test('pauseActiveLog resolves as paused', () async {
      final controller = LogController(repository: InMemoryLogRepository());
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
      );
      await runLoggedControllerAction(
        action: 'startLog',
        operation: () => controller.startLog(
          label: 'pause me',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 20,
        ),
        controller: controller,
      );

      await runLoggedControllerAction(
        action: 'pauseActiveLog',
        operation: controller.pauseActiveLog,
        controller: controller,
      );

      expect(controller.activeLog, isNull);
      expect(controller.logs.single.status, LogStatus.paused);
      expect(controller.todayTimeline, hasLength(1));
    });

    test('abandonActiveLog stores reason and status', () async {
      final controller = LogController(repository: InMemoryLogRepository());
      await runLoggedControllerAction(
        action: 'initialize',
        operation: controller.initialize,
        controller: controller,
      );
      await runLoggedControllerAction(
        action: 'startLog',
        operation: () => controller.startLog(
          label: 'abandon me',
          kind: BehaviorKind.intentionalAction,
          expectedDurationMinutes: 20,
        ),
        controller: controller,
      );

      await runLoggedControllerAction(
        action: 'abandonActiveLog',
        operation: () => controller.abandonActiveLog('  context switch  '),
        controller: controller,
      );

      expect(controller.activeLog, isNull);
      expect(controller.logs.single.status, LogStatus.abandoned);
      expect(controller.logs.single.abandonmentReason, 'context switch');
    });

    test(
      'transition chain keeps parent lineage and chronological order',
      () async {
        final controller = LogController(repository: InMemoryLogRepository());
        await runLoggedControllerAction(
          action: 'initialize',
          operation: controller.initialize,
          controller: controller,
        );

        await runLoggedControllerAction(
          action: 'startLog:A',
          operation: () => controller.startLog(
            label: 'A',
            kind: BehaviorKind.intentionalAction,
            expectedDurationMinutes: 10,
          ),
          controller: controller,
        );
        final a = controller.activeLog!;
        await runLoggedControllerAction(
          action: 'completeActiveLog:A',
          operation: controller.completeActiveLog,
          controller: controller,
        );

        await runLoggedControllerAction(
          action: 'startLog:B',
          operation: () => controller.startLog(
            label: 'B',
            kind: BehaviorKind.correctiveStop,
            expectedDurationMinutes: 5,
            parentId: a.id,
            transitionCategory: TransitionCategory.urgentImportant,
          ),
          controller: controller,
        );
        final b = controller.activeLog!;
        await runLoggedControllerAction(
          action: 'pauseActiveLog:B',
          operation: controller.pauseActiveLog,
          controller: controller,
        );

        await runLoggedControllerAction(
          action: 'startLog:C',
          operation: () => controller.startLog(
            label: 'C',
            kind: BehaviorKind.intentionalBreak,
            expectedDurationMinutes: 5,
            parentId: b.id,
            transitionCategory: TransitionCategory.importantNotUrgent,
          ),
          controller: controller,
        );
        await runLoggedControllerAction(
          action: 'abandonActiveLog:C',
          operation: () => controller.abandonActiveLog('interrupted'),
          controller: controller,
        );

        final logs = controller.logs.reversed.toList();
        for (var i = 1; i < logs.length; i++) {
          expect(logs[i - 1].startedAt.isAfter(logs[i].startedAt), isFalse);
        }
        expect(
          controller.logs.where((log) => log.parentId == a.id).isNotEmpty,
          isTrue,
        );
        expect(
          controller.todayMetrics.plannedVsActualAccuracy,
          inInclusiveRange(0, 1),
        );
      },
    );
  });
}
