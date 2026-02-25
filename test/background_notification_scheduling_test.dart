import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/services/notification_scheduler.dart';
import 'package:habit_aligner/features/logs/presentation/controllers/active_session_controller.dart';

import 'support_test_helpers.dart';

class FakeNotificationScheduler implements NotificationScheduler {
  final List<String> events = <String>[];

  @override
  Future<void> cancelSessionNotifications(String sessionId) async =>
      events.add('cancel:$sessionId');

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleHalfAlert(String sessionId, DateTime at) async =>
      events.add('half:$sessionId');

  @override
  Future<void> schedulePlannedAlert(String sessionId, DateTime at) async =>
      events.add('planned:$sessionId');
}

void main() {
  test('schedules half/planned alerts and cancels on resolution', () async {
    final repo = InMemoryLogRepository();
    final scheduler = FakeNotificationScheduler();
    final controller = ActiveSessionController(
      repository: repo,
      now: () => fixedNow(),
      notifications: scheduler,
    );

    await controller.start(
      label: 'Deep work',
      kind: BehaviorKind.intentionalAction,
      expectedDurationMinutes: 40,
    );
    expect(scheduler.events.where((e) => e.startsWith('half:')).length, 1);
    expect(scheduler.events.where((e) => e.startsWith('planned:')).length, 1);

    await controller.resolve(LogStatus.completed);
    expect(scheduler.events.any((e) => e.startsWith('cancel:')), isTrue);
  });

  test(
    'resume paused session creates new active session and schedules alerts',
    () async {
      final paused = entry(
        id: 'paused_1',
        start: fixedNow(-1),
        status: LogStatus.paused,
        expected: 25,
        actual: 10,
      );
      final repo = InMemoryLogRepository([paused]);
      final scheduler = FakeNotificationScheduler();
      final controller = ActiveSessionController(
        repository: repo,
        now: () => fixedNow(),
        notifications: scheduler,
      );

      final resumed = await controller.resume('paused_1');

      expect(resumed, isNotNull);
      expect(resumed!.status, LogStatus.active);
      expect(resumed.parentId, 'paused_1');
      expect(scheduler.events.where((e) => e.startsWith('half:')).length, 1);
      expect(scheduler.events.where((e) => e.startsWith('planned:')).length, 1);

      final logs = await repo.loadLogs();
      expect(logs.where((e) => e.status == LogStatus.active).length, 1);
    },
  );
}
