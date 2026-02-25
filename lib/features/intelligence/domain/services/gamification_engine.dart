import '../../../logs/domain/log_entry.dart';

class GamificationState {
  const GamificationState({
    required this.points,
    required this.level,
    required this.badges,
  });

  final int points;
  final int level;
  final List<String> badges;
}

class GamificationEngine {
  GamificationState compute(List<LogEntry> logs) {
    var points = 0;
    final badges = <String>[];

    for (final log in logs) {
      if (log.status == LogStatus.completed) {
        points += 10;
      }
      if (log.status == LogStatus.paused) {
        points += 3;
      }
      if (log.status == LogStatus.abandoned) {
        points -= 2;
      }
      if (log.parentId != null && log.status == LogStatus.completed) {
        points += 4;
      }
    }

    final streakLike = logs
        .where((e) => e.status == LogStatus.completed)
        .length;
    if (streakLike >= 10) {
      badges.add('Consistency Builder');
    }
    if (points >= 200) {
      badges.add('Focus Athlete');
    }
    if (logs.where((e) => e.status == LogStatus.abandoned).isEmpty &&
        logs.isNotEmpty) {
      badges.add('Zero-Abandon Week');
    }

    final level = (points / 100).floor() + 1;
    return GamificationState(points: points, level: level, badges: badges);
  }
}
