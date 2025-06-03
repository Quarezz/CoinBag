import 'package:csv/csv.dart';
import '../models/expense.dart';

class CsvService {
  String exportCsv(List<Expense> expenses) {
    final rows = expenses.map((e) => [e.date.toIso8601String(), e.description, e.amount]).toList();
    return const ListToCsvConverter().convert(rows);
  }

  List<Expense> importCsv(String data) {
    final rows = const CsvToListConverter().convert(data);
    return rows.map((r) => Expense(id: '', description: r[1], amount: r[2], date: DateTime.parse(r[0]), accountId: '')).toList();
  }
}
