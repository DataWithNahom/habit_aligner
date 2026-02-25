import '../domain/intention_session.dart';

abstract class IntentionRepository {
  Future<IntentionSession?> loadActive();
  Future<List<IntentionSession>> loadByDay(DateTime day);
  Future<void> upsert(IntentionSession session);
  Future<void> upsertAll(List<IntentionSession> sessions);

  /// Incremented on every voluntary switch or avoidance impulse.
  Future<void> incrementDailyDeviationCounter(DateTime day);
}
