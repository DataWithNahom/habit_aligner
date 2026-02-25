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
}
