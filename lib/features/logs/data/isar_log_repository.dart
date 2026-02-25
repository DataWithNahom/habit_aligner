import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/logger_service.dart';
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
    await LoggerService.instance.traceAsync<void>(
      event: 'RepositoryInitialize',
      tag: FeatureTag.database,
      operation: () async {
        if (_isar != null && _isar!.isOpen) {
          LoggerService.instance.log(
            level: LogLevel.debug,
            tag: FeatureTag.database,
            event: 'DatabaseOpenSkipped',
            message: 'Database already open, skipping re-open.',
          );
          return;
        }
        final dir = await getApplicationDocumentsDirectory();
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'DatabaseOpenAttempt',
          message: 'Opening Isar database.',
          context: {'directory': dir.path, 'name': 'behavior_os'},
        );
        _isar = await Isar.open(
          [SessionEntitySchema, AppMetaEntitySchema],
          directory: dir.path,
          name: 'behavior_os',
          inspector: false,
        );
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'DatabaseOpenSuccess',
          message: 'Isar database opened successfully.',
        );

        await _runMigrations();
        await _runInvariantRepair();
      },
    );
  }

  Future<void> _runMigrations() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'RunMigrations',
      tag: FeatureTag.database,
      operation: () async {
        final isar = _isar!;
        var meta = await isar.appMetaEntitys.get(1);
        meta ??= AppMetaEntity()
          ..id = 1
          ..schemaVersion = 1
          ..sharedPrefsImported = false;

        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'MigrationMetaLoaded',
          message: 'Loaded migration metadata.',
          context: {
            'schemaVersion': meta.schemaVersion,
            'sharedPrefsImported': meta.sharedPrefsImported,
          },
        );

        if (!meta.sharedPrefsImported) {
          final prefs = await SharedPreferences.getInstance();
          final rawLogs = prefs.getStringList(_legacyStorageKey) ?? <String>[];
          final migrated = <LogEntry>[];
          for (final raw in rawLogs) {
            try {
              migrated.add(LogEntry.fromJson(raw));
            } catch (error, stackTrace) {
              LoggerService.instance.log(
                level: LogLevel.warning,
                tag: FeatureTag.database,
                event: 'LegacyRowSkipped',
                message:
                    'Malformed legacy shared preferences row skipped during migration.',
                error: error,
                stackTrace: stackTrace,
              );
            }
          }
          if (migrated.isNotEmpty) {
            await upsertLogs(migrated);
          }
          meta.sharedPrefsImported = true;
          await prefs.remove(_legacyStorageKey);
          LoggerService.instance.log(
            level: LogLevel.info,
            tag: FeatureTag.database,
            event: 'LegacyImportComplete',
            message: 'Legacy shared preferences import completed.',
            context: {'importedRows': migrated.length},
          );
        }

        if (meta.schemaVersion < currentSchemaVersion) {
          for (var v = meta.schemaVersion + 1; v <= currentSchemaVersion; v++) {
            if (v == 2) {
              await _migrateToV2();
            }
            LoggerService.instance.log(
              level: LogLevel.info,
              tag: FeatureTag.database,
              event: 'MigrationStepApplied',
              message: 'Applied schema migration step.',
              context: {'toVersion': v},
            );
          }
          meta.schemaVersion = currentSchemaVersion;
        }

        final transactionId =
            'meta_write_${DateTime.now().microsecondsSinceEpoch}';
        await isar.writeTxn(() async {
          await isar.appMetaEntitys.put(meta!);
        });
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'MigrationMetaPersisted',
          message: 'Migration metadata persisted.',
          context: {
            'transactionId': transactionId,
            'schemaVersion': meta.schemaVersion,
          },
        );
      },
    );
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
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.database,
      event: 'MigrateToV2Prepared',
      message: 'Prepared records for schema v2 migration.',
      context: {'recordCount': upgraded.length},
    );
    await upsertLogs(upgraded);
  }

  Future<void> _runInvariantRepair() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'RunInvariantRepair',
      tag: FeatureTag.database,
      operation: () async {
        _repairEvents.clear();
        final logs = await loadLogs();
        if (logs.isEmpty) {
          LoggerService.instance.log(
            level: LogLevel.debug,
            tag: FeatureTag.database,
            event: 'InvariantRepairSkipped',
            message: 'No logs available for invariant repair.',
          );
          return;
        }

        final result = InvariantRepairEngine(now: now).repair(logs);
        for (final event in result.events) {
          _repairEvents.add(RepairEvent('system', event));
        }
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'InvariantRepairResult',
          message: 'Invariant repair executed.',
          context: {
            'eventCount': result.events.length,
            'logCount': result.logs.length,
          },
        );
        await upsertLogs(result.logs);
      },
    );
  }

  @override
  Future<List<LogEntry>> loadLogs() async {
    return LoggerService.instance.traceAsync<List<LogEntry>>(
      event: 'LoadLogs',
      tag: FeatureTag.database,
      operation: () async {
        await initialize();
        final rows = await _isar!.sessionEntitys.where().findAll();
        LoggerService.instance.log(
          level: LogLevel.debug,
          tag: FeatureTag.database,
          event: 'LoadLogsResult',
          message: 'Loaded logs from Isar.',
          context: {'collection': 'sessionEntitys', 'resultCount': rows.length},
        );
        return rows.map(_fromEntity).toList();
      },
    );
  }

  @override
  Future<void> upsertLog(LogEntry log) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'UpsertLog',
      tag: FeatureTag.database,
      context: {'collection': 'sessionEntitys', 'logId': log.id},
      operation: () async {
        await initialize();
        final isar = _isar!;
        final previous = await isar.sessionEntitys.getById(log.id);
        final entity = _toEntity(log);
        final transactionId = 'txn_${DateTime.now().microsecondsSinceEpoch}';
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'UpsertLogBefore',
          message: 'Preparing upsert for single log.',
          context: {
            'transactionId': transactionId,
            'before': previous == null ? null : _fromEntity(previous).toMap(),
            'after': log.toMap(),
          },
        );
        await isar.writeTxn(() async {
          await isar.sessionEntitys.put(entity);
        });
      },
    );
  }

  @override
  Future<void> upsertLogs(List<LogEntry> logs) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'UpsertLogsBatch',
      tag: FeatureTag.database,
      context: {'collection': 'sessionEntitys', 'count': logs.length},
      operation: () async {
        await initialize();
        final isar = _isar!;
        final entities = logs.map(_toEntity).toList();
        final transactionId =
            'txn_batch_${DateTime.now().microsecondsSinceEpoch}';
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'UpsertLogsBefore',
          message: 'Preparing batch upsert.',
          context: {
            'transactionId': transactionId,
            'afterIds': logs.map((e) => e.id).toList(),
          },
        );
        await isar.writeTxn(() async {
          await isar.sessionEntitys.putAll(entities);
        });
      },
    );
  }

  @override
  Future<void> deleteAll() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'DeleteAllLogs',
      tag: FeatureTag.database,
      context: {'collection': 'sessionEntitys'},
      operation: () async {
        await initialize();
        final before = await _isar!.sessionEntitys.count();
        final transactionId =
            'txn_delete_${DateTime.now().microsecondsSinceEpoch}';
        await _isar!.writeTxn(() async {
          await _isar!.sessionEntitys.clear();
        });
        LoggerService.instance.log(
          level: LogLevel.warning,
          tag: FeatureTag.database,
          event: 'DeleteAllCompleted',
          message: 'All session logs deleted.',
          context: {
            'transactionId': transactionId,
            'beforeCount': before,
            'afterCount': 0,
          },
        );
      },
    );
  }

  Future<String> exportJson() async {
    return LoggerService.instance.traceAsync<String>(
      event: 'ExportJson',
      tag: FeatureTag.database,
      operation: () async {
        final sessions = await loadLogs();
        final payload = jsonEncode({
          _exportSchemaVersionKey: currentSchemaVersion,
          'sessions': sessions.map((s) => s.toMap()).toList(),
        });
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'ExportJsonPrepared',
          message: 'JSON export payload prepared.',
          context: {'sessionCount': sessions.length, 'bytes': payload.length},
        );
        return payload;
      },
    );
  }

  Future<String> exportCsv() async {
    return LoggerService.instance.traceAsync<String>(
      event: 'ExportCsv',
      tag: FeatureTag.database,
      operation: () async {
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
        final payload = '$header\n${lines.join('\n')}';
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'ExportCsvPrepared',
          message: 'CSV export payload prepared.',
          context: {'sessionCount': sessions.length, 'bytes': payload.length},
        );
        return payload;
      },
    );
  }

  Future<void> importJson(String payload) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'ImportJson',
      tag: FeatureTag.database,
      context: {'bytes': payload.length},
      operation: () async {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final sessions = (data['sessions'] as List<dynamic>)
            .map((e) => LogEntry.fromMap(e as Map<String, dynamic>))
            .toList();
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'ImportJsonParsed',
          message: 'Parsed sessions from JSON import payload.',
          context: {'sessionCount': sessions.length},
        );
        await upsertLogs(sessions);
        await _runInvariantRepair();
      },
    );
  }

  Future<File> saveExportToFile({
    required String fileName,
    required String content,
  }) async {
    return LoggerService.instance.traceAsync<File>(
      event: 'SaveExportToFile',
      tag: FeatureTag.database,
      context: {'fileName': fileName, 'bytes': content.length},
      operation: () async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        final written = await file.writeAsString(content);
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.database,
          event: 'ExportFileWritten',
          message: 'Export payload written to local file.',
          context: {'path': file.path},
        );
        return written;
      },
    );
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
