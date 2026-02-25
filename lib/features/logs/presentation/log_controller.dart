import 'dart:async';

import 'package:flutter/material.dart';

import '../data/log_repository.dart';
import '../domain/log_entry.dart';

class LogController extends ChangeNotifier {
  LogController({required LogRepository repository}) : _repository = repository;

  final LogRepository _repository;

  final List<LogEntry> _logs = <LogEntry>[];
  Timer? _ticker;
  Duration _activeElapsed = Duration.zero;

  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  LogEntry? get activeLog {
    for (final log in _logs) {
      if (!log.resolved) return log;
    }
    return null;
  }

  Duration get activeElapsed => _activeElapsed;

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

  Future<void> createLog({
    required String description,
    required LogType type,
  }) async {
    if (activeLog != null) return;

    final created = LogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      description: description.trim(),
      type: type,
      startTime: DateTime.now(),
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

  void _syncTicker() {
    _ticker?.cancel();
    final current = activeLog;

    if (current == null) {
      _activeElapsed = Duration.zero;
      return;
    }

    _activeElapsed = DateTime.now().difference(current.startTime);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _activeElapsed = DateTime.now().difference(current.startTime);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // TODO(ai): add behavior pattern summaries once AI insights are integrated.
}
