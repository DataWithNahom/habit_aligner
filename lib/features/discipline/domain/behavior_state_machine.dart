import 'intention_session.dart';

class BehaviorStateMachine {
  const BehaviorStateMachine();

  IntentionSession declareAndCommit(IntentionSession session) {
    _ensureNoOpenSegmentOverlap(session.segments);
    if (session.state != BehaviorState.activeCommitted) {
      throw StateError('New declarations must enter activeCommitted.');
    }
    return session;
  }

  IntentionSession awarenessConfirmed(IntentionSession session) {
    _assertState(session, BehaviorState.activeCommitted);
    return session.copyWith(awarenessCheckpointResponded: true);
  }

  IntentionSession declareDrift({
    required IntentionSession session,
    required DeviationEvent event,
  }) {
    _assertState(session, BehaviorState.activeCommitted);
    final eventRequiresDeclaration =
        event.reasonType == DriftReasonType.voluntarySwitch ||
        event.reasonType == DriftReasonType.avoidanceImpulse;
    if (eventRequiresDeclaration &&
        (event.explicitTradeoffDeclaration == null ||
            event.explicitTradeoffDeclaration!.trim().isEmpty)) {
      throw StateError(
        'Voluntary switches and avoidance impulses require explicit tradeoff declaration.',
      );
    }
    return session.copyWith(
      state: BehaviorState.driftDeclared,
      deviations: [...session.deviations, event],
      defended: false,
    );
  }

  IntentionSession pauseExternal(IntentionSession session, String note) {
    _assertState(session, BehaviorState.driftDeclared);
    return session.copyWith(
      state: BehaviorState.pausedExternal,
      interruptions: [
        ...session.interruptions,
        InterruptionEvent(timestamp: DateTime.now(), note: note),
      ],
    );
  }

  IntentionSession complete(IntentionSession session, DateTime at) {
    _assertResolvable(session);
    return session.copyWith(state: BehaviorState.completed, completedAt: at);
  }

  IntentionSession abandon(
    IntentionSession session,
    DateTime at,
    String reason,
  ) {
    _assertResolvable(session);
    if (reason.trim().isEmpty) {
      throw StateError('Abandoned sessions require an explicit reason text.');
    }
    return session.copyWith(
      state: BehaviorState.abandoned,
      abandonedAt: at,
      abandonmentReason: reason.trim(),
    );
  }

  void validateSingleActive(List<IntentionSession> sessions) {
    final activeCount = sessions
        .where((s) => s.state == BehaviorState.activeCommitted)
        .length;
    if (activeCount > 1) {
      throw StateError('Only one activeCommitted session is allowed.');
    }
  }

  void _assertState(IntentionSession session, BehaviorState expected) {
    if (session.state != expected) {
      throw StateError(
        'Invalid transition. Expected state ${expected.name}, got ${session.state.name}.',
      );
    }
  }

  void _assertResolvable(IntentionSession session) {
    const resolvable = {
      BehaviorState.activeCommitted,
      BehaviorState.driftDeclared,
      BehaviorState.pausedExternal,
    };
    if (!resolvable.contains(session.state)) {
      throw StateError('Session in ${session.state.name} cannot be resolved.');
    }
  }

  void _ensureNoOpenSegmentOverlap(List<Segment> segments) {
    DateTime? previousEnd;
    for (final segment in [
      ...segments,
    ]..sort((a, b) => a.start.compareTo(b.start))) {
      final end = segment.end;
      if (end != null && end.isBefore(segment.start)) {
        throw StateError('Segment end cannot be before segment start.');
      }
      if (previousEnd != null && segment.start.isBefore(previousEnd)) {
        throw StateError('Overlapping segments are not allowed.');
      }
      previousEnd = end;
    }
  }
}
