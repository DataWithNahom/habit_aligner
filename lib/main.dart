import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/logging/logger_service.dart';

bool _didBoot = false;

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      tz.initializeTimeZones();

      await LoggerService.instance.initialize(coldStart: !_didBoot);
      _didBoot = true;

      FlutterError.onError = (FlutterErrorDetails details) {
        LoggerService.instance.log(
          level: LogLevel.critical,
          tag: FeatureTag.system,
          event: 'FlutterFrameworkError',
          message:
              'Unhandled framework exception captured by FlutterError.onError.',
          error: details.exception,
          stackTrace: details.stack,
          context: {
            'library': details.library,
            'context': details.context?.toDescription(),
          },
        );
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError =
          (Object error, StackTrace stackTrace) {
            LoggerService.instance.log(
              level: LogLevel.critical,
              tag: FeatureTag.system,
              event: 'PlatformDispatcherError',
              message: 'Unhandled platform-dispatcher exception captured.',
              error: error,
              stackTrace: stackTrace,
            );
            return true;
          };

      LoggerService.instance.log(
        level: LogLevel.info,
        tag: FeatureTag.init,
        event: 'RunApp',
        message: 'Starting HabitAlignerApp through guarded zone.',
      );
      runApp(const HabitAlignerApp());
    },
    (Object error, StackTrace stackTrace) {
      LoggerService.instance.log(
        level: LogLevel.critical,
        tag: FeatureTag.system,
        event: 'RunZonedGuardedError',
        message: 'Unhandled asynchronous zone error captured.',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
