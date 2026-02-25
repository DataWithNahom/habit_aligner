import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_aligner/app.dart';

void main() {
  testWidgets('renders behavioral operating system shell', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const HabitAlignerApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Behavioral Operating System'), findsOneWidget);
    expect(find.text('Start intentional action'), findsOneWidget);
    expect(find.text('Daily analytics'), findsOneWidget);
  });
}
