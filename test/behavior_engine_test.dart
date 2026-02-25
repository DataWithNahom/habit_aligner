import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/discipline/data/intention_repository.dart';
import 'package:habit_aligner/features/discipline/domain/behavior_engine.dart';
import 'package:habit_aligner/features/discipline/domain/intention_session.dart';

class _MemoryIntentionRepository implements IntentionRepository {
  IntentionSession? active;
  final all = <IntentionSession>[];
  int deviationCounter = 0;

  @override
  Future<void> incrementDailyDeviationCounter(DateTime day) async {
    deviationCounter++;
  }

  @override
  Future<IntentionSession?> loadActive() async => active;

  @override
  Future<List<IntentionSession>> loadByDay(DateTime day) async => all;

  @override
  Future<void> upsert(IntentionSession session) async {
    active = session.state == BehaviorState.activeCommitted ? session : null;
    final index = all.indexWhere((s) => s.id == session.id);
    if (index == -1) {
      all.add(session);
    } else {
      all[index] = session;
    }
  }

  @override
  Future<void> upsertAll(List<IntentionSession> sessions) async {
    for (final item in sessions) {
      await upsert(item);
    }
  }
}

void main() {
  test('declare blocks when active session already exists', () async {
    final repo = _MemoryIntentionRepository();
    final now = DateTime(2026, 1, 1, 9);
    final engine = BehaviorEngine(repository: repo, now: () => now);

    await engine.declare(
      id: 'a',
      label: 'Deep work',
      declaredDuration: const Duration(minutes: 60),
      type: IntentionType.mandatory,
    );

    expect(
      () => engine.declare(
        id: 'b',
        label: 'Switch',
        declaredDuration: const Duration(minutes: 25),
        type: IntentionType.optional,
      ),
      throwsStateError,
    );
  });

  test('voluntary switch requires explicit declaration and increments counter', () async {
    final repo = _MemoryIntentionRepository();
    final now = DateTime(2026, 1, 1, 9);
    final engine = BehaviorEngine(repository: repo, now: () => now);

    await engine.declare(
      id: 'a',
      label: 'Deep work',
      declaredDuration: const Duration(minutes: 60),
      type: IntentionType.mandatory,
    );

    expect(
      () => engine.declareDrift(reason: DriftReasonType.voluntarySwitch),
      throwsStateError,
    );

    final switched = await engine.declareDrift(
      reason: DriftReasonType.voluntarySwitch,
      priority: SwitchPriority.urgent,
      explicitTradeoffDeclaration:
          'This is more important than what I committed to.',
    );

    expect(switched.state, BehaviorState.driftDeclared);
    expect(switched.defended, isFalse);
    expect(repo.deviationCounter, 1);
  });
}
