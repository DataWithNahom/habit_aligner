import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/logging/logger_service.dart';
import '../../data/log_repository.dart';
import '../../domain/log_entry.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../domain/use_cases/resume_session_use_case.dart';
import '../../domain/use_cases/resolve_session_use_case.dart';
import '../../domain/use_cases/start_session_use_case.dart';

class ActiveSessionController extends ChangeNotifier {
  ActiveSessionController({
    required LogRepository repository,
    required DateTime Function() now,
    required NotificationScheduler notifications,
  }) : _repository = repository,
       _startUseCase = StartSessionUseCase(repository: repository, now: now),
       _resolveUseCase = ResolveSessionUseCase(
         repository: repository,
         now: now,
       ),
       _resumeUseCase = ResumeSessionUseCase(repository: repository, now: now),
       _notifications = notifications,
       _now = now {
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.init,
      event: 'ActiveSessionControllerConstructed',
      message: 'ActiveSessionController created.',
    );
    unawaited(_notifications.initialize());
  }

  final LogRepository _repository;
  final StartSessionUseCase _startUseCase;
  final ResolveSessionUseCase _resolveUseCase;
  final ResumeSessionUseCase _resumeUseCase;
  final NotificationScheduler _notifications;
  final DateTime Function() _now;

  LogEntry? _active;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  LogEntry? get active => _active;
  Duration get elapsed => _elapsed;

  Future<void> refresh() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'ActiveSessionRefresh',
      tag: FeatureTag.system,
      operation: () async {
        final logs = await _repository.loadLogs();
        _active = logs
            .where((e) => e.isActive)
            .cast<LogEntry?>()
            .firstWhere((e) => e != null, orElse: () => null);
        _syncTick();
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.system,
          event: 'ActiveSessionRefreshResult',
          message: 'Refreshed active session state.',
          context: {
            'activeSessionId': _active?.id,
            'elapsedMs': _elapsed.inMilliseconds,
          },
        );
        notifyListeners();
      },
    );
  }

  Future<void> start({
    required String label,
    required BehaviorKind kind,
    required int expectedDurationMinutes,
    TransitionCategory? transitionCategory,
    String? parentId,
  }) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'ActiveSessionStart',
      tag: FeatureTag.userAction,
      context: {
        'label': label,
        'kind': kind.name,
        'expectedDurationMinutes': expectedDurationMinutes,
        'transitionCategory': transitionCategory?.name,
        'parentId': parentId,
      },
      operation: () async {
        final created = await _startUseCase(
          label: label,
          kind: kind,
          expectedDurationMinutes: expectedDurationMinutes,
          transitionCategory: transitionCategory,
          parentId: parentId,
        );
        if (created != null) {
          await _notifications.scheduleHalfAlert(
            created.id,
            created.startedAt.add(
              Duration(minutes: (created.expectedDurationMinutes / 2).ceil()),
            ),
          );
          await _notifications.schedulePlannedAlert(
            created.id,
            created.startedAt.add(created.expectedDuration),
          );
        }
        await refresh();
      },
    );
  }

  Future<LogEntry?> resolve(LogStatus status, {String? reason}) async {
    return LoggerService.instance.traceAsync<LogEntry?>(
      event: 'ActiveSessionResolve',
      tag: FeatureTag.userAction,
      context: {'status': status.name, 'reason': reason},
      operation: () async {
        final resolved = await _resolveUseCase(
          resolution: status,
          reason: reason,
        );
        if (resolved != null) {
          await _notifications.cancelSessionNotifications(resolved.id);
        }
        await refresh();
        return resolved;
      },
    );
  }

  Future<LogEntry?> resume(String pausedSessionId) {
    return LoggerService.instance.traceAsync<LogEntry?>(
      event: 'ActiveSessionResume',
      tag: FeatureTag.userAction,
      context: {'pausedSessionId': pausedSessionId},
      operation: () async {
        final resumed = await _resumeUseCase(pausedSessionId);
        if (resumed != null) {
          await _notifications.scheduleHalfAlert(
            resumed.id,
            resumed.startedAt.add(
              Duration(minutes: (resumed.expectedDurationMinutes / 2).ceil()),
            ),
          );
          await _notifications.schedulePlannedAlert(
            resumed.id,
            resumed.startedAt.add(resumed.expectedDuration),
          );
        }
        await refresh();
        return resumed;
      },
    );
  }

  Future<void> markHalfShown() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'MarkHalfAlertShown',
      tag: FeatureTag.notification,
      operation: () async {
        final s = _active;
        if (s == null || s.halfAlertShown) {
          LoggerService.instance.log(
            level: LogLevel.debug,
            tag: FeatureTag.notification,
            event: 'MarkHalfAlertShownSkipped',
            message:
                'Half alert mark skipped due to missing/already-marked session.',
            context: {
              'activeSessionId': s?.id,
              'alreadyShown': s?.halfAlertShown,
            },
          );
          return;
        }
        await _repository.upsertLog(s.copyWith(halfAlertShown: true));
        await refresh();
      },
    );
  }

  Future<void> markPlannedShown() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'MarkPlannedAlertShown',
      tag: FeatureTag.notification,
      operation: () async {
        final s = _active;
        if (s == null || s.plannedAlertShown) {
          LoggerService.instance.log(
            level: LogLevel.debug,
            tag: FeatureTag.notification,
            event: 'MarkPlannedAlertShownSkipped',
            message:
                'Planned alert mark skipped due to missing/already-marked session.',
            context: {
              'activeSessionId': s?.id,
              'alreadyShown': s?.plannedAlertShown,
            },
          );
          return;
        }
        await _repository.upsertLog(s.copyWith(plannedAlertShown: true));
        await refresh();
      },
    );
  }

  bool get halfAlertDue {
    final s = _active;
    if (s == null || s.halfAlertShown) return false;
    final at = s.startedAt.add(
      Duration(minutes: (s.expectedDurationMinutes / 2).ceil()),
    );
    final due = !_now().isBefore(at);
    if (due) {
      LoggerService.instance.log(
        level: LogLevel.info,
        tag: FeatureTag.notification,
        event: 'HalfAlertDue',
        message: 'Half alert is due for active session.',
        context: {'sessionId': s.id, 'dueAt': at.toIso8601String()},
      );
    }
    return due;
  }

  bool get plannedAlertDue {
    final s = _active;
    if (s == null || s.plannedAlertShown) return false;
    final due = !_now().isBefore(s.startedAt.add(s.expectedDuration));
    if (due) {
      LoggerService.instance.log(
        level: LogLevel.info,
        tag: FeatureTag.notification,
        event: 'PlannedAlertDue',
        message: 'Planned alert is due for active session.',
        context: {'sessionId': s.id},
      );
    }
    return due;
  }

  void _syncTick() {
    _timer?.cancel();
    final s = _active;
    if (s == null) {
      _elapsed = Duration.zero;
      LoggerService.instance.log(
        level: LogLevel.debug,
        tag: FeatureTag.system,
        event: 'ActiveTickStopped',
        message: 'No active session; elapsed timer reset.',
      );
      return;
    }
    _elapsed = _now().difference(s.startedAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _now().difference(s.startedAt);
      notifyListeners();
    });
    LoggerService.instance.log(
      level: LogLevel.debug,
      tag: FeatureTag.system,
      event: 'ActiveTickStarted',
      message: 'Active session timer synchronized.',
      context: {'sessionId': s.id, 'elapsedMs': _elapsed.inMilliseconds},
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'ActiveSessionControllerDispose',
      message: 'ActiveSessionController disposed and timer canceled.',
    );
    super.dispose();
  }
}
