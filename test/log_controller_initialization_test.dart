import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/data/shared_prefs_log_repository.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/presentation/log_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support_test_helpers.dart';

void main() {
  group('controller initialization and loading', () {
    test('empty storage initializes safely', () async {
      final repository = InMemoryLogRepository();
      final controller = LogController(repository: repository);

      await controller.initialize();

      expect(controller.logs, isEmpty);
      expect(controller.activeLog, isNull);
      expect(controller.todayTimeline, isEmpty);
      expect(controller.todayMetrics.plannedVsActualAccuracy, 0);
      expect(controller.todayMetrics.reactionRatio, 0);
    });

    test('loads valid logs and computes safe timeline and metrics', () async {
      final now = DateTime.now();
      final repository = InMemoryLogRepository([
        buildLog(
          id: 'a',
          startedAt: now.subtract(const Duration(minutes: 25)),
          endedAt: now.subtract(const Duration(minutes: 5)),
        ),
      ]);
      final controller = LogController(repository: repository);

      await controller.initialize();

      expect(controller.logs, hasLength(1));
      expect(controller.todayTimeline, hasLength(1));
      expect(
        controller.todayMetrics.plannedVsActualAccuracy,
        inInclusiveRange(0, 1),
      );
    });

    test('mixed valid and corrupted rows load without crashing', () async {
      final valid = jsonEncode(<String, dynamic>{
        'id': 'ok-1',
        'label': 'Good row',
        'kind': 'intentionalAction',
        'startedAt': DateTime.now().toIso8601String(),
        'expectedDurationMinutes': 30,
        'status': 'completed',
        'endedAt': DateTime.now()
            .add(const Duration(minutes: 1))
            .toIso8601String(),
      });
      SharedPreferences.setMockInitialValues({
        'behavior_logs': <String>['{not-json', valid, '42'],
      });
      final repository = SharedPrefsLogRepository();
      final controller = LogController(repository: repository);

      await controller.initialize();

      expect(controller.logs, hasLength(1));
      expect(controller.logs.first.id, 'ok-1');
    });

    test('only corrupted rows are skipped safely', () async {
      SharedPreferences.setMockInitialValues({
        'behavior_logs': <String>['oops', '{invalid'],
      });
      final controller = LogController(repository: SharedPrefsLogRepository());

      await controller.initialize();

      expect(controller.logs, isEmpty);
      expect(controller.todayMetrics.interruptionDensity, 0);
    });

    test(
      'legacy schema logs deserialize through controller initialization',
      () async {
        SharedPreferences.setMockInitialValues({
          'behavior_logs': <String>[
            jsonEncode(<String, dynamic>{
              'id': 'legacy-100',
              'description': 'Legacy stop',
              'type': 'stop',
              'startTime': '2025-01-01T10:00:00.000',
              'durationSeconds': 600,
              'resolved': true,
              'endTime': '2025-01-01T10:10:00.000',
            }),
          ],
        });
        final controller = LogController(
          repository: SharedPrefsLogRepository(),
        );

        await controller.initialize();

        expect(controller.logs.single.kind, BehaviorKind.correctiveStop);
        expect(controller.logs.single.status, LogStatus.completed);
        expect(controller.logs.single.expectedDurationMinutes, 10);
      },
    );

    test('multiple active logs only expose one activeLog', () async {
      final now = DateTime.now();
      final controller = LogController(
        repository: InMemoryLogRepository([
          buildLog(
            id: 'active-1',
            startedAt: now.subtract(const Duration(minutes: 10)),
            status: LogStatus.active,
          ),
          buildLog(
            id: 'active-2',
            startedAt: now.subtract(const Duration(minutes: 5)),
            status: LogStatus.active,
          ),
        ]),
      );

      await controller.initialize();

      expect(controller.activeLog, isNotNull);
      expect(controller.logs.where((item) => item.isActive), hasLength(2));
    });

    test('handles active log without end time and computes elapsed', () async {
      final startedAt = DateTime.now().subtract(const Duration(seconds: 3));
      final controller = LogController(
        repository: InMemoryLogRepository([
          buildLog(
            id: 'running',
            startedAt: startedAt,
            status: LogStatus.active,
          ),
        ]),
      );

      await controller.initialize();

      expect(controller.activeLog, isNotNull);
      expect(
        controller.activeElapsed,
        greaterThanOrEqualTo(const Duration(seconds: 3)),
      );
    });

    test('missing optional fields in map fallback safely', () {
      final entry = LogEntry.fromMap(<String, dynamic>{
        'kind': 'drift',
        'startedAt': DateTime.now().toIso8601String(),
        'expectedDurationMinutes': 15,
        'status': 'completed',
        'endedAt': DateTime.now()
            .add(const Duration(minutes: 1))
            .toIso8601String(),
      });

      expect(entry.id, isNotEmpty);
      expect(entry.label, 'Unlabeled action');
      expect(entry.parentId, isNull);
      expect(entry.transitionCategory, isNull);
    });

    test('extremely large dataset loads and timeline remains sorted', () async {
      final now = DateTime.now();
      final entries = List.generate(2000, (index) {
        final started = now.subtract(Duration(minutes: index));
        return buildLog(
          id: 'bulk-$index',
          startedAt: started,
          endedAt: started.add(const Duration(minutes: 5)),
        );
      });
      final controller = LogController(
        repository: InMemoryLogRepository(entries),
      );

      await controller.initialize();

      expect(controller.logs.length, 2000);
      final timeline = controller.todayTimeline;
      for (var i = 1; i < timeline.length; i++) {
        expect(
          timeline[i - 1].startedAt.isAfter(timeline[i].startedAt),
          isFalse,
          reason: 'Timeline is expected to be ascending.',
        );
      }
    });

    test(
      'logs spanning multiple days only include today in timeline',
      () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final controller = LogController(
          repository: InMemoryLogRepository([
            buildLog(
              id: 'today',
              startedAt: now.subtract(const Duration(hours: 2)),
              endedAt: now.subtract(const Duration(hours: 1)),
            ),
            buildLog(
              id: 'yesterday',
              startedAt: yesterday,
              endedAt: yesterday.add(const Duration(minutes: 10)),
            ),
          ]),
        );

        await controller.initialize();

        expect(
          controller.todayTimeline.map((item) => item.id),
          contains('today'),
        );
        expect(
          controller.todayTimeline.map((item) => item.id),
          isNot(contains('yesterday')),
        );
      },
    );
  });
}
