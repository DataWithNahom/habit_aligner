import 'package:flutter/foundation.dart';

import '../../../../core/logging/logger_service.dart';
import '../../data/log_repository.dart';
import '../../domain/use_cases/compute_focus_score_use_case.dart';
import '../../domain/use_cases/compute_streak_use_case.dart';

class MetricsSnapshot {
  const MetricsSnapshot({
    required this.focusScore,
    required this.interruptionDensity,
    required this.reactionRatio,
    required this.driftDuration,
    required this.streak,
  });

  final int focusScore;
  final double interruptionDensity;
  final double reactionRatio;
  final Duration driftDuration;
  final int streak;
}

class MetricsController extends ChangeNotifier {
  MetricsController({required LogRepository repository})
    : _repository = repository;

  final LogRepository _repository;
  final _focus = ComputeFocusScoreUseCase();
  final _streak = ComputeStreakUseCase();

  DateTime? _cachedDay;
  MetricsSnapshot _cached = const MetricsSnapshot(
    focusScore: 0,
    interruptionDensity: 0,
    reactionRatio: 0,
    driftDuration: Duration.zero,
    streak: 0,
  );

  MetricsSnapshot get snapshot => _cached;

  Future<void> refresh({bool force = false}) async {
    await LoggerService.instance.traceAsync<void>(
      event: 'MetricsRefresh',
      tag: FeatureTag.system,
      context: {'force': force},
      operation: () async {
        final day = DateTime.now();
        final key = DateTime(day.year, day.month, day.day);
        if (!force && _cachedDay == key) {
          LoggerService.instance.log(
            level: LogLevel.debug,
            tag: FeatureTag.system,
            event: 'MetricsRefreshSkipped',
            message: 'Metrics refresh skipped due to cache hit.',
            context: {'cachedDay': _cachedDay?.toIso8601String()},
          );
          return;
        }

        final sessions = await _repository.loadLogs();
        final today = sessions
            .where(
              (s) =>
                  s.startedAt.year == key.year &&
                  s.startedAt.month == key.month &&
                  s.startedAt.day == key.day,
            )
            .toList();
        final focus = _focus(today);
        final streak = _streak(sessions);

        _cached = MetricsSnapshot(
          focusScore: focus.score,
          interruptionDensity: focus.interruptionDensity,
          reactionRatio: focus.reactionRatio,
          driftDuration: Duration(minutes: focus.driftPenaltyMinutes),
          streak: streak,
        );
        _cachedDay = key;
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.system,
          event: 'MetricsUpdated',
          message: 'Metrics snapshot recalculated.',
          context: {
            'focusScore': _cached.focusScore,
            'interruptionDensity': _cached.interruptionDensity,
            'reactionRatio': _cached.reactionRatio,
            'driftDurationMs': _cached.driftDuration.inMilliseconds,
            'streak': _cached.streak,
          },
        );
        notifyListeners();
      },
    );
  }

  void invalidate() {
    _cachedDay = null;
    LoggerService.instance.log(
      level: LogLevel.debug,
      tag: FeatureTag.system,
      event: 'MetricsCacheInvalidated',
      message: 'Metrics cache invalidated.',
    );
  }
}
