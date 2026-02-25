import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../intelligence/domain/models/coach_recommendation.dart';
import '../../intelligence/domain/models/plan_block.dart';
import '../../intelligence/domain/models/weekly_report.dart';
import '../domain/log_entry.dart';
import '../domain/services/invariant_repair_engine.dart';
import 'isar_models.dart';
import 'log_repository.dart';

class RepairEvent {
  const RepairEvent(this.sessionId, this.reason);
  final String sessionId;
  final String reason;
}

class IsarLogRepository implements LogRepository {
  IsarLogRepository({this.now = _defaultNow});

  static const int currentSchemaVersion = 3;
  static const String _legacyStorageKey = 'behavior_logs';
  static const String _exportSchemaVersionKey = 'schemaVersion';

  static DateTime _defaultNow() => DateTime.now();

  final DateTime Function() now;
  Isar? _isar;
  final List<RepairEvent> _repairEvents = <RepairEvent>[];

  List<RepairEvent> get repairEvents => List.unmodifiable(_repairEvents);

  Future<void> initialize() async {
    if (_isar != null && _isar!.isOpen) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        SessionEntitySchema,
        AppMetaEntitySchema,
        DailyAnalyticsEntitySchema,
        CoachRecommendationEntitySchema,
        PlanBlockEntitySchema,
        WeeklyReportEntitySchema,
        GamificationProfileEntitySchema,
        ExperimentEntitySchema,
        BackupSnapshotEntitySchema,
      ],
      directory: dir.path,
      name: 'behavior_os',
      inspector: false,
    );
    await _runMigrations();
    await _runInvariantRepair();
  }

  Future<void> _runMigrations() async {
    final isar = _isar!;
    var meta = await isar.appMetaEntitys.get(1);
    meta ??= AppMetaEntity()
      ..id = 1
      ..schemaVersion = 1
      ..sharedPrefsImported = false;

    if (!meta.sharedPrefsImported) {
      final prefs = await SharedPreferences.getInstance();
      final rawLogs = prefs.getStringList(_legacyStorageKey) ?? <String>[];
      final migrated = <LogEntry>[];
      for (final raw in rawLogs) {
        try {
          migrated.add(LogEntry.fromJson(raw));
        } catch (_) {}
      }
      if (migrated.isNotEmpty) {
        await upsertLogs(migrated);
      }
      meta.sharedPrefsImported = true;
      await prefs.remove(_legacyStorageKey);
    }

    if (meta.schemaVersion < currentSchemaVersion) {
      meta.schemaVersion = currentSchemaVersion;
    }

    await isar.writeTxn(() async {
      await isar.appMetaEntitys.put(meta!);
      final profile = await isar.gamificationProfileEntitys.get(1);
      if (profile == null) {
        final created = GamificationProfileEntity()
          ..id = 1
          ..points = 0
          ..level = 1
          ..currentStreak = 0
          ..badgesCsv = ''
          ..updatedAt = now();
        await isar.gamificationProfileEntitys.put(created);
      }
    });
  }

  Future<void> _runInvariantRepair() async {
    _repairEvents.clear();
    final logs = await loadLogs();
    if (logs.isEmpty) return;
    final result = InvariantRepairEngine(now: now).repair(logs);
    for (final event in result.events) {
      _repairEvents.add(RepairEvent('system', event));
    }
    await upsertLogs(result.logs);
  }

  @override
  Future<List<LogEntry>> loadLogs() async {
    await initialize();
    final rows = await _isar!.sessionEntitys.where().findAll();
    return rows.map(_fromEntity).toList();
  }

  @override
  Future<void> upsertLog(LogEntry log) async {
    await initialize();
    await _isar!.writeTxn(() async {
      await _isar!.sessionEntitys.put(_toEntity(log));
    });
  }

  @override
  Future<void> upsertLogs(List<LogEntry> logs) async {
    await initialize();
    final entities = logs.map(_toEntity).toList();
    await _isar!.writeTxn(() async {
      await _isar!.sessionEntitys.putAll(entities);
    });
  }

  @override
  Future<void> deleteAll() async {
    await initialize();
    await _isar!.writeTxn(() async {
      await _isar!.sessionEntitys.clear();
      await _isar!.dailyAnalyticsEntitys.clear();
      await _isar!.coachRecommendationEntitys.clear();
      await _isar!.planBlockEntitys.clear();
      await _isar!.weeklyReportEntitys.clear();
    });
  }

  Future<String> exportJson() async {
    final sessions = await loadLogs();
    return jsonEncode({
      _exportSchemaVersionKey: currentSchemaVersion,
      'sessions': sessions.map((s) => s.toMap()).toList(),
    });
  }

  Future<String> exportCsv() async {
    final sessions = await loadLogs();
    final header =
        'id,label,kind,startedAt,endedAt,expectedDurationMinutes,status,parentId,transitionCategory,abandonmentReason,halfAlertShown,plannedAlertShown,schemaVersion,tags,experimentId';
    final lines = sessions.map((s) {
      String esc(String? raw) => '"${(raw ?? '').replaceAll('"', '""')}"';
      return [
        esc(s.id),
        esc(s.label),
        esc(s.kind.name),
        esc(s.startedAt.toIso8601String()),
        esc(s.endedAt?.toIso8601String()),
        s.expectedDurationMinutes,
        esc(s.status.name),
        esc(s.parentId),
        esc(s.transitionCategory?.name),
        esc(s.abandonmentReason),
        s.halfAlertShown,
        s.plannedAlertShown,
        s.schemaVersion,
        esc(s.tags.join('|')),
        esc(s.experimentId),
      ].join(',');
    });
    return '$header\n${lines.join('\n')}';
  }

  Future<void> importJson(String payload) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final sessions = (data['sessions'] as List<dynamic>)
        .map((e) => LogEntry.fromMap(e as Map<String, dynamic>))
        .toList();

    final existing = await loadLogs();
    final merged = <String, LogEntry>{for (final log in existing) log.id: log};
    for (final incoming in sessions) {
      final current = merged[incoming.id];
      if (current == null ||
          (incoming.endedAt ?? incoming.startedAt).isAfter(
            current.endedAt ?? current.startedAt,
          )) {
        merged[incoming.id] = incoming;
      }
    }
    await upsertLogs(merged.values.toList());
    await _runInvariantRepair();
  }

  Future<File> saveExportToFile({
    required String fileName,
    required String content,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    return file.writeAsString(content);
  }

  Future<void> saveCoachRecommendations(List<CoachRecommendation> items) async {
    await initialize();
    await _isar!.writeTxn(() async {
      final entities = items.map((e) {
        return CoachRecommendationEntity()
          ..id = e.id
          ..createdAt = now()
          ..title = e.title
          ..body = e.body
          ..priority = e.priority
          ..acknowledged = e.acknowledged;
      }).toList();
      await _isar!.coachRecommendationEntitys.putAll(entities);
    });
  }

  Future<List<CoachRecommendation>> loadCoachRecommendations() async {
    await initialize();
    final rows = await _isar!.coachRecommendationEntitys.where().findAll();
    return rows
        .map(
          (e) => CoachRecommendation(
            id: e.id,
            title: e.title,
            body: e.body,
            priority: e.priority,
            acknowledged: e.acknowledged,
          ),
        )
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  Future<void> savePlanBlocks(String dayKey, List<PlanBlock> blocks) async {
    await initialize();
    await _isar!.writeTxn(() async {
      await _isar!.planBlockEntitys.filter().dayKeyEqualTo(dayKey).deleteAll();
      await _isar!.planBlockEntitys.putAll(
        blocks.map((b) {
          return PlanBlockEntity()
            ..id = b.id
            ..dayKey = dayKey
            ..label = b.label
            ..durationMinutes = b.durationMinutes
            ..startHour = b.startHour
            ..startMinute = b.startMinute
            ..completed = b.completed;
        }).toList(),
      );
    });
  }

  Future<List<PlanBlock>> loadPlanBlocks(String dayKey) async {
    await initialize();
    final rows = await _isar!.planBlockEntitys
        .filter()
        .dayKeyEqualTo(dayKey)
        .findAll();
    return rows
        .map(
          (e) => PlanBlock(
            id: e.id,
            label: e.label,
            durationMinutes: e.durationMinutes,
            startHour: e.startHour,
            startMinute: e.startMinute,
            completed: e.completed,
          ),
        )
        .toList();
  }

  Future<void> saveWeeklyReport(WeeklyReport report) async {
    await initialize();
    await _isar!.writeTxn(() async {
      final e = WeeklyReportEntity()
        ..weekKey = report.weekKey
        ..summary = report.summary
        ..totalSessions = report.totalSessions
        ..avgFocus = report.averageFocus
        ..chartPointsCsv = report.chartPoints.join(',')
        ..generatedAt = now();
      await _isar!.weeklyReportEntitys.put(e);
    });
  }

  Future<WeeklyReport?> loadWeeklyReport(String weekKey) async {
    await initialize();
    final row = await _isar!.weeklyReportEntitys.getByWeekKey(weekKey);
    if (row == null) return null;
    return WeeklyReport(
      weekKey: row.weekKey,
      summary: row.summary,
      totalSessions: row.totalSessions,
      averageFocus: row.avgFocus,
      chartPoints: row.chartPointsCsv
          .split(',')
          .where((e) => e.isNotEmpty)
          .map(int.parse)
          .toList(),
    );
  }

  Future<void> saveAnalyticsSnapshot({
    required String key,
    required int focus,
    required double interruption,
    required double reaction,
    required int driftMinutes,
    required int streak,
  }) async {
    await initialize();
    await _isar!.writeTxn(() async {
      final row = DailyAnalyticsEntity()
        ..key = key
        ..focusScore = focus
        ..interruptionDensity = interruption
        ..reactionRatio = reaction
        ..driftMinutes = driftMinutes
        ..streak = streak
        ..updatedAt = now();
      await _isar!.dailyAnalyticsEntitys.put(row);
    });
  }

  Future<void> saveGamification({
    required int points,
    required int level,
    required int streak,
    required List<String> badges,
  }) async {
    await initialize();
    await _isar!.writeTxn(() async {
      final row = GamificationProfileEntity()
        ..id = 1
        ..points = points
        ..level = level
        ..currentStreak = streak
        ..badgesCsv = badges.join('|')
        ..updatedAt = now();
      await _isar!.gamificationProfileEntitys.put(row);
    });
  }

  Future<GamificationProfileEntity?> loadGamification() async {
    await initialize();
    return _isar!.gamificationProfileEntitys.get(1);
  }

  Future<void> upsertExperiment({
    required String id,
    required String name,
    required String hypothesis,
    required String variantA,
    required String variantB,
    required bool active,
  }) async {
    await initialize();
    await _isar!.writeTxn(() async {
      final e = ExperimentEntity()
        ..id = id
        ..name = name
        ..hypothesis = hypothesis
        ..variantA = variantA
        ..variantB = variantB
        ..active = active
        ..createdAt = now();
      await _isar!.experimentEntitys.put(e);
    });
  }

  Future<List<ExperimentEntity>> loadExperiments() async {
    await initialize();
    return _isar!.experimentEntitys.where().findAll();
  }

  Future<void> createBackupSnapshot() async {
    final payload = await exportJson();
    await initialize();
    await _isar!.writeTxn(() async {
      final snap = BackupSnapshotEntity()
        ..id = 'snapshot_${now().millisecondsSinceEpoch}'
        ..createdAt = now()
        ..payloadJson = payload;
      await _isar!.backupSnapshotEntitys.put(snap);
    });
  }

  Future<bool> runIntegrityCheck() async {
    final logs = await loadLogs();
    final ids = <String>{};
    for (final log in logs) {
      if (ids.contains(log.id)) return false;
      ids.add(log.id);
      if (log.status != LogStatus.active && log.endedAt == null) return false;
    }
    return true;
  }

  SessionEntity _toEntity(LogEntry log) {
    return SessionEntity()
      ..id = log.id
      ..label = log.label
      ..kind = log.kind.name
      ..startedAt = log.startedAt
      ..expectedDurationMinutes = log.expectedDurationMinutes
      ..status = log.status.name
      ..parentId = log.parentId
      ..endedAt = log.endedAt
      ..transitionCategory = log.transitionCategory?.name
      ..abandonmentReason = log.abandonmentReason
      ..halfAlertShown = log.halfAlertShown
      ..plannedAlertShown = log.plannedAlertShown
      ..schemaVersion = log.schemaVersion
      ..tagsCsv = log.tags.join('|')
      ..experimentId = log.experimentId;
  }

  LogEntry _fromEntity(SessionEntity e) {
    return LogEntry(
      id: e.id,
      label: e.label,
      kind: BehaviorKind.values.firstWhere((k) => k.name == e.kind),
      startedAt: e.startedAt,
      expectedDurationMinutes: e.expectedDurationMinutes,
      status: LogStatus.values.firstWhere((s) => s.name == e.status),
      schemaVersion: e.schemaVersion,
      endedAt: e.endedAt,
      parentId: e.parentId,
      transitionCategory: e.transitionCategory == null
          ? null
          : TransitionCategory.values.firstWhere(
              (c) => c.name == e.transitionCategory,
            ),
      abandonmentReason: e.abandonmentReason,
      halfAlertShown: e.halfAlertShown,
      plannedAlertShown: e.plannedAlertShown,
      tags: (e.tagsCsv ?? '').isEmpty
          ? const <String>[]
          : e.tagsCsv!.split('|'),
      experimentId: e.experimentId,
    );
  }
}
