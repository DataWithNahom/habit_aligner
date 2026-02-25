import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_aligner/core/widgets/dashboard_cards.dart';

void main() {
  testWidgets('MetricCard renders label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(label: 'Focus', value: '85'),
        ),
      ),
    );

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
  });
}
