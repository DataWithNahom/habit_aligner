import 'package:flutter/foundation.dart';

import '../../../../core/logging/logger_service.dart';
import '../../data/log_repository.dart';
import '../../domain/log_entry.dart';
import '../../domain/use_cases/drift_analysis_use_case.dart';

class TimelineController extends ChangeNotifier {
  TimelineController({required LogRepository repository})
    : _repository = repository;

  final LogRepository _repository;
  final DriftAnalysisUseCase _driftAnalysis = DriftAnalysisUseCase();

  List<LogEntry> _todayTimeline = <LogEntry>[];
  List<DriftInsight> _insights = <DriftInsight>[];

  List<LogEntry> get todayTimeline => _todayTimeline;
  List<DriftInsight> get insights => _insights;

  Future<void> refresh() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'TimelineRefresh',
      tag: FeatureTag.system,
      operation: () async {
        final logs = await _repository.loadLogs();
        final now = DateTime.now();
        _todayTimeline =
            logs
                .where(
                  (log) =>
                      log.startedAt.year == now.year &&
                      log.startedAt.month == now.month &&
                      log.startedAt.day == now.day,
                )
                .toList()
              ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
        _insights = _driftAnalysis(logs);
        LoggerService.instance.log(
          level: LogLevel.info,
          tag: FeatureTag.system,
          event: 'TimelineUpdated',
          message: 'Timeline and drift insights recalculated.',
          context: {
            'timelineCount': _todayTimeline.length,
            'insightCount': _insights.length,
          },
        );
        notifyListeners();
      },
    );
  }
}
