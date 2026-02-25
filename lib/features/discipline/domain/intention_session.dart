enum IntentionType { mandatory, growth, maintenance, optional }

enum BehaviorState {
  idle,
  activeCommitted,
  driftDeclared,
  pausedExternal,
  completed,
  abandoned,
}

enum DriftReasonType {
  interruptedExternally,
  voluntarySwitch,
  avoidanceImpulse,
  taskCompletedEarly,
}

enum SwitchPriority { urgent, important, neutral, impulse }

class Segment {
  Segment({required this.start, this.end});

  final DateTime start;
  final DateTime? end;

  Duration get duration {
    final terminal = end ?? DateTime.now();
    final delta = terminal.difference(start);
    return delta.isNegative ? Duration.zero : delta;
  }

  Segment close(DateTime at) => Segment(start: start, end: at);
}

class DeviationEvent {
  DeviationEvent({
    required this.timestamp,
    required this.reasonType,
    this.declaredPriority,
    this.replacedBySessionId,
    this.explicitTradeoffDeclaration,
  });

  final DateTime timestamp;
  final DriftReasonType reasonType;
  final SwitchPriority? declaredPriority;
  final String? replacedBySessionId;
  final String? explicitTradeoffDeclaration;
}

class InterruptionEvent {
  InterruptionEvent({required this.timestamp, required this.note});

  final DateTime timestamp;
  final String note;
}

class IntentionSession {
  IntentionSession({
    required this.id,
    required this.label,
    required this.declaredDuration,
    required this.startedAt,
    required this.type,
    this.resistanceLevel,
    this.state = BehaviorState.activeCommitted,
    this.segments = const <Segment>[],
    this.deviations = const <DeviationEvent>[],
    this.interruptions = const <InterruptionEvent>[],
    this.completedAt,
    this.abandonedAt,
    this.abandonmentReason,
    this.defended = true,
    this.awarenessCheckpointResponded = false,
  }) : assert(
         resistanceLevel == null ||
             (resistanceLevel >= 1 && resistanceLevel <= 5),
         'resistanceLevel must be 1-5 when provided.',
       );

  final String id;
  final String label;
  final Duration declaredDuration;
  final DateTime startedAt;
  final IntentionType type;
  final int? resistanceLevel;
  final BehaviorState state;
  final List<Segment> segments;
  final List<DeviationEvent> deviations;
  final List<InterruptionEvent> interruptions;
  final DateTime? completedAt;
  final DateTime? abandonedAt;
  final String? abandonmentReason;
  final bool defended;
  final bool awarenessCheckpointResponded;

  Duration get defendedDuration =>
      segments.fold(Duration.zero, (sum, segment) => sum + segment.duration);

  IntentionSession copyWith({
    BehaviorState? state,
    List<Segment>? segments,
    List<DeviationEvent>? deviations,
    List<InterruptionEvent>? interruptions,
    DateTime? completedAt,
    DateTime? abandonedAt,
    String? abandonmentReason,
    bool? defended,
    bool? awarenessCheckpointResponded,
  }) {
    return IntentionSession(
      id: id,
      label: label,
      declaredDuration: declaredDuration,
      startedAt: startedAt,
      type: type,
      resistanceLevel: resistanceLevel,
      state: state ?? this.state,
      segments: segments ?? this.segments,
      deviations: deviations ?? this.deviations,
      interruptions: interruptions ?? this.interruptions,
      completedAt: completedAt ?? this.completedAt,
      abandonedAt: abandonedAt ?? this.abandonedAt,
      abandonmentReason: abandonmentReason ?? this.abandonmentReason,
      defended: defended ?? this.defended,
      awarenessCheckpointResponded:
          awarenessCheckpointResponded ?? this.awarenessCheckpointResponded,
    );
  }
}
