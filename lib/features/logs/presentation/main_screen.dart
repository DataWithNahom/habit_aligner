import 'package:flutter/material.dart';

import '../domain/log_entry.dart';
import 'log_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.controller});

  final LogController controller;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _handlingDialog = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChanged);
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    widget.controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});

    if (!_handlingDialog && widget.controller.halfTimeAlertDue) {
      _handlingDialog = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showHalfTimeDialog(),
      );
      return;
    }

    if (!_handlingDialog && widget.controller.plannedDurationAlertDue) {
      _handlingDialog = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showPlannedDurationDialog(),
      );
    }
  }

  Future<void> _showHalfTimeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Half-time checkpoint'),
          content: const Text('Continue current action or transition.'),
          actions: [
            TextButton(
              onPressed: () {
                widget.controller.dismissHalfTimeAlert();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
            FilledButton(
              onPressed: () {
                widget.controller.dismissHalfTimeAlert();
                Navigator.of(context).pop();
                _openTransitionFlow();
              },
              child: const Text('Transition'),
            ),
          ],
        );
      },
    );
    _handlingDialog = false;
  }

  Future<void> _showPlannedDurationDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Planned duration reached'),
          content: const Text('Are you still working on this action?'),
          actions: [
            TextButton(
              onPressed: () {
                widget.controller.dismissPlannedDurationAlert();
                Navigator.of(context).pop();
              },
              child: const Text('Continue current'),
            ),
            FilledButton(
              onPressed: () {
                widget.controller.dismissPlannedDurationAlert();
                Navigator.of(context).pop();
                _openTransitionFlow();
              },
              child: const Text('Transition now'),
            ),
          ],
        );
      },
    );
    _handlingDialog = false;
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ActivePanel(controller: controller),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: controller.activeLog == null
                            ? () => _openStartSheet()
                            : _openTransitionFlow,
                        icon: const Icon(Icons.track_changes_rounded, size: 18),
                        label: Text(
                          controller.activeLog == null
                              ? 'Start intentional action'
                              : 'Resolve and transition',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MetricsPanel(metrics: metrics),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: 'Daily timeline',
                        subtitle:
                            'Chronological reconstruction of resolved states.',
                      ),
                      const SizedBox(height: 8),
                      if (controller.todayTimeline.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('No timeline records for today.'),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.todayTimeline.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final log = controller.todayTimeline[index];
                            return _TimelineTile(log: log);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _openStartSheet({
    String? parentId,
    TransitionCategory? transitionCategory,
  }) async {
    final labelController = TextEditingController();
    final expectedController = TextEditingController(text: '30');
    BehaviorKind selectedKind = BehaviorKind.intentionalAction;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Define behavior state',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Action label',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: expectedController,
                    decoration: const InputDecoration(
                      labelText: 'Expected duration (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BehaviorKind>(
                    initialValue: selectedKind,
                    isExpanded: true,
                    items: BehaviorKind.values
                        .map(
                          (kind) => DropdownMenuItem(
                            value: kind,
                            child: Text(_kindLabel(kind)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setStateModal(() => selectedKind = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Behavior state',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final label = labelController.text.trim();
                      final expected =
                          int.tryParse(expectedController.text) ?? 0;
                      if (label.isEmpty || expected <= 0) return;

                      await widget.controller.startLog(
                        label: label,
                        kind: selectedKind,
                        expectedDurationMinutes: expected,
                        parentId: parentId,
                        transitionCategory: transitionCategory,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Start'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openTransitionFlow() async {
    final active = widget.controller.activeLog;
    if (active == null) {
      await _openStartSheet();
      return;
    }

    TransitionCategory selectedCategory = TransitionCategory.importantNotUrgent;
    String resolution = 'pause';
    final abandonReasonController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Transition classification required'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Current action: ${active.label}'),
                    const SizedBox(height: 12),
                    const Text('Resolve current action before switching:'),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'complete',
                          label: Text('Completed'),
                        ),
                        ButtonSegment<String>(
                          value: 'pause',
                          label: Text('Paused'),
                        ),
                        ButtonSegment<String>(
                          value: 'abandon',
                          label: Text('Abandoned'),
                        ),
                      ],
                      selected: {resolution},
                      onSelectionChanged: (selection) {
                        setDialogState(() => resolution = selection.first);
                      },
                    ),
                    if (resolution == 'abandon')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextField(
                          controller: abandonReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Abandonment reason',
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TransitionCategory>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      items: TransitionCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(_transitionLabel(category)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCategory = value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Reason for switching',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (resolution == 'complete') {
                      await widget.controller.completeActiveLog();
                    } else if (resolution == 'pause') {
                      await widget.controller.pauseActiveLog();
                    } else {
                      final reason = abandonReasonController.text.trim();
                      if (reason.isEmpty) return;
                      await widget.controller.abandonActiveLog(reason);
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    await _openStartSheet(
                      parentId: active.id,
                      transitionCategory: selectedCategory,
                    );
                  },
                  child: const Text('Resolve and continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ActivePanel extends StatelessWidget {
  const _ActivePanel({required this.controller});

  final LogController controller;

  @override
  Widget build(BuildContext context) {
    final active = controller.activeLog;

    if (active == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'State: Unassigned',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Define the next intentional action to assign time.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'State: ${_kindLabel(active.kind)}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(active.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Started ${_formatDate(active.startedAt)}'),
                _InfoChip(
                  label: 'Expected ${active.expectedDurationMinutes} min',
                ),
                _InfoChip(
                  label: 'Elapsed ${_formatDuration(controller.activeElapsed)}',
                ),
                if (active.parentId != null)
                  _InfoChip(label: 'Lineage ${active.parentId}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(64),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.metrics});

  final DailyMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Daily analytics',
              subtitle: 'Derived structural measures for today.',
            ),
            const SizedBox(height: 10),
            _MetricRow(
              label: 'Planned vs actual accuracy',
              value:
                  '${(metrics.plannedVsActualAccuracy * 100).toStringAsFixed(1)}%',
            ),
            _MetricRow(
              label: 'Deviation frequency',
              value:
                  '${(metrics.deviationFrequency * 100).toStringAsFixed(1)}%',
            ),
            _MetricRow(
              label: 'Drift duration',
              value: _formatDuration(metrics.driftDuration),
            ),
            _MetricRow(
              label: 'Reaction ratio',
              value: '${(metrics.reactionRatio * 100).toStringAsFixed(1)}%',
            ),
            _MetricRow(
              label: 'Interruption density',
              value:
                  '${(metrics.interruptionDensity * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.log});

  final LogEntry log;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor(context, log.status),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(log.startedAt)} - ${log.endedAt == null ? 'Active' : _formatDate(log.endedAt!)} • ${_kindLabel(log.kind)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _statusLabel(log.status),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, LogStatus status) {
    return switch (status) {
      LogStatus.active => Theme.of(context).colorScheme.primary,
      LogStatus.paused => Colors.amber,
      LogStatus.completed => Colors.greenAccent,
      LogStatus.abandoned => Colors.redAccent,
    };
  }
}

String _kindLabel(BehaviorKind kind) {
  return switch (kind) {
    BehaviorKind.intentionalAction => 'Intentional action',
    BehaviorKind.correctiveStop => 'Corrective stop',
    BehaviorKind.intentionalBreak => 'Intentional break',
    BehaviorKind.drift => 'Drift awareness',
  };
}

String _transitionLabel(TransitionCategory category) {
  return switch (category) {
    TransitionCategory.urgentImportant => 'Urgent & important',
    TransitionCategory.importantNotUrgent => 'Important, not urgent',
    TransitionCategory.urgentNotImportant => 'Urgent, not important',
    TransitionCategory.neither => 'Neither urgent nor important',
  };
}

String _statusLabel(LogStatus status) {
  return switch (status) {
    LogStatus.active => 'Active',
    LogStatus.paused => 'Paused',
    LogStatus.completed => 'Completed',
    LogStatus.abandoned => 'Abandoned',
  };
}

String _formatDate(DateTime dateTime) {
  final twoDigitHour = dateTime.hour.toString().padLeft(2, '0');
  final twoDigitMinute = dateTime.minute.toString().padLeft(2, '0');
  return '$twoDigitHour:$twoDigitMinute';
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
