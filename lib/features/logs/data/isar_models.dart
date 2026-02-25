import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class SessionEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String label;
  late String kind;
  late DateTime startedAt;
  late int expectedDurationMinutes;
  @Index()
  late String status;
  @Index()
  String? parentId;
  DateTime? endedAt;
  String? transitionCategory;
  String? abandonmentReason;
  late bool halfAlertShown;
  late bool plannedAlertShown;
  late int schemaVersion;
  String? tagsCsv;
  String? experimentId;
}

@collection
class AppMetaEntity {
  Id id = 1;
  late int schemaVersion;
  late bool sharedPrefsImported;
}

@collection
class DailyAnalyticsEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key; // yyyy-mm-dd

  late int focusScore;
  late double interruptionDensity;
  late double reactionRatio;
  late int driftMinutes;
  late int streak;
  late DateTime updatedAt;
}

@collection
class CoachRecommendationEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late DateTime createdAt;
  late String title;
  late String body;
  late int priority;
  late bool acknowledged;
}

@collection
class PlanBlockEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String dayKey;

  late String label;
  late int durationMinutes;
  late int startHour;
  late int startMinute;
  late bool completed;
}

@collection
class WeeklyReportEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String weekKey;

  late String summary;
  late int totalSessions;
  late int avgFocus;
  late String chartPointsCsv;
  late DateTime generatedAt;
}

@collection
class GamificationProfileEntity {
  Id id = 1;
  late int points;
  late int level;
  late int currentStreak;
  late String badgesCsv;
  late DateTime updatedAt;
}

@collection
class ExperimentEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  late String hypothesis;
  late String variantA;
  late String variantB;
  late bool active;
  late DateTime createdAt;
}

@collection
class BackupSnapshotEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late DateTime createdAt;
  late String payloadJson;
}
