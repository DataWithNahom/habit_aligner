import '../../../logs/domain/log_entry.dart';
import '../models/coach_recommendation.dart';

class CoachEngine {
  List<CoachRecommendation> build(List<LogEntry> logs) {
    final now = DateTime.now();
    final today = logs
        .where(
          (e) =>
              e.startedAt.year == now.year &&
              e.startedAt.month == now.month &&
              e.startedAt.day == now.day,
        )
        .toList();
    final recommendations = <CoachRecommendation>[];

    final drift = today
        .where(
          (e) =>
              e.kind == BehaviorKind.drift || e.status == LogStatus.abandoned,
        )
        .length;
    if (drift >= 2) {
      recommendations.add(
        const CoachRecommendation(
          id: 'coach_drift_split',
          title: 'High drift risk detected',
          body: 'Try a 25+5 split for the next deep-work block.',
          priority: 10,
        ),
      );
    }

    final avgMinutes = today
        .where((e) => e.endedAt != null)
        .map((e) => e.actualDuration.inMinutes)
        .toList();
    if (avgMinutes.isNotEmpty) {
      final avg = avgMinutes.reduce((a, b) => a + b) / avgMinutes.length;
      recommendations.add(
        CoachRecommendation(
          id: 'coach_duration_${avg.round()}',
          title: 'Tune your block length',
          body:
              'Your average block is ${avg.round()} min. Set next block around ${(avg * .8).round()} min.',
          priority: 8,
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        const CoachRecommendation(
          id: 'coach_default',
          title: 'Momentum is healthy',
          body: 'Keep current rhythm and schedule one short recovery break.',
          priority: 5,
        ),
      );
    }

    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }
}
