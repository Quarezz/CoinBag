import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinbag_flutter/screens/settings/category_settings_screen.dart';

void main() {
  testWidgets('Can create a category', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CategorySettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Food');
    await tester.pump();

    // Save category
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);
  });
}
