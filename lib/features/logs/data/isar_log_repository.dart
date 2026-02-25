import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const int currentSchemaVersion = 2;
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
      [SessionEntitySchema, AppMetaEntitySchema],
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
        } catch (_) {
          // Skip malformed rows from legacy storage.
        }
      }
      if (migrated.isNotEmpty) {
        await upsertLogs(migrated);
      }
      meta.sharedPrefsImported = true;
      await prefs.remove(_legacyStorageKey);
    }

    if (meta.schemaVersion < currentSchemaVersion) {
      for (var v = meta.schemaVersion + 1; v <= currentSchemaVersion; v++) {
        if (v == 2) {
          await _migrateToV2();
        }
      }
      meta.schemaVersion = currentSchemaVersion;
    }

    await isar.writeTxn(() async {
      await isar.appMetaEntitys.put(meta!);
    });
  }

  Future<void> _migrateToV2() async {
    final all = await loadLogs();
    final upgraded = all
        .map((e) => e.copyWith().copyWith())
        .map(
          (e) => LogEntry(
            id: e.id,
            label: e.label,
            kind: e.kind,
            startedAt: e.startedAt,
            expectedDurationMinutes: e.expectedDurationMinutes,
            status: e.status,
            schemaVersion: currentSchemaVersion,
            endedAt: e.endedAt,
            parentId: e.parentId,
            transitionCategory: e.transitionCategory,
            abandonmentReason: e.abandonmentReason,
            halfAlertShown: e.halfAlertShown,
            plannedAlertShown: e.plannedAlertShown,
          ),
        )
        .toList();
    await upsertLogs(upgraded);
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
    final isar = _isar!;
    final entity = _toEntity(log);
    await isar.writeTxn(() async {
      await isar.sessionEntitys.put(entity);
    });
  }

  @override
  Future<void> upsertLogs(List<LogEntry> logs) async {
    await initialize();
    final isar = _isar!;
    final entities = logs.map(_toEntity).toList();
    await isar.writeTxn(() async {
      await isar.sessionEntitys.putAll(entities);
    });
  }

  @override
  Future<void> deleteAll() async {
    await initialize();
    await _isar!.writeTxn(() async {
      await _isar!.sessionEntitys.clear();
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
        'id,label,kind,startedAt,endedAt,expectedDurationMinutes,status,parentId,transitionCategory,abandonmentReason,halfAlertShown,plannedAlertShown,schemaVersion';
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
      ].join(',');
    });
    return '$header\n${lines.join('\n')}';
  }

  Future<void> importJson(String payload) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final sessions = (data['sessions'] as List<dynamic>)
        .map((e) => LogEntry.fromMap(e as Map<String, dynamic>))
        .toList();
    await upsertLogs(sessions);
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
      ..schemaVersion = log.schemaVersion;
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
    );
  }
}
