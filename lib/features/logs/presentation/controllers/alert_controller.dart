import 'package:flutter/foundation.dart';

import '../../../../core/logging/logger_service.dart';
import 'active_session_controller.dart';

class AlertController extends ChangeNotifier {
  AlertController({required ActiveSessionController activeSession})
    : _activeSession = activeSession {
    _activeSession.addListener(_onActiveChange);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.init,
      event: 'AlertControllerConstructed',
      message: 'AlertController created and active-session listener attached.',
    );
  }

  final ActiveSessionController _activeSession;

  bool get halfDue => _activeSession.halfAlertDue;
  bool get plannedDue => _activeSession.plannedAlertDue;

  Future<void> dismissHalf() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'DismissHalfAlert',
      tag: FeatureTag.userAction,
      operation: () async {
        await _activeSession.markHalfShown();
        notifyListeners();
      },
    );
  }

  Future<void> dismissPlanned() async {
    await LoggerService.instance.traceAsync<void>(
      event: 'DismissPlannedAlert',
      tag: FeatureTag.userAction,
      operation: () async {
        await _activeSession.markPlannedShown();
        notifyListeners();
      },
    );
  }

  void _onActiveChange() {
    LoggerService.instance.log(
      level: LogLevel.debug,
      tag: FeatureTag.system,
      event: 'AlertControllerActiveChange',
      message: 'Observed active session state change; forwarding notification.',
      context: {'halfDue': halfDue, 'plannedDue': plannedDue},
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _activeSession.removeListener(_onActiveChange);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'AlertControllerDispose',
      message: 'AlertController disposed and listener removed.',
    );
    super.dispose();
  }
}
