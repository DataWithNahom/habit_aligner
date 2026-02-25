import '../../../logs/domain/log_entry.dart';

/// Deprecated: Behavioral Discipline Engine does not use points/levels/badges.
class GamificationState {
  const GamificationState({
    this.points = 0,
    this.level = 0,
    this.badges = const [],
  });

  final int points;
  final int level;
  final List<String> badges;
}

/// Legacy compatibility shim. Always returns neutral values.
class GamificationEngine {
  const GamificationEngine();

  GamificationState compute(List<LogEntry> logs) {
    return const GamificationState();
  }
}
