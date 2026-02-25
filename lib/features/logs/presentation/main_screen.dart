import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/dashboard_cards.dart';
import '../../intelligence/domain/models/plan_block.dart';
import '../../intelligence/domain/models/weekly_report.dart';
import '../domain/log_entry.dart';
import 'log_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.controller});

  final LogController controller;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final metrics = controller.todayMetrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Behavioral Operating System')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: SessionStateCard(
                        key: ValueKey(controller.activeLog?.id ?? 'idle'),
                        title:
                            controller.activeLog?.label ?? 'No active session',
                        subtitle: controller.activeLog == null
                            ? 'Start an intentional block to begin.'
                            : 'Elapsed ${controller.activeElapsed.inMinutes} min',
                        trailing: controller.activeLog != null
                            ? IconButton(
                                tooltip: 'Complete current session',
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();
                                  await controller.completeActiveLog();
                                },
                                icon: const Icon(Icons.check_circle_outline),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuickActions(controller: controller),

                    const SizedBox(height: 20),
                    const Text(
                      'Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CTASection(
                      title: 'Adaptive plan builder',
                      subtitle:
                          'Generated from your offline historical performance.',
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => controller.createDailyPlan(),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Regenerate plan'),
                            ),
                          ),
                          ...controller.dailyPlan.map(
                            (block) => _PlanTile(block: block),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TemplateRow(controller: controller),

                    const SizedBox(height: 20),
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MetricCard(
                          label: 'Focus',
                          value: '${metrics.focusScore}',
                        ),
                        MetricCard(
                          label: 'Streak',
                          value: '${metrics.streak}d',
                        ),
                        MetricCard(
                          label: 'Points',
                          value: '${controller.points}',
                        ),
                        MetricCard(
                          label: 'Level',
                          value: '${controller.level}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...controller.coachRecommendations.map(
                      (e) => Semantics(
                        label: 'Coach recommendation',
                        child: InsightCard(message: '${e.title}: ${e.body}'),
                      ),
                    ),
                    ...controller.driftInsights.map(
                      (e) => InsightCard(message: e),
                    ),
                    if (controller.weeklyReport != null)
                      _WeeklyChart(report: controller.weeklyReport!),
                    if (controller.badges.isNotEmpty)
                      InsightCard(
                        message:
                            'Badges unlocked: ${controller.badges.join(', ')}',
                      ),

                    const SizedBox(height: 20),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.todayTimeline.map(
                      (log) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(log.label),
                        subtitle: Text(
                          '${log.kind.name} • ${log.status.name}${log.tags.isNotEmpty ? ' • ${log.tags.join('/')}' : ''}',
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: controller.exportJson,
                          child: const Text('Export JSON'),
                        ),
                        OutlinedButton(
                          onPressed: controller.exportCsv,
                          child: const Text('Export CSV'),
                        ),
                        OutlinedButton(
                          onPressed: controller.createBackup,
                          child: const Text('Create backup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openStartSheet,
        label: const Text('Start'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  Future<void> _openStartSheet({
    String? presetLabel,
    int presetMins = 30,
  }) async {
    final labelController = TextEditingController(text: presetLabel ?? '');
    final expectedController = TextEditingController(text: '$presetMins');
    final tagsController = TextEditingController();
    final experimentController = TextEditingController();
    var selectedKind = BehaviorKind.intentionalAction;
    var advanced = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Action label'),
                autofocus: true,
              ),
              TextField(
                controller: expectedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes'),
              ),
              DropdownButtonFormField<BehaviorKind>(
                initialValue: selectedKind,
                items: BehaviorKind.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setModal(
                  () => selectedKind = v ?? BehaviorKind.intentionalAction,
                ),
              ),
              SwitchListTile(
                value: advanced,
                onChanged: (v) => setModal(() => advanced = v),
                title: const Text('Advanced options (tags + experiment)'),
              ),
              if (advanced) ...[
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Context tags (comma separated)',
                  ),
                ),
                TextField(
                  controller: experimentController,
                  decoration: const InputDecoration(
                    labelText: 'Experiment ID (optional)',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  final label = labelController.text.trim();
                  final expected = int.tryParse(expectedController.text) ?? 30;
                  if (label.isEmpty || expected <= 0) return;
                  HapticFeedback.lightImpact();
                  await widget.controller.startLog(
                    label: label,
                    kind: selectedKind,
                    expectedDurationMinutes: expected,
                    tags: tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    experimentId: experimentController.text.trim().isEmpty
                        ? null
                        : experimentController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final LogController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: controller.activeLog == null
              ? null
              : controller.pauseActiveLog,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        FilledButton.icon(
          onPressed: controller.activeLog == null
              ? null
              : controller.completeActiveLog,
          icon: const Icon(Icons.check),
          label: const Text('Complete'),
        ),
        OutlinedButton.icon(
          onPressed: controller.activeLog == null
              ? null
              : () => controller.abandonActiveLog('manual abandon'),
          icon: const Icon(Icons.close),
          label: const Text('Abandon'),
        ),
      ],
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.controller});

  final LogController controller;

  @override
  Widget build(BuildContext context) {
    final templates = [
      ('Deep Work 45', 45),
      ('Admin Sweep 20', 20),
      ('Recovery Break 10', 10),
    ];
    return CTASection(
      title: 'Session templates',
      subtitle: 'One-thumb quick start templates.',
      child: Wrap(
        spacing: 8,
        children: [
          for (final t in templates)
            ActionChip(
              label: Text(t.$1),
              onPressed: () =>
                  (context.findAncestorStateOfType<_MainScreenState>())
                      ?._openStartSheet(presetLabel: t.$1, presetMins: t.$2),
            ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.block});

  final PlanBlock block;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(block.label),
      subtitle: Text(
        '${block.startHour.toString().padLeft(2, '0')}:${block.startMinute.toString().padLeft(2, '0')} • ${block.durationMinutes} min',
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final points = report.chartPoints;
    final max = points.isEmpty
        ? 1
        : points.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return CTASection(
      title: 'Weekly intelligence',
      subtitle: report.summary,
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final p in points)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: (p / max) * 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
