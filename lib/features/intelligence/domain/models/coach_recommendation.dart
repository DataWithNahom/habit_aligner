class CoachRecommendation {
  const CoachRecommendation({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    this.acknowledged = false,
  });

  final String id;
  final String title;
  final String body;
  final int priority;
  final bool acknowledged;
}
