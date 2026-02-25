import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/log_repository.dart';
import '../../domain/log_entry.dart';
import '../../domain/services/notification_scheduler.dart';
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
       _notifications = notifications,
       _now = now {
    _notifications.initialize();
  }

  final LogRepository _repository;
  final StartSessionUseCase _startUseCase;
  final ResolveSessionUseCase _resolveUseCase;
  final NotificationScheduler _notifications;
  final DateTime Function() _now;

  LogEntry? _active;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  LogEntry? get active => _active;
  Duration get elapsed => _elapsed;

  Future<void> refresh() async {
    final logs = await _repository.loadLogs();
    _active = logs
        .where((e) => e.isActive)
        .cast<LogEntry?>()
        .firstWhere((e) => e != null, orElse: () => null);
    _syncTick();
    notifyListeners();
  }

  Future<void> start({
    required String label,
    required BehaviorKind kind,
    required int expectedDurationMinutes,
    TransitionCategory? transitionCategory,
    String? parentId,
  }) async {
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
  }

  Future<LogEntry?> resolve(LogStatus status, {String? reason}) async {
    final resolved = await _resolveUseCase(resolution: status, reason: reason);
    if (resolved != null) {
      await _notifications.cancelSessionNotifications(resolved.id);
    }
    await refresh();
    return resolved;
  }

  Future<void> markHalfShown() async {
    final s = _active;
    if (s == null || s.halfAlertShown) return;
    await _repository.upsertLog(s.copyWith(halfAlertShown: true));
    await refresh();
  }

  Future<void> markPlannedShown() async {
    final s = _active;
    if (s == null || s.plannedAlertShown) return;
    await _repository.upsertLog(s.copyWith(plannedAlertShown: true));
    await refresh();
  }

  bool get halfAlertDue {
    final s = _active;
    if (s == null || s.halfAlertShown) return false;
    final at = s.startedAt.add(
      Duration(minutes: (s.expectedDurationMinutes / 2).ceil()),
    );
    return !_now().isBefore(at);
  }

  bool get plannedAlertDue {
    final s = _active;
    if (s == null || s.plannedAlertShown) return false;
    return !_now().isBefore(s.startedAt.add(s.expectedDuration));
  }

  void _syncTick() {
    _timer?.cancel();
    final s = _active;
    if (s == null) {
      _elapsed = Duration.zero;
      return;
    }
    _elapsed = _now().difference(s.startedAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _now().difference(s.startedAt);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
