import '../log_entry.dart';

class DriftInsight {
  const DriftInsight({required this.message});
  final String message;
}

class DriftAnalysisUseCase {
  List<DriftInsight> call(List<LogEntry> sessions) {
    final resolved = sessions.where((s) => s.endedAt != null).toList();
    if (resolved.isEmpty) {
      return const [
        DriftInsight(message: 'No drift patterns yet. Collect more sessions.'),
      ];
    }

    final driftByHour = <int, int>{};
    final timeToInterruptMinutes = <int>[];
    final abandonReasons = <String, int>{};

    for (final s in resolved) {
      if (s.kind == BehaviorKind.drift ||
          s.status == LogStatus.abandoned ||
          s.status == LogStatus.paused) {
        driftByHour[s.startedAt.hour] =
            (driftByHour[s.startedAt.hour] ?? 0) + 1;
        timeToInterruptMinutes.add(s.actualDuration.inMinutes);
      }
      if (s.status == LogStatus.abandoned) {
        final reason = (s.abandonmentReason?.trim().isNotEmpty ?? false)
            ? s.abandonmentReason!.trim()
            : 'unspecified';
        abandonReasons[reason] = (abandonReasons[reason] ?? 0) + 1;
      }
    }

    final worstHour = driftByHour.entries.isEmpty
        ? null
        : (driftByHour.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
    final avgInterrupt = timeToInterruptMinutes.isEmpty
        ? null
        : timeToInterruptMinutes.reduce((a, b) => a + b) /
              timeToInterruptMinutes.length;
    final topReason = abandonReasons.entries.isEmpty
        ? null
        : (abandonReasons.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    final insights = <DriftInsight>[];
    if (worstHour != null) {
      final bandStart = worstHour;
      final bandEnd = (worstHour + 2) % 24;
      insights.add(
        DriftInsight(
          message:
              'You are most likely to drift between ${_hourLabel(bandStart)}–${_hourLabel(bandEnd)}.',
        ),
      );
    }
    if (avgInterrupt != null) {
      insights.add(
        DriftInsight(
          message:
              'Interruptions increase after ${avgInterrupt.round()} minutes of work.',
        ),
      );
    }
    if (topReason != null) {
      insights.add(
        DriftInsight(message: 'Most common abandonment reason: $topReason.'),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        const DriftInsight(message: 'No drift signatures detected yet.'),
      );
    }

    return insights;
  }

  String _hourLabel(int hour) {
    final normalized = hour % 24;
    final suffix = normalized >= 12 ? 'PM' : 'AM';
    final twelve = normalized % 12 == 0 ? 12 : normalized % 12;
    return '$twelve $suffix';
  }
}
