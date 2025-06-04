import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinbag_flutter/main.dart';
import 'package:coinbag_flutter/screens/dashboard_screen.dart';
import 'package:coinbag_flutter/screens/expenses_list_screen.dart';
import 'package:coinbag_flutter/screens/add_expense_screen.dart';
import 'package:coinbag_flutter/screens/account_screen.dart';
import 'package:coinbag_flutter/screens/settings/tag_settings_screen.dart';

void main() {
  group('Individual screens', () {
    testWidgets('Dashboard screen shows chart and bills', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Spending Over Time'), findsOneWidget);
      expect(find.text('Upcoming Bills'), findsOneWidget);
    });

    testWidgets('Expenses list screen shows sample data', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExpensesListScreen()));
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Expense 1'), findsOneWidget);
    });

    testWidgets('Add expense screen shows rich entry form', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('Recurring interval (days)'), findsOneWidget);
    });

    testWidgets('Account screen shows login form when signed out', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Tag settings allows creating a tag', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TagSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Tags'), findsOneWidget);
      final initialCount = tester.widgetList(find.byType(ListTile)).length;

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.tap(find.widgetWithIcon(CircleAvatar, Icons.check));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final newCount = tester.widgetList(find.byType(ListTile)).length;
      expect(newCount, initialCount + 1);
    });
  });

  testWidgets('Home navigation shows all screens', (tester) async {
    await tester.pumpWidget(const CoinBagApp());

    // Dashboard by default
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Spending Over Time'), findsOneWidget);

    // Navigate to Expenses list
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Expense 1'), findsOneWidget);

    // Open Add screen via action button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    // Navigate to Accounts
    await tester.tap(find.byIcon(Icons.account_balance));
    await tester.pumpAndSettle();
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
