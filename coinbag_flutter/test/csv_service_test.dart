import 'package:flutter_test/flutter_test.dart';
import 'package:coinbag_flutter/services/csv_service.dart';
import 'package:coinbag_flutter/models/expense.dart';

void main() {
  group('CsvService', () {
    test('export and import round trip', () {
      final service = CsvService();
      final expenses = [
        Expense(
          id: '1',
          description: 'Coffee',
          amount: 3.5,
          date: DateTime(2024, 1, 1),
          accountId: 'a1',
        ),
      ];
      final csv = service.exportCsv(expenses);
      final imported = service.importCsv(csv);
      expect(imported.length, 1);
      expect(imported.first.description, 'Coffee');
      expect(imported.first.amount, 3.5);
      expect(imported.first.date, DateTime(2024, 1, 1));
    });
  });
}
