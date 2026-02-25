import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error, critical }

enum FeatureTag {
  ui,
  database,
  notification,
  navigation,
  lifecycle,
  init,
  userAction,
  system,
  async,
}

class LoggerService {
  LoggerService._();

  static final LoggerService instance = LoggerService._();

  static const int _inMemoryBufferLimit = 2000;
  static const int _maxLogFileBytes = 1024 * 1024;
  static const String _logFileName = 'habit_aligner.log';

  final List<String> _buffer = <String>[];
  final Stopwatch _sessionClock = Stopwatch()..start();
  int _sequenceId = 0;
  bool _initialized = false;
  bool _persistenceReady = false;
  bool _isFlushing = false;
  String? _currentRoute;
  File? _logFile;
  Future<void> _writeChain = Future<void>.value();
  final List<String> _pendingLines = <String>[];

  List<String> get inMemoryLogs => List.unmodifiable(_buffer);
  String? get currentRoute => _currentRoute;

  Future<void> initialize({required bool coldStart}) async {
    if (_initialized) {
      log(
        level: LogLevel.info,
        tag: FeatureTag.init,
        event: 'LoggerReinitializeAttempt',
        message:
            'Logger initialize called after initial setup; ignoring duplicate setup.',
        context: {'coldStart': coldStart},
      );
      return;
    }

    _initialized = true;
    await _preparePersistence();
    log(
      level: LogLevel.info,
      tag: FeatureTag.init,
      event: coldStart ? 'ColdStart' : 'WarmStart',
      message: 'Logger service initialized.',
      context: {
        'coldStart': coldStart,
        'releaseMode': kReleaseMode,
        'logPersistenceEnabled': _persistenceReady,
      },
    );
  }

  void setCurrentRoute(String? routeName) {
    _currentRoute = routeName;
  }

  void log({
    required LogLevel level,
    required FeatureTag tag,
    required String event,
    required String message,
    Map<String, Object?> context = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
    Duration? duration,
  }) {
    if (!_initialized && event != 'PreInitLog') {
      // Best-effort pre-init logging.
      _initialized = true;
    }

    if (kReleaseMode && level == LogLevel.debug) {
      return;
    }

    final id = ++_sequenceId;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final mergedContext = <String, Object?>{
      ...context,
      'route': _currentRoute,
      'sessionElapsedMs': _sessionClock.elapsedMilliseconds,
    };
    final serializedContext = jsonEncode(mergedContext);

    final buffer = StringBuffer()
      ..writeln(
        '[$timestamp] [${level.name.toUpperCase()}] [${tag.name.toUpperCase()}] [Event#$id] $event',
      )
      ..writeln('Message: $message')
      ..writeln('Context: $serializedContext');

    if (duration != null) {
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    }
    if (error != null) {
      buffer.writeln('Error: $error');
    }
    if (stackTrace != null) {
      buffer.writeln('StackTrace: $stackTrace');
    }

    final line = buffer.toString().trimRight();
    _buffer.add(line);
    if (_buffer.length > _inMemoryBufferLimit) {
      _buffer.removeRange(0, _buffer.length - _inMemoryBufferLimit);
    }

    debugPrint(line);

    if (_persistenceReady) {
      _pendingLines.add('$line\n');
      _scheduleFlush();
    }
  }

  Future<T> traceAsync<T>({
    required String event,
    required FeatureTag tag,
    required Future<T> Function() operation,
    Map<String, Object?> context = const <String, Object?>{},
  }) async {
    final sw = Stopwatch()..start();
    log(
      level: LogLevel.debug,
      tag: FeatureTag.async,
      event: '${event}Start',
      message: 'Async operation started.',
      context: {'tag': tag.name, ...context},
    );

    try {
      final result = await operation();
      sw.stop();
      log(
        level: LogLevel.info,
        tag: FeatureTag.async,
        event: '${event}Success',
        message: 'Async operation completed successfully.',
        context: {'tag': tag.name, ...context},
        duration: sw.elapsed,
      );
      return result;
    } catch (error, stackTrace) {
      sw.stop();
      log(
        level: LogLevel.error,
        tag: FeatureTag.async,
        event: '${event}Failure',
        message: 'Async operation failed.',
        context: {'tag': tag.name, ...context},
        error: error,
        stackTrace: stackTrace,
        duration: sw.elapsed,
      );
      rethrow;
    }
  }

  Future<void> _preparePersistence() async {
    if (kIsWeb) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
      }
      await _rotateIfNeeded();
      _persistenceReady = true;
    } catch (error, stackTrace) {
      _persistenceReady = false;
      log(
        level: LogLevel.warning,
        tag: FeatureTag.system,
        event: 'LogPersistenceUnavailable',
        message:
            'Log file persistence could not be initialized; continuing with in-memory buffer only.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _scheduleFlush() {
    if (_isFlushing) return;
    _isFlushing = true;
    unawaited(_flushPending());
  }

  Future<void> _flushPending() async {
    while (_pendingLines.isNotEmpty && _persistenceReady && _logFile != null) {
      final toWrite = List<String>.from(_pendingLines);
      _pendingLines.clear();
      _writeChain = _writeChain.then((_) async {
        await _rotateIfNeeded();
        await _logFile!.writeAsString(
          toWrite.join(),
          mode: FileMode.append,
          flush: true,
        );
      });
      await _writeChain;
    }
    _isFlushing = false;
  }

  Future<void> _rotateIfNeeded() async {
    if (_logFile == null || !await _logFile!.exists()) return;
    final length = await _logFile!.length();
    if (length < _maxLogFileBytes) return;

    final rotated = File('${_logFile!.path}.1');
    if (await rotated.exists()) {
      await rotated.delete();
    }
    await _logFile!.rename(rotated.path);
    _logFile = File(rotated.path.replaceFirst('.1', ''));
    await _logFile!.create(recursive: true);
  }
}
