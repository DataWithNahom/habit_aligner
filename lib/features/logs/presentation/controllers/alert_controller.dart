import 'package:flutter/foundation.dart';

import 'active_session_controller.dart';

class AlertController extends ChangeNotifier {
  AlertController({required ActiveSessionController activeSession})
    : _activeSession = activeSession {
    _activeSession.addListener(_onActiveChange);
  }

  final ActiveSessionController _activeSession;

  bool get halfDue => _activeSession.halfAlertDue;
  bool get plannedDue => _activeSession.plannedAlertDue;

  Future<void> dismissHalf() async {
    await _activeSession.markHalfShown();
    notifyListeners();
  }

  Future<void> dismissPlanned() async {
    await _activeSession.markPlannedShown();
    notifyListeners();
  }

  void _onActiveChange() => notifyListeners();

  @override
  void dispose() {
    _activeSession.removeListener(_onActiveChange);
    super.dispose();
  }
}
