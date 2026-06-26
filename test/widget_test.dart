import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_app/main.dart';

void main() {
  testWidgets('Birthday app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BirthdayApp());
    await tester.pump();

    // App title is visible
    expect(find.text('🎉 Birthday Vibes'), findsOneWidget);

    // Input fields are present
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cake_rounded), findsOneWidget);

    // Celebrate button is present
    expect(find.textContaining("Let's Celebrate!"), findsOneWidget);
  });

  testWidgets('Empty name shows snackbar warning', (WidgetTester tester) async {
    await tester.pumpWidget(const BirthdayApp());
    await tester.pump();

    // Tap celebrate without entering a name
    await tester.tap(find.textContaining("Let's Celebrate!"));
    await tester.pump();

    expect(find.text("Enter a name first! 🎂"), findsOneWidget);
  });

  testWidgets('Entering name navigates to wish screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BirthdayApp());
    await tester.pump();

    // Enter a name
    await tester.enterText(find.byIcon(Icons.person_rounded), 'Alex');
    await tester.enterText(find.byIcon(Icons.cake_rounded), '25');

    // Tap celebrate
    await tester.tap(find.textContaining("Let's Celebrate!"));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Wish screen shows the name
    expect(find.text('Alex'), findsOneWidget);
    expect(find.textContaining('25 candles'), findsOneWidget);
  });
}
