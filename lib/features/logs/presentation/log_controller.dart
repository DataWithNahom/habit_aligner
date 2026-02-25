import 'package:flutter/material.dart';

import '../../../core/logging/logger_service.dart';
import '../../intelligence/domain/models/coach_recommendation.dart';
import '../../intelligence/domain/models/plan_block.dart';
import '../../intelligence/domain/models/weekly_report.dart';
import '../../intelligence/domain/services/adaptive_plan_builder.dart';
import '../../intelligence/domain/services/coach_engine.dart';
import '../../intelligence/domain/services/gamification_engine.dart';
import '../../intelligence/domain/services/weekly_report_builder.dart';
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

  final _coachEngine = CoachEngine();
  final _planBuilder = AdaptivePlanBuilder();
  final _weeklyBuilder = WeeklyReportBuilder();
  final _gamification = GamificationEngine();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<LogEntry> _logs = <LogEntry>[];
  List<LogEntry> get logs => List.unmodifiable(_logs);
  List<CoachRecommendation> _coachRecommendations = const [];
  List<CoachRecommendation> get coachRecommendations => _coachRecommendations;
  List<PlanBlock> _dailyPlan = const [];
  List<PlanBlock> get dailyPlan => _dailyPlan;
  WeeklyReport? _weeklyReport;
  WeeklyReport? get weeklyReport => _weeklyReport;
  int _points = 0;
  int get points => _points;
  int _level = 1;
  int get level => _level;
  List<String> _badges = const [];
  List<String> get badges => _badges;

  List<LogEntry> get resumablePausedLogs => List.unmodifiable(
    _logs.where((entry) => entry.status == LogStatus.paused).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
  );
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
    List<String> tags = const <String>[],
    String? experimentId,
  }) async {
    await _active.start(
      label: label,
      kind: kind,
      expectedDurationMinutes: expectedDurationMinutes,
      transitionCategory: transitionCategory,
      parentId: parentId,
      tags: tags,
      experimentId: experimentId,
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

  Future<void> resumePausedLog(String pausedSessionId) async {
    await _active.resume(pausedSessionId);
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

  Future<void> createDailyPlan() async {
    final today = _now();
    final dayKey = '${today.year}-${today.month}-${today.day}';
    final plan = _planBuilder.buildForDay(_logs, today);
    await _repository.savePlanBlocks(dayKey, plan);
    _dailyPlan = plan;
    notifyListeners();
  }

  Future<void> saveExperiment({
    required String name,
    required String hypothesis,
    required String variantA,
    required String variantB,
  }) async {
    await _repository.upsertExperiment(
      id: 'exp_${_now().millisecondsSinceEpoch}',
      name: name,
      hypothesis: hypothesis,
      variantA: variantA,
      variantB: variantB,
      active: true,
    );
    await _refreshAll();
  }

  Future<void> createBackup() async {
    await _repository.createBackupSnapshot();
  }

  Future<bool> runIntegrityCheck() => _repository.runIntegrityCheck();

  Future<void> _refreshAll({bool forceMetrics = false}) async {
    _logs = await _repository.loadLogs();
    await _active.refresh();
    if (forceMetrics) {
      _metrics.invalidate();
    }
    await _metrics.refresh(force: forceMetrics);
    await _timeline.refresh();

    _coachRecommendations = _coachEngine.build(_logs);
    await _repository.saveCoachRecommendations(_coachRecommendations);

    final today = _now();
    final dayKey = '${today.year}-${today.month}-${today.day}';
    _dailyPlan = await _repository.loadPlanBlocks(dayKey);
    if (_dailyPlan.isEmpty) {
      _dailyPlan = _planBuilder.buildForDay(_logs, today);
      await _repository.savePlanBlocks(dayKey, _dailyPlan);
    }

    final report = _weeklyBuilder.build(_logs, today, todayMetrics.focusScore);
    _weeklyReport = report;
    await _repository.saveWeeklyReport(report);

    final game = _gamification.compute(_logs);
    _points = game.points;
    _level = game.level;
    _badges = game.badges;
    await _repository.saveGamification(
      points: _points,
      level: _level,
      streak: todayMetrics.streak,
      badges: _badges,
    );

    final key = '${today.year}-${today.month}-${today.day}';
    await _repository.saveAnalyticsSnapshot(
      key: key,
      focus: todayMetrics.focusScore,
      interruption: todayMetrics.interruptionDensity,
      reaction: todayMetrics.reactionRatio,
      driftMinutes: todayMetrics.driftDuration.inMinutes,
      streak: todayMetrics.streak,
    );

    notifyListeners();
  }

  void _relay() {
    LoggerService.instance.log(
      level: LogLevel.debug,
      tag: FeatureTag.system,
      event: 'ControllerRelayNotify',
      message: 'Child controller emitted change notification.',
    );
    notifyListeners();
  }

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
