import '../../../logs/domain/log_entry.dart';
import '../models/plan_block.dart';

class AdaptivePlanBuilder {
  List<PlanBlock> buildForDay(List<LogEntry> logs, DateTime day) {
    final productiveByHour = <int, int>{};
    for (final log in logs) {
      if (log.status == LogStatus.completed) {
        productiveByHour[log.startedAt.hour] =
            (productiveByHour[log.startedAt.hour] ?? 0) + 1;
      }
    }

    final sortedHours = productiveByHour.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hours = sortedHours.take(3).map((e) => e.key).toList();
    if (hours.isEmpty) {
      hours.addAll([9, 11, 14]);
    }

    return [
      for (var i = 0; i < hours.length; i++)
        PlanBlock(
          id: '${day.toIso8601String()}_$i',
          label: i == 1 ? 'Recovery Break' : 'Intentional Focus',
          durationMinutes: i == 1 ? 15 : 45,
          startHour: hours[i],
          startMinute: 0,
        ),
    ];
  }
}
