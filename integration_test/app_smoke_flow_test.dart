import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:habit_aligner/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('boot, start session, and complete session flow', (tester) async {
    await tester.pumpWidget(const HabitAlignerApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Behavioral Operating System'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);

    final startFab = find.text('Start');
    expect(startFab, findsWidgets);
    await tester.tap(startFab.first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Action label'),
      'Deep Work',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Minutes'), '25');
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Deep Work'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Complete'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Session completed.'), findsOneWidget);
  });
}
