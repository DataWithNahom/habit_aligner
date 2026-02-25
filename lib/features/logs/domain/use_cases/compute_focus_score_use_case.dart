import '../log_entry.dart';

class FocusScoreResult {
  const FocusScoreResult({
    required this.score,
    required this.interruptionDensity,
    required this.reactionRatio,
    required this.driftPenaltyMinutes,
  });

  final int score;
  final double interruptionDensity;
  final double reactionRatio;
  final int driftPenaltyMinutes;
}

class ComputeFocusScoreUseCase {
  FocusScoreResult call(List<LogEntry> sessions) {
    final resolved = sessions.where((s) => s.endedAt != null).toList();
    if (resolved.isEmpty) {
      return const FocusScoreResult(
        score: 0,
        interruptionDensity: 0,
        reactionRatio: 0,
        driftPenaltyMinutes: 0,
      );
    }

    var expected = 0.0;
    var actual = 0.0;
    var interruptions = 0;
    var reactive = 0;
    var driftMinutes = 0;

    for (final s in resolved) {
      expected += s.expectedDuration.inMinutes;
      actual += s.actualDuration.inMinutes;
      if (s.status == LogStatus.paused || s.status == LogStatus.abandoned) {
        interruptions++;
      }
      if (s.kind == BehaviorKind.correctiveStop ||
          s.kind == BehaviorKind.drift) {
        reactive++;
      }
      if (s.kind == BehaviorKind.drift) {
        driftMinutes += s.actualDuration.inMinutes;
      }
    }

    final adherence = actual == 0
        ? 0
        : (1 - ((actual - expected).abs() / actual)).clamp(0, 1).toDouble();
    final interruptionDensity = interruptions / resolved.length;
    final reactionRatio = reactive / resolved.length;
    final driftPenalty = (driftMinutes / (actual == 0 ? 1 : actual))
        .clamp(0, 1)
        .toDouble();

    // Weights are grounded in behavioral science:
    // 1) Plan adherence (35%): implementation-intention research shows plan execution supports executive stability.
    // 2) Interruption density (30%): attention residue literature shows frequent context breaks reduce cognitive depth.
    // 3) Reaction ratio (20%): self-regulation findings link reactive behavior with reduced proactive control.
    // 4) Drift duration (15%): fatigue/disengagement windows indicate longer drift correlates with cognitive depletion.
    final weighted =
        (adherence * 0.35) +
        ((1 - interruptionDensity) * 0.30) +
        ((1 - reactionRatio) * 0.20) +
        ((1 - driftPenalty) * 0.15);
    final score = (weighted * 100).round().clamp(0, 100);

    return FocusScoreResult(
      score: score,
      interruptionDensity: interruptionDensity,
      reactionRatio: reactionRatio,
      driftPenaltyMinutes: driftMinutes,
    );
  }
}
