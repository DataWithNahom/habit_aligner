import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_aligner/app.dart';

void main() {
  testWidgets('renders behavior resolution home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const HabitAlignerApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Behavior Resolution Log'), findsOneWidget);
    expect(find.text('Create new log'), findsOneWidget);
  });
}
