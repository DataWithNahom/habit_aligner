import '../log_entry.dart';

class ComputeStreakUseCase {
  int call(
    List<LogEntry> sessions, {
    int minIntentionalMinutes = 20,
    double maxInterruptionDensity = 0.35,
  }) {
    if (sessions.isEmpty) return 0;
    final byDay = <DateTime, List<LogEntry>>{};
    for (final s in sessions.where((s) => s.endedAt != null)) {
      final key = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      byDay.putIfAbsent(key, () => <LogEntry>[]).add(s);
    }
    final days = byDay.keys.toList()..sort();
    if (days.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    while (true) {
      final daySessions = byDay[cursor];
      if (daySessions == null) break;
      final intentionalMinutes = daySessions
          .where((s) => s.kind == BehaviorKind.intentionalAction)
          .fold<int>(0, (sum, s) => sum + s.actualDuration.inMinutes);
      final abandoned = daySessions.any((s) => s.status == LogStatus.abandoned);
      final interruptions = daySessions
          .where(
            (s) =>
                s.status == LogStatus.paused || s.status == LogStatus.abandoned,
          )
          .length;
      final density = daySessions.isEmpty
          ? 1.0
          : interruptions / daySessions.length;
      if (intentionalMinutes >= minIntentionalMinutes &&
          !abandoned &&
          density <= maxInterruptionDensity) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
