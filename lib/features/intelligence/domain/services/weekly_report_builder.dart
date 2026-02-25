import '../../../logs/domain/log_entry.dart';
import '../models/weekly_report.dart';

class WeeklyReportBuilder {
  WeeklyReport build(List<LogEntry> logs, DateTime now, int averageFocus) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekLogs = logs
        .where(
          (l) =>
              l.startedAt.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ) &&
              l.startedAt.isBefore(startOfWeek.add(const Duration(days: 7))),
        )
        .toList();

    final chart = List<int>.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      return weekLogs
          .where(
            (l) =>
                l.startedAt.year == day.year &&
                l.startedAt.month == day.month &&
                l.startedAt.day == day.day &&
                l.status == LogStatus.completed,
          )
          .length;
    });

    final summary = weekLogs.isEmpty
        ? 'No sessions recorded this week. Start with one intentional block today.'
        : 'You completed ${weekLogs.where((e) => e.status == LogStatus.completed).length} sessions this week. Best day volume: ${chart.reduce((a, b) => a > b ? a : b)}.';

    final key = '${startOfWeek.year}-W${_weekNumber(startOfWeek)}';

    return WeeklyReport(
      weekKey: key,
      summary: summary,
      totalSessions: weekLogs.length,
      averageFocus: averageFocus,
      chartPoints: chart,
    );
  }

  int _weekNumber(DateTime date) {
    final first = DateTime(date.year, 1, 1);
    return ((date.difference(first).inDays + first.weekday) / 7).ceil();
  }
}
