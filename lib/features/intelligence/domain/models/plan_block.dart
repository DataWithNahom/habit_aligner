class PlanBlock {
  const PlanBlock({
    required this.id,
    required this.label,
    required this.durationMinutes,
    required this.startHour,
    required this.startMinute,
    this.completed = false,
  });

  final String id;
  final String label;
  final int durationMinutes;
  final int startHour;
  final int startMinute;
  final bool completed;
}
