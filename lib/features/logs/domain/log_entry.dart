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
    this.endedAt,
    this.parentId,
    this.transitionCategory,
    this.abandonmentReason,
  });

  final String id;
  final String label;
  final BehaviorKind kind;
  final DateTime startedAt;
  final int expectedDurationMinutes;
  final LogStatus status;
  final DateTime? endedAt;
  final String? parentId;
  final TransitionCategory? transitionCategory;
  final String? abandonmentReason;

  Duration get expectedDuration => Duration(minutes: expectedDurationMinutes);

  Duration get actualDuration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  bool get isActive => status == LogStatus.active;

  LogEntry complete(DateTime completedAt) {
    return _copyWith(status: LogStatus.completed, endedAt: completedAt);
  }

  LogEntry pause(DateTime pausedAt) {
    return _copyWith(status: LogStatus.paused, endedAt: pausedAt);
  }

  LogEntry abandon(DateTime abandonedAt, String reason) {
    return _copyWith(
      status: LogStatus.abandoned,
      endedAt: abandonedAt,
      abandonmentReason: reason,
    );
  }

  LogEntry _copyWith({
    LogStatus? status,
    DateTime? endedAt,
    String? abandonmentReason,
  }) {
    return LogEntry(
      id: id,
      label: label,
      kind: kind,
      startedAt: startedAt,
      expectedDurationMinutes: expectedDurationMinutes,
      status: status ?? this.status,
      endedAt: endedAt ?? this.endedAt,
      parentId: parentId,
      transitionCategory: transitionCategory,
      abandonmentReason: abandonmentReason ?? this.abandonmentReason,
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
      'endedAt': endedAt?.toIso8601String(),
      'parentId': parentId,
      'transitionCategory': transitionCategory?.name,
      'abandonmentReason': abandonmentReason,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as String,
      label: map['label'] as String,
      kind: BehaviorKind.values.firstWhere((item) => item.name == map['kind']),
      startedAt: DateTime.parse(map['startedAt'] as String),
      expectedDurationMinutes: map['expectedDurationMinutes'] as int,
      status: LogStatus.values.firstWhere((item) => item.name == map['status']),
      endedAt: map['endedAt'] == null
          ? null
          : DateTime.parse(map['endedAt'] as String),
      parentId: map['parentId'] as String?,
      transitionCategory: map['transitionCategory'] == null
          ? null
          : TransitionCategory.values.firstWhere(
              (item) => item.name == map['transitionCategory'],
            ),
      abandonmentReason: map['abandonmentReason'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LogEntry.fromJson(String source) =>
      LogEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
