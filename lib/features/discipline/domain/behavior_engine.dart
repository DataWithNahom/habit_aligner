import '../data/intention_repository.dart';
import 'behavior_state_machine.dart';
import 'intention_session.dart';

class BehaviorEngine {
  BehaviorEngine({
    required IntentionRepository repository,
    BehaviorStateMachine? stateMachine,
    DateTime Function()? now,
  }) : _repository = repository,
       _stateMachine = stateMachine ?? const BehaviorStateMachine(),
       _now = now ?? DateTime.now;

  final IntentionRepository _repository;
  final BehaviorStateMachine _stateMachine;
  final DateTime Function() _now;

  Future<IntentionSession> declare({
    required String id,
    required String label,
    required Duration declaredDuration,
    required IntentionType type,
    int? resistanceLevel,
  }) async {
    final active = await _repository.loadActive();
    if (active != null) {
      throw StateError(
        'Cannot start a new session while one is active. Trigger switch protocol.',
      );
    }

    final session = _stateMachine.declareAndCommit(
      IntentionSession(
        id: id,
        label: label.trim(),
        declaredDuration: declaredDuration,
        startedAt: _now(),
        type: type,
        resistanceLevel: resistanceLevel,
        segments: [Segment(start: _now())],
      ),
    );
    await _repository.upsert(session);
    return session;
  }

  Future<IntentionSession> declareDrift({
    required DriftReasonType reason,
    SwitchPriority? priority,
    String? replacementSessionId,
    String? explicitTradeoffDeclaration,
  }) async {
    final active = await _repository.loadActive();
    if (active == null) {
      throw StateError('Cannot declare drift without an active session.');
    }

    final updated = _stateMachine.declareDrift(
      session: active,
      event: DeviationEvent(
        timestamp: _now(),
        reasonType: reason,
        declaredPriority: priority,
        replacedBySessionId: replacementSessionId,
        explicitTradeoffDeclaration: explicitTradeoffDeclaration,
      ),
    );

    if (reason == DriftReasonType.voluntarySwitch ||
        reason == DriftReasonType.avoidanceImpulse) {
      await _repository.incrementDailyDeviationCounter(_now());
    }

    await _repository.upsert(updated);
    return updated;
  }
}
