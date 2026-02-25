import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/features/logs/domain/log_entry.dart';
import 'package:habit_aligner/features/logs/domain/use_cases/resolve_session_use_case.dart';

import 'support_test_helpers.dart';

void main() {
  test('pause resolution stores optional pause reason defensively', () async {
    final repository = InMemoryLogRepository([
      entry(id: 'active', start: fixedNow(), status: LogStatus.active),
    ]);

    final useCase = ResolveSessionUseCase(
      repository: repository,
      now: () => fixedNow().add(const Duration(minutes: 5)),
    );

    final paused = await useCase(
      resolution: LogStatus.paused,
      reason: '  interrupted by call ',
    );

    expect(paused, isNotNull);
    expect(paused!.status, LogStatus.paused);
    expect(paused.abandonmentReason, 'interrupted by call');

    final rows = await repository.loadLogs();
    expect(rows.single.abandonmentReason, 'interrupted by call');
  });

  test('blank pause reason is ignored instead of storing noise', () async {
    final repository = InMemoryLogRepository([
      entry(id: 'active', start: fixedNow(), status: LogStatus.active),
    ]);

    final useCase = ResolveSessionUseCase(
      repository: repository,
      now: () => fixedNow().add(const Duration(minutes: 2)),
    );

    final paused = await useCase(resolution: LogStatus.paused, reason: '   ');

    expect(paused, isNotNull);
    expect(paused!.abandonmentReason, isNull);
  });
}
