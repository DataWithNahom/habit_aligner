import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationScheduler {
  Future<void> initialize();
  Future<void> scheduleHalfAlert(String sessionId, DateTime at);
  Future<void> schedulePlannedAlert(String sessionId, DateTime at);
  Future<void> cancelSessionNotifications(String sessionId);
}

class FlutterNotificationScheduler implements NotificationScheduler {
  FlutterNotificationScheduler() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  @override
  Future<void> scheduleHalfAlert(String sessionId, DateTime at) async {
    await _plugin.zonedSchedule(
      sessionId.hashCode,
      'Half-time checkpoint',
      'Continue or transition based on your current focus state.',
      tz.TZDateTime.from(at, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails('half_alert', 'Half Alerts'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> schedulePlannedAlert(String sessionId, DateTime at) async {
    await _plugin.zonedSchedule(
      sessionId.hashCode + 1,
      'Planned duration reached',
      'Reassess whether to continue or transition.',
      tz.TZDateTime.from(at, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails('planned_alert', 'Planned Alerts'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelSessionNotifications(String sessionId) async {
    await _plugin.cancel(sessionId.hashCode);
    await _plugin.cancel(sessionId.hashCode + 1);
  }
}
