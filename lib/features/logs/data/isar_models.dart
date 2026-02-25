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
}

@collection
class AppMetaEntity {
  Id id = 1;
  late int schemaVersion;
  late bool sharedPrefsImported;
}
