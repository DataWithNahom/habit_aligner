import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/logging/logger_service.dart';

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
    await LoggerService.instance.traceAsync<void>(
      event: 'NotificationInitialize',
      tag: FeatureTag.notification,
      operation: () async {
        const android = AndroidInitializationSettings('@mipmap/ic_launcher');
        const ios = DarwinInitializationSettings();
        await _plugin.initialize(
          const InitializationSettings(android: android, iOS: ios),
          onDidReceiveNotificationResponse: (response) {
            LoggerService.instance.log(
              level: LogLevel.info,
              tag: FeatureTag.notification,
              event: 'NotificationTapped',
              message: 'User interacted with local notification.',
              context: {
                'notificationResponseType':
                    response.notificationResponseType.name,
                'payload': response.payload,
                'actionId': response.actionId,
              },
            );
          },
        );

        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await androidPlugin?.requestNotificationsPermission();
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.notification,
          event: 'NotificationPermissionResult',
          message: 'Notification permission request completed.',
          context: {'granted': granted},
        );
      },
    );
  }

  @override
  Future<void> scheduleHalfAlert(String sessionId, DateTime at) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'ScheduleHalfAlert',
      tag: FeatureTag.notification,
      context: {
        'sessionId': sessionId,
        'notificationId': sessionId.hashCode,
        'scheduledAt': at.toIso8601String(),
        'timezone': tz.UTC.name,
      },
      operation: () async {
        await _plugin.zonedSchedule(
          sessionId.hashCode,
          'Half-time checkpoint',
          'Continue or transition based on your current focus state.',
          tz.TZDateTime.from(at, tz.UTC),
          const NotificationDetails(
            android: AndroidNotificationDetails('half_alert', 'Half Alerts'),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'half:$sessionId',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      },
    );
  }

  @override
  Future<void> schedulePlannedAlert(String sessionId, DateTime at) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'SchedulePlannedAlert',
      tag: FeatureTag.notification,
      context: {
        'sessionId': sessionId,
        'notificationId': sessionId.hashCode + 1,
        'scheduledAt': at.toIso8601String(),
        'timezone': tz.UTC.name,
      },
      operation: () async {
        await _plugin.zonedSchedule(
          sessionId.hashCode + 1,
          'Planned duration reached',
          'Reassess whether to continue or transition.',
          tz.TZDateTime.from(at, tz.UTC),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'planned_alert',
              'Planned Alerts',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'planned:$sessionId',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      },
    );
  }

  @override
  Future<void> cancelSessionNotifications(String sessionId) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'CancelSessionNotifications',
      tag: FeatureTag.notification,
      context: {'sessionId': sessionId},
      operation: () async {
        await _plugin.cancel(sessionId.hashCode);
        await _plugin.cancel(sessionId.hashCode + 1);
      },
    );
  }
}
