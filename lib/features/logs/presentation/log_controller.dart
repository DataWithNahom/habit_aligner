import 'package:flutter/material.dart';

import '../data/isar_log_repository.dart';
import '../domain/log_entry.dart';
import '../domain/services/notification_scheduler.dart';
import 'controllers/active_session_controller.dart';
import 'controllers/alert_controller.dart';
import 'controllers/metrics_controller.dart';
import 'controllers/timeline_controller.dart';

class DailyMetrics {
  const DailyMetrics({
    required this.plannedVsActualAccuracy,
    required this.deviationFrequency,
    required this.driftDuration,
    required this.reactionRatio,
    required this.interruptionDensity,
    required this.focusScore,
    required this.streak,
  });

  final double plannedVsActualAccuracy;
  final double deviationFrequency;
  final Duration driftDuration;
  final double reactionRatio;
  final double interruptionDensity;
  final int focusScore;
  final int streak;
}

class LogController extends ChangeNotifier {
  LogController({
    required IsarLogRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _active = ActiveSessionController(
         repository: repository,
         now: now ?? DateTime.now,
         notifications: FlutterNotificationScheduler(),
       ),
       _metrics = MetricsController(repository: repository),
       _timeline = TimelineController(repository: repository),
       _now = now ?? DateTime.now {
    _alerts = AlertController(activeSession: _active);
    _active.addListener(_relay);
    _metrics.addListener(_relay);
    _timeline.addListener(_relay);
    _alerts.addListener(_relay);
  }

  final IsarLogRepository _repository;
  final ActiveSessionController _active;
  final MetricsController _metrics;
  final TimelineController _timeline;
  late final AlertController _alerts;
  final DateTime Function() _now;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<LogEntry> _logs = <LogEntry>[];
  List<LogEntry> get logs => List.unmodifiable(_logs);
  LogEntry? get activeLog => _active.active;
  Duration get activeElapsed => _active.elapsed;
  bool get halfTimeAlertDue => _alerts.halfDue;
  bool get plannedDurationAlertDue => _alerts.plannedDue;
  List<LogEntry> get todayTimeline => _timeline.todayTimeline;
  List<String> get driftInsights =>
      _timeline.insights.map((e) => e.message).toList();

  DailyMetrics get todayMetrics {
    final s = _metrics.snapshot;
    return DailyMetrics(
      plannedVsActualAccuracy: s.focusScore / 100,
      deviationFrequency: 1 - (s.focusScore / 100),
      driftDuration: s.driftDuration,
      reactionRatio: s.reactionRatio,
      interruptionDensity: s.interruptionDensity,
      focusScore: s.focusScore,
      streak: s.streak,
    );
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _repository.initialize();
    await _refreshAll(forceMetrics: true);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startLog({
    required String label,
    required BehaviorKind kind,
    required int expectedDurationMinutes,
    TransitionCategory? transitionCategory,
    String? parentId,
  }) async {
    await _active.start(
      label: label,
      kind: kind,
      expectedDurationMinutes: expectedDurationMinutes,
      transitionCategory: transitionCategory,
      parentId: parentId,
    );
    await _refreshAll(forceMetrics: true);
  }

  Future<void> completeActiveLog() async {
    await _active.resolve(LogStatus.completed);
    await _refreshAll(forceMetrics: true);
  }

  Future<void> pauseActiveLog() async {
    await _active.resolve(LogStatus.paused);
    await _refreshAll(forceMetrics: true);
  }

  Future<void> abandonActiveLog(String reason) async {
    await _active.resolve(LogStatus.abandoned, reason: reason);
    await _refreshAll(forceMetrics: true);
  }

  Future<void> dismissHalfTimeAlert() async {
    await _alerts.dismissHalf();
    await _refreshAll();
  }

  Future<void> dismissPlannedDurationAlert() async {
    await _alerts.dismissPlanned();
    await _refreshAll();
  }

  Future<void> exportJson() async {
    final payload = await _repository.exportJson();
    await _repository.saveExportToFile(
      fileName: 'behavior_os_export_${_now().millisecondsSinceEpoch}.json',
      content: payload,
    );
  }

  Future<void> exportCsv() async {
    final payload = await _repository.exportCsv();
    await _repository.saveExportToFile(
      fileName: 'behavior_os_export_${_now().millisecondsSinceEpoch}.csv',
      content: payload,
    );
  }

  Future<void> importJson(String payload) async {
    await _repository.importJson(payload);
    await _refreshAll(forceMetrics: true);
  }

  Future<void> _refreshAll({bool forceMetrics = false}) async {
    _logs = await _repository.loadLogs();
    await _active.refresh();
    if (forceMetrics) {
      _metrics.invalidate();
    }
    await _metrics.refresh(force: forceMetrics);
    await _timeline.refresh();
    notifyListeners();
  }

  void _relay() => notifyListeners();

  @override
  void dispose() {
    _active.removeListener(_relay);
    _metrics.removeListener(_relay);
    _timeline.removeListener(_relay);
    _alerts.removeListener(_relay);
    _alerts.dispose();
    _active.dispose();
    _metrics.dispose();
    _timeline.dispose();
    super.dispose();
  }
}
