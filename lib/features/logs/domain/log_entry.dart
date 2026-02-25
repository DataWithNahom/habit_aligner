import 'dart:convert';

enum LogType { stop, start }

class LogEntry {
  LogEntry({
    required this.id,
    required this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    this.resolved = false,
  });

  final String id;
  final String description;
  final LogType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final bool resolved;

  Duration? get duration =>
      durationSeconds == null ? null : Duration(seconds: durationSeconds!);

  LogEntry complete(DateTime completedAt) {
    final seconds = completedAt.difference(startTime).inSeconds;
    return LogEntry(
      id: id,
      description: description,
      type: type,
      startTime: startTime,
      endTime: completedAt,
      durationSeconds: seconds,
      resolved: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'resolved': resolved,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as String,
      description: map['description'] as String,
      type: LogType.values.firstWhere((item) => item.name == map['type']),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] == null
          ? null
          : DateTime.parse(map['endTime'] as String),
      durationSeconds: map['durationSeconds'] as int?,
      resolved: map['resolved'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LogEntry.fromJson(String source) =>
      LogEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
