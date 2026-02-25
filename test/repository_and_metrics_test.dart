import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/data/shared_prefs_log_repository.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support_test_helpers.dart';

void main() {
  group('persistence reliability', () {
    test('save occurs after each mutation and survives reload', () async {
      final repo = InMemoryLogRepository();
      final controller = LogController(repository: repo);
      await controller.initialize();

      await controller.startLog(
        label: 'persist',
        kind: BehaviorKind.intentionalAction,
        expectedDurationMinutes: 10,
      );
      await controller.pauseActiveLog();
      await controller.startLog(
        label: 'persist2',
        kind: BehaviorKind.intentionalBreak,
        expectedDurationMinutes: 10,
      );
      await controller.completeActiveLog();

      expect(repo.saveCalls, 4);

      final reloadedController = LogController(
        repository: InMemoryLogRepository(repo.snapshot),
      );
      await reloadedController.initialize();
      expect(reloadedController.logs, hasLength(2));
      expect(
        reloadedController.logs.any(
          (entry) => entry.status == LogStatus.completed,
        ),
        isTrue,
      );
      expect(
        reloadedController.logs.any(
          (entry) => entry.status == LogStatus.paused,
        ),
        isTrue,
      );
    });

    test(
      'serialization round-trip via shared preferences is lossless for key fields',
      () async {
        SharedPreferences.setMockInitialValues({});
        final repo = SharedPrefsLogRepository();

        final now = DateTime.now();
        final logs = [
          buildLog(
            id: 'rt-1',
            label: 'Roundtrip',
            startedAt: now,
            endedAt: now.add(const Duration(minutes: 15)),
            transitionCategory: TransitionCategory.neither,
            parentId: 'rt-parent',
            kind: BehaviorKind.correctiveStop,
          ),
        ];

        await repo.saveLogs(logs);
        final loaded = await repo.loadLogs();

        expect(loaded, hasLength(1));
        expect(loaded.single.id, 'rt-1');
        expect(loaded.single.parentId, 'rt-parent');
        expect(loaded.single.transitionCategory, TransitionCategory.neither);
        expect(loaded.single.kind, BehaviorKind.correctiveStop);
      },
    );

    test('malformed entries are skipped without losing valid rows', () async {
      final valid = jsonEncode(
        buildLog(id: 'valid-1', startedAt: DateTime.now()).toMap(),
      );
      SharedPreferences.setMockInitialValues({
        'behavior_logs': ['bad-json', valid, '{'],
      });

      final loaded = await SharedPrefsLogRepository().loadLogs();

      expect(loaded, hasLength(1));
      expect(loaded.single.id, 'valid-1');
    });
  });

  group('metrics and timeline validation', () {
    test('metrics formulas match controlled synthetic logs', () async {
      final day = DateTime.now();
      final items = [
        buildLog(
          id: 'perfect',
          startedAt: day.subtract(const Duration(hours: 4)),
          endedAt: day.subtract(const Duration(hours: 3, minutes: 30)),
          expectedMinutes: 30,
          kind: BehaviorKind.intentionalAction,
          status: LogStatus.completed,
        ),
        buildLog(
          id: 'mismatch',
          startedAt: day.subtract(const Duration(hours: 3)),
          endedAt: day.subtract(const Duration(hours: 2, minutes: 30)),
          expectedMinutes: 10,
          kind: BehaviorKind.drift,
          status: LogStatus.paused,
        ),
        buildLog(
          id: 'zeroish',
          startedAt: day.subtract(const Duration(hours: 2)),
          endedAt: day.subtract(const Duration(hours: 2)),
          expectedMinutes: 15,
          kind: BehaviorKind.correctiveStop,
          status: LogStatus.abandoned,
          abandonmentReason: 'test',
        ),
      ];
      final controller = LogController(
        repository: InMemoryLogRepository(items),
      );
      await controller.initialize();

      final metrics = controller.todayMetrics;

      expect(metrics.plannedVsActualAccuracy, inInclusiveRange(0, 1));
      expect(metrics.deviationFrequency, closeTo(2 / 3, 0.0001));
      expect(metrics.driftDuration, const Duration(minutes: 30));
      expect(metrics.reactionRatio, closeTo(2 / 3, 0.0001));
      expect(metrics.interruptionDensity, closeTo(2 / 3, 0.0001));
      expect(metrics.plannedVsActualAccuracy.isFinite, isTrue);
      expect(metrics.reactionRatio.isFinite, isTrue);
      expect(metrics.interruptionDensity.isFinite, isTrue);
    });

    test(
      'timeline includes active logs started today and remains sorted ascending',
      () async {
        final now = DateTime.now();
        final controller = LogController(
          repository: InMemoryLogRepository([
            buildLog(
              id: '2',
              startedAt: now.subtract(const Duration(minutes: 20)),
              endedAt: now.subtract(const Duration(minutes: 15)),
            ),
            buildLog(
              id: '1',
              startedAt: now.subtract(const Duration(minutes: 40)),
              status: LogStatus.active,
            ),
            buildLog(
              id: '3',
              startedAt: now.subtract(const Duration(minutes: 5)),
              endedAt: now.subtract(const Duration(minutes: 1)),
            ),
          ]),
        );

        await controller.initialize();
        final ids = controller.todayTimeline.map((item) => item.id).toList();

        expect(ids, ['1', '2', '3']);
        expect(ids.toSet().length, ids.length);
      },
    );

    test('cross-midnight logs are filtered by startedAt day', () async {
      final now = DateTime.now();
      final yesterdayLate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(minutes: 10));
      final todayEarly = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(minutes: 5));
      final controller = LogController(
        repository: InMemoryLogRepository([
          buildLog(
            id: 'cross-midnight',
            startedAt: yesterdayLate,
            endedAt: todayEarly,
          ),
          buildLog(
            id: 'today',
            startedAt: todayEarly,
            endedAt: todayEarly.add(const Duration(minutes: 10)),
          ),
        ]),
      );

      await controller.initialize();

      expect(controller.todayTimeline.map((item) => item.id), ['today']);
    });
  });
}
