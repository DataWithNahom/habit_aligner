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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ActivePanel(controller: controller),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.activeLog == null
                        ? () => _openStartSheet()
                        : _openTransitionFlow,
                    child: Text(
                      controller.activeLog == null
                          ? 'Start intentional action'
                          : 'Resolve and transition',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetricsPanel(metrics: metrics),
                  const SizedBox(height: 16),
                  Text(
                    'Daily timeline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: controller.todayTimeline.isEmpty
                        ? const Center(
                            child: Text('No timeline records for today.'),
                          )
                        : ListView.separated(
                            itemCount: controller.todayTimeline.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final log = controller.todayTimeline[index];
                              return ListTile(
                                title: Text(log.label),
                                subtitle: Text(
                                  '${_formatDate(log.startedAt)} - ${log.endedAt == null ? 'Active' : _formatDate(log.endedAt!)} • ${_kindLabel(log.kind)}',
                                ),
                                trailing: Text(_statusLabel(log.status)),
                              );
                            },
                          ),
                  ),
                ],
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
                      TextField(
                        controller: abandonReasonController,
                        decoration: const InputDecoration(
                          labelText: 'Abandonment reason',
                        ),
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TransitionCategory>(
                      initialValue: selectedCategory,
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
            Text(active.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Started ${_formatDate(active.startedAt)}'),
            Text('Expected ${active.expectedDurationMinutes} min'),
            Text('Elapsed ${_formatDuration(controller.activeElapsed)}'),
            if (active.parentId != null)
              Text('Lineage link ${active.parentId}'),
          ],
        ),
      ),
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
            Text(
              'Daily analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Planned vs actual accuracy: ${(metrics.plannedVsActualAccuracy * 100).toStringAsFixed(1)}%',
            ),
            Text(
              'Deviation frequency: ${(metrics.deviationFrequency * 100).toStringAsFixed(1)}%',
            ),
            Text('Drift duration: ${_formatDuration(metrics.driftDuration)}'),
            Text(
              'Reaction ratio: ${(metrics.reactionRatio * 100).toStringAsFixed(1)}%',
            ),
            Text(
              'Interruption density: ${(metrics.interruptionDensity * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
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
