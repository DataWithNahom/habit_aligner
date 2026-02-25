import 'dart:async';

import 'package:flutter/material.dart';

import '../data/log_repository.dart';
import '../domain/log_entry.dart';

class DailyMetrics {
  const DailyMetrics({
    required this.plannedVsActualAccuracy,
    required this.deviationFrequency,
    required this.driftDuration,
    required this.reactionRatio,
    required this.interruptionDensity,
  });

  final double plannedVsActualAccuracy;
  final double deviationFrequency;
  final Duration driftDuration;
  final double reactionRatio;
  final double interruptionDensity;
}

class LogController extends ChangeNotifier {
  LogController({required LogRepository repository}) : _repository = repository;

  final LogRepository _repository;

  final List<LogEntry> _logs = <LogEntry>[];
  Timer? _ticker;
  Duration _activeElapsed = Duration.zero;
  bool _halfTimeAlertDue = false;
  bool _plannedDurationAlertDue = false;

  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  LogEntry? get activeLog {
    for (final log in _logs) {
      if (log.isActive) return log;
    }
    return null;
  }

  Duration get activeElapsed => _activeElapsed;
  bool get halfTimeAlertDue => _halfTimeAlertDue;
  bool get plannedDurationAlertDue => _plannedDurationAlertDue;

  List<LogEntry> get todayTimeline {
    final now = DateTime.now();
    return _logs.where((log) {
      return log.startedAt.year == now.year &&
          log.startedAt.month == now.month &&
          log.startedAt.day == now.day;
    }).toList()..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  }

  DailyMetrics get todayMetrics {
    final items = todayTimeline.where((item) => item.endedAt != null).toList();
    if (items.isEmpty) {
      return const DailyMetrics(
        plannedVsActualAccuracy: 0,
        deviationFrequency: 0,
        driftDuration: Duration.zero,
        reactionRatio: 0,
        interruptionDensity: 0,
      );
    }

    var totalExpected = 0;
    var totalActual = 0;
    var deviations = 0;
    var reactive = 0;
    var intentional = 0;
    var interruptions = 0;
    var driftSeconds = 0;

    for (final item in items) {
      final actual = item.actualDuration.inSeconds;
      final expected = item.expectedDuration.inSeconds;
      totalActual += actual;
      totalExpected += expected;

      final difference = (actual - expected).abs();
      if (difference > 300) {
        deviations += 1;
      }

      if (item.kind == BehaviorKind.drift ||
          item.kind == BehaviorKind.correctiveStop) {
        reactive += 1;
      } else {
        intentional += 1;
      }

      if (item.status == LogStatus.paused ||
          item.status == LogStatus.abandoned) {
        interruptions += 1;
      }

      if (item.kind == BehaviorKind.drift) {
        driftSeconds += actual;
      }
    }

    final accuracy = totalActual == 0
        ? 0.0
        : 1 - ((totalActual - totalExpected).abs() / totalActual);

    return DailyMetrics(
      plannedVsActualAccuracy: accuracy.clamp(0.0, 1.0),
      deviationFrequency: deviations / items.length,
      driftDuration: Duration(seconds: driftSeconds),
      reactionRatio: items.isEmpty ? 0 : reactive / (reactive + intentional),
      interruptionDensity: interruptions / items.length,
    );
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final loaded = await _repository.loadLogs();
    _logs
      ..clear()
      ..addAll(loaded);
    _isLoading = false;
    _syncTicker();
    notifyListeners();
  }

  Future<void> startLog({
    required String label,
    required BehaviorKind kind,
    required int expectedDurationMinutes,
    TransitionCategory? transitionCategory,
    String? parentId,
  }) async {
    if (activeLog != null) return;

    final created = LogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label.trim(),
      kind: kind,
      startedAt: DateTime.now(),
      expectedDurationMinutes: expectedDurationMinutes,
      status: LogStatus.active,
      transitionCategory: transitionCategory,
      parentId: parentId,
    );

    _logs.insert(0, created);
    _syncTicker();
    notifyListeners();
    await _repository.saveLogs(_logs);
  }

  Future<void> completeActiveLog() async {
    final unresolved = activeLog;
    if (unresolved == null) return;

    final index = _logs.indexWhere((log) => log.id == unresolved.id);
    if (index == -1) return;

    _logs[index] = unresolved.complete(DateTime.now());
    _syncTicker();
    notifyListeners();
    await _repository.saveLogs(_logs);
  }

  Future<void> pauseActiveLog() async {
    final unresolved = activeLog;
    if (unresolved == null) return;

    final index = _logs.indexWhere((log) => log.id == unresolved.id);
    if (index == -1) return;

    _logs[index] = unresolved.pause(DateTime.now());
    _syncTicker();
    notifyListeners();
    await _repository.saveLogs(_logs);
  }

  Future<void> abandonActiveLog(String reason) async {
    final unresolved = activeLog;
    if (unresolved == null) return;

    final index = _logs.indexWhere((log) => log.id == unresolved.id);
    if (index == -1) return;

    _logs[index] = unresolved.abandon(DateTime.now(), reason.trim());
    _syncTicker();
    notifyListeners();
    await _repository.saveLogs(_logs);
  }

  void dismissHalfTimeAlert() {
    _halfTimeAlertDue = false;
    notifyListeners();
  }

  void dismissPlannedDurationAlert() {
    _plannedDurationAlertDue = false;
    notifyListeners();
  }

  void _syncTicker() {
    _ticker?.cancel();
    final current = activeLog;

    if (current == null) {
      _activeElapsed = Duration.zero;
      _halfTimeAlertDue = false;
      _plannedDurationAlertDue = false;
      return;
    }

    _activeElapsed = DateTime.now().difference(current.startedAt);
    _evaluateAlerts(current);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _activeElapsed = DateTime.now().difference(current.startedAt);
      _evaluateAlerts(current);
      notifyListeners();
    });
  }

  void _evaluateAlerts(LogEntry current) {
    final half = Duration(
      minutes: (current.expectedDurationMinutes / 2).ceil(),
    );
    if (!_halfTimeAlertDue && _activeElapsed >= half) {
      _halfTimeAlertDue = true;
    }

    if (!_plannedDurationAlertDue &&
        _activeElapsed >= current.expectedDuration) {
      _plannedDurationAlertDue = true;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
