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
  bool _showingBlockingDialog = false;

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

    final active = widget.controller.activeLog;
    if (active != null && !_showingBlockingDialog) {
      _showingBlockingDialog = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showBlockingDialog(),
      );
    }
  }

  Future<void> _showBlockingDialog() async {
    final active = widget.controller.activeLog;
    if (active == null || !mounted) {
      _showingBlockingDialog = false;
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Unresolved behavior active'),
            content: Text(
              'You must resolve this entry before continuing:\n\n"${active.description}"',
            ),
            actions: [
              FilledButton(
                onPressed: () async {
                  await widget.controller.completeActiveLog();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Confirm resolved'),
              ),
            ],
          ),
        );
      },
    );

    _showingBlockingDialog = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Behavior Resolution Log')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ActivePanel(controller: controller),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.activeLog == null
                        ? () => _openCreateSheet(context, controller)
                        : null,
                    child: const Text('Create new log'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: controller.logs.isEmpty
                        ? const Center(child: Text('No logs yet'))
                        : ListView.separated(
                            itemCount: controller.logs.length,
                            separatorBuilder: (_, _) => const Divider(),
                            itemBuilder: (context, index) {
                              final log = controller.logs[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(log.description),
                                subtitle: Text(
                                  '${_label(log.type)} • ${_formatDate(log.startTime)}',
                                ),
                                trailing: log.resolved
                                    ? Text(_formatDuration(log.duration!))
                                    : const Text('OPEN'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _openCreateSheet(
    BuildContext context,
    LogController controller,
  ) async {
    final textController = TextEditingController();
    LogType selectedType = LogType.stop;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Describe what you need to resolve',
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<LogType>(
                    segments: const [
                      ButtonSegment<LogType>(
                        value: LogType.stop,
                        label: Text('I need to STOP something'),
                      ),
                      ButtonSegment<LogType>(
                        value: LogType.start,
                        label: Text('I need to START something'),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (selection) {
                      setModalState(() {
                        selectedType = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final description = textController.text.trim();
                      if (description.isEmpty) return;

                      await controller.createLog(
                        description: description,
                        type: selectedType,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Start timer now'),
                  ),
                ],
              ),
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
                'No active unresolved log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Create one entry when you are avoiding or drifting.'),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVE: ${_label(active.type)}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              active.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Started: ${_formatDate(active.startTime)}'),
            const SizedBox(height: 4),
            Text('Elapsed: ${_formatDuration(controller.activeElapsed)}'),
          ],
        ),
      ),
    );
  }
}

String _label(LogType type) {
  return switch (type) {
    LogType.stop => 'STOP',
    LogType.start => 'START',
  };
}

String _formatDate(DateTime dateTime) {
  final twoDigitMonth = dateTime.month.toString().padLeft(2, '0');
  final twoDigitDay = dateTime.day.toString().padLeft(2, '0');
  final twoDigitHour = dateTime.hour.toString().padLeft(2, '0');
  final twoDigitMinute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$twoDigitMonth-$twoDigitDay $twoDigitHour:$twoDigitMinute';
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
