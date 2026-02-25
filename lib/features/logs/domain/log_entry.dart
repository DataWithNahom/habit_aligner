import 'dart:convert';

enum BehaviorKind { intentionalAction, correctiveStop, intentionalBreak, drift }

enum LogStatus { active, paused, completed, abandoned }

enum TransitionCategory {
  urgentImportant,
  importantNotUrgent,
  urgentNotImportant,
  neither,
}

class LogEntry {
  LogEntry({
    required this.id,
    required this.label,
    required this.kind,
    required this.startedAt,
    required this.expectedDurationMinutes,
    required this.status,
    required this.schemaVersion,
    this.endedAt,
    this.parentId,
    this.transitionCategory,
    this.abandonmentReason,
    this.halfAlertShown = false,
    this.plannedAlertShown = false,
  });

  final String id;
  final String label;
  final BehaviorKind kind;
  final DateTime startedAt;
  final int expectedDurationMinutes;
  final LogStatus status;
  final int schemaVersion;
  final DateTime? endedAt;
  final String? parentId;
  final TransitionCategory? transitionCategory;
  final String? abandonmentReason;
  final bool halfAlertShown;
  final bool plannedAlertShown;

  Duration get expectedDuration => Duration(minutes: expectedDurationMinutes);

  Duration get actualDuration {
    final end = endedAt ?? DateTime.now();
    final diff = end.difference(startedAt);
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isActive => status == LogStatus.active;

  LogEntry copyWith({
    LogStatus? status,
    DateTime? endedAt,
    String? abandonmentReason,
    bool? halfAlertShown,
    bool? plannedAlertShown,
    String? id,
    String? parentId,
    bool clearParentId = false,
  }) {
    return LogEntry(
      id: id ?? this.id,
      label: label,
      kind: kind,
      startedAt: startedAt,
      expectedDurationMinutes: expectedDurationMinutes,
      status: status ?? this.status,
      schemaVersion: schemaVersion,
      endedAt: endedAt ?? this.endedAt,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      transitionCategory: transitionCategory,
      abandonmentReason: abandonmentReason ?? this.abandonmentReason,
      halfAlertShown: halfAlertShown ?? this.halfAlertShown,
      plannedAlertShown: plannedAlertShown ?? this.plannedAlertShown,
    );
  }

  LogEntry complete(DateTime completedAt) {
    return copyWith(status: LogStatus.completed, endedAt: completedAt);
  }

  LogEntry pause(DateTime pausedAt) {
    return copyWith(status: LogStatus.paused, endedAt: pausedAt);
  }

  LogEntry abandon(DateTime abandonedAt, String reason) {
    return copyWith(
      status: LogStatus.abandoned,
      endedAt: abandonedAt,
      abandonmentReason: reason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'kind': kind.name,
      'startedAt': startedAt.toIso8601String(),
      'expectedDurationMinutes': expectedDurationMinutes,
      'status': status.name,
      'schemaVersion': schemaVersion,
      'endedAt': endedAt?.toIso8601String(),
      'parentId': parentId,
      'transitionCategory': transitionCategory?.name,
      'abandonmentReason': abandonmentReason,
      'halfAlertShown': halfAlertShown,
      'plannedAlertShown': plannedAlertShown,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    final id =
        _asString(map['id']) ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final label =
        _asString(map['label']) ??
        _asString(map['description']) ??
        'Unlabeled action';

    final startedAtRaw =
        _asString(map['startedAt']) ?? _asString(map['startTime']);
    final startedAt = _parseDateTime(startedAtRaw) ?? DateTime.now();

    final endedAtRaw = _asString(map['endedAt']) ?? _asString(map['endTime']);
    final endedAt = _parseDateTime(endedAtRaw);

    final kind = _parseBehaviorKind(map) ?? BehaviorKind.intentionalAction;

    final expectedDurationMinutes = _parseExpectedMinutes(
      map,
      endedAt,
      startedAt,
    );

    final status = _parseStatus(map, endedAt);

    final transitionCategory = _parseTransitionCategory(
      map['transitionCategory'],
    );

    return LogEntry(
      id: id,
      label: label,
      kind: kind,
      startedAt: startedAt,
      expectedDurationMinutes: expectedDurationMinutes,
      status: status,
      schemaVersion: (map['schemaVersion'] is int)
          ? map['schemaVersion'] as int
          : 1,
      endedAt: endedAt,
      parentId: _asString(map['parentId']),
      transitionCategory: transitionCategory,
      abandonmentReason: _asString(map['abandonmentReason']),
      halfAlertShown: map['halfAlertShown'] is bool
          ? map['halfAlertShown'] as bool
          : false,
      plannedAlertShown: map['plannedAlertShown'] is bool
          ? map['plannedAlertShown'] as bool
          : false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LogEntry.fromJson(String source) =>
      LogEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static String? _asString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static DateTime? _parseDateTime(String? source) {
    if (source == null) return null;
    return DateTime.tryParse(source);
  }

  static BehaviorKind? _parseBehaviorKind(Map<String, dynamic> map) {
    final kindName = _asString(map['kind']);
    if (kindName != null) {
      for (final item in BehaviorKind.values) {
        if (item.name == kindName) return item;
      }
    }

    final legacyType = _asString(map['type']);
    if (legacyType == 'stop') return BehaviorKind.correctiveStop;
    if (legacyType == 'start') return BehaviorKind.intentionalAction;
    return null;
  }

  static int _parseExpectedMinutes(
    Map<String, dynamic> map,
    DateTime? endedAt,
    DateTime startedAt,
  ) {
    final expectedRaw = map['expectedDurationMinutes'];
    if (expectedRaw is int && expectedRaw > 0) return expectedRaw;

    final durationSeconds = map['durationSeconds'];
    if (durationSeconds is int && durationSeconds > 0) {
      return (durationSeconds / 60).ceil();
    }

    if (endedAt != null) {
      final diffMinutes = endedAt.difference(startedAt).inMinutes;
      if (diffMinutes > 0) return diffMinutes;
    }

    return 30;
  }

  static LogStatus _parseStatus(Map<String, dynamic> map, DateTime? endedAt) {
    final statusName = _asString(map['status']);
    if (statusName != null) {
      for (final item in LogStatus.values) {
        if (item.name == statusName) return item;
      }
    }

    final legacyResolved = map['resolved'];
    if (legacyResolved is bool) {
      return legacyResolved ? LogStatus.completed : LogStatus.active;
    }

    return endedAt == null ? LogStatus.active : LogStatus.completed;
  }

  static TransitionCategory? _parseTransitionCategory(Object? raw) {
    final categoryName = _asString(raw);
    if (categoryName == null) return null;
    for (final item in TransitionCategory.values) {
      if (item.name == categoryName) return item;
    }
    return null;
  }
}
