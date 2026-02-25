import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'logger_service.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  final Map<Route<dynamic>, DateTime> _routeStartTimes =
      <Route<dynamic>, DateTime>{};

  String _routeName(Route<dynamic>? route) {
    if (route == null) return 'unknown';
    return route.settings.name ?? route.runtimeType.toString();
  }

  Map<String, Object?> _routeContext(Route<dynamic>? route) {
    return {
      'routeName': _routeName(route),
      'arguments': route?.settings.arguments?.toString(),
    };
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final now = DateTime.now();
    _routeStartTimes[route] = now;
    LoggerService.instance.setCurrentRoute(_routeName(route));
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.navigation,
      event: 'RoutePush',
      message: 'Route pushed onto navigator stack.',
      context: {
        ..._routeContext(route),
        'fromRoute': _routeName(previousRoute),
      },
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final start = _routeStartTimes.remove(route);
    final duration = start == null ? null : DateTime.now().difference(start);
    LoggerService.instance.setCurrentRoute(_routeName(previousRoute));
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.navigation,
      event: 'RoutePop',
      message: 'Route popped from navigator stack.',
      context: {..._routeContext(route), 'toRoute': _routeName(previousRoute)},
      duration: duration,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      _routeStartTimes.remove(oldRoute);
    }
    if (newRoute != null) {
      _routeStartTimes[newRoute] = DateTime.now();
      LoggerService.instance.setCurrentRoute(_routeName(newRoute));
    }
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.navigation,
      event: 'RouteReplace',
      message: 'Route replaced.',
      context: {
        'oldRoute': _routeName(oldRoute),
        'newRoute': _routeName(newRoute),
      },
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeStartTimes.remove(route);
    LoggerService.instance.log(
      level: LogLevel.warning,
      tag: FeatureTag.navigation,
      event: 'RouteRemove',
      message: 'Route removed from navigator stack.',
      context: {
        ..._routeContext(route),
        'revealedRoute': _routeName(previousRoute),
      },
    );
  }
}

class AppLifecycleLogger with WidgetsBindingObserver {
  AppLifecycleState? _lastState;
  DateTime? _lastTransition;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'LifecycleObserverAttached',
      message: 'App lifecycle observer attached.',
    );
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'LifecycleObserverDetached',
      message: 'App lifecycle observer detached.',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    final delta = _lastTransition == null
        ? null
        : now.difference(_lastTransition!);
    LoggerService.instance.log(
      level: LogLevel.info,
      tag: FeatureTag.lifecycle,
      event: 'LifecycleStateChanged',
      message: 'Application lifecycle state changed.',
      context: {'previousState': _lastState?.name, 'newState': state.name},
      duration: delta,
    );
    _lastState = state;
    _lastTransition = now;
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    LoggerService.instance.log(
      level: LogLevel.warning,
      tag: FeatureTag.lifecycle,
      event: 'AppExitRequested',
      message: 'Platform requested app exit.',
    );
    return super.didRequestAppExit();
  }
}
