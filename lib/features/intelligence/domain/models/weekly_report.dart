class WeeklyReport {
  const WeeklyReport({
    required this.weekKey,
    required this.summary,
    required this.totalSessions,
    required this.averageFocus,
    required this.chartPoints,
  });

  final String weekKey;
  final String summary;
  final int totalSessions;
  final int averageFocus;
  final List<int> chartPoints;
}
