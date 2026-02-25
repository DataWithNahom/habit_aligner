import 'intention_session.dart';

class BehavioralMetrics {
  const BehavioralMetrics({
    required this.commitmentIntegrityScore,
    required this.deviationFrequency,
    required this.averageTimeToFirstDrift,
    required this.completionIntegrityPercent,
    required this.voluntarySwitches,
    required this.impulseFrequency,
  });

  final double commitmentIntegrityScore;
  final double deviationFrequency;
  final Duration averageTimeToFirstDrift;
  final double completionIntegrityPercent;
  final int voluntarySwitches;
  final int impulseFrequency;
}

class BehavioralMetricsCalculator {
  const BehavioralMetricsCalculator();

  BehavioralMetrics compute(List<IntentionSession> sessions) {
    if (sessions.isEmpty) {
      return const BehavioralMetrics(
        commitmentIntegrityScore: 1,
        deviationFrequency: 0,
        averageTimeToFirstDrift: Duration.zero,
        completionIntegrityPercent: 0,
        voluntarySwitches: 0,
        impulseFrequency: 0,
      );
    }

    final totalSessions = sessions.length;
    final defendedSessions = sessions.where((s) => s.defended).length;
    final deviations = sessions.fold<int>(
      0,
      (sum, session) => sum + session.deviations.length,
    );

    final completed = sessions
        .where((s) => s.state == BehaviorState.completed)
        .length;
    final completedWithoutDrift = sessions
        .where((s) => s.state == BehaviorState.completed)
        .where((s) => s.deviations.isEmpty)
        .length;

    final drifts = sessions
        .map(
          (s) => s.deviations.isNotEmpty
              ? s.deviations.first.timestamp.difference(s.startedAt)
              : null,
        )
        .whereType<Duration>()
        .toList();

    final voluntarySwitches = sessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          session.deviations
              .where((d) => d.reasonType == DriftReasonType.voluntarySwitch)
              .length,
    );

    final impulseFrequency = sessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          session.deviations
              .where((d) => d.reasonType == DriftReasonType.avoidanceImpulse)
              .length,
    );

    final firstDriftAvg = drifts.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds:
                drifts.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/
                drifts.length,
          );

    return BehavioralMetrics(
      commitmentIntegrityScore: defendedSessions / totalSessions,
      deviationFrequency: deviations / totalSessions,
      averageTimeToFirstDrift: firstDriftAvg,
      completionIntegrityPercent: completed == 0
          ? 0
          : completedWithoutDrift / completed,
      voluntarySwitches: voluntarySwitches,
      impulseFrequency: impulseFrequency,
    );
  }
}
