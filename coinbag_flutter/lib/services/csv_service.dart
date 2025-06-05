import 'package:csv/csv.dart';
import '../data/models/expense.dart';

class CsvService {
  String exportCsv(List<Expense> expenses) {
    final rows = expenses
        .map(
          (e) => [
            e.date.toIso8601String(),
            e.description,
            e.amount,
            e.categoryId ?? '',
            e.tags.join('|'),
          ],
        )
        .toList();
    return const ListToCsvConverter().convert(rows);
  }

  List<Expense> importCsv(String data) {
    final rows = const CsvToListConverter().convert(data);
    return rows
        .map(
          (r) => Expense(
            id: '',
            description: r[1] as String,
            amount: (r[2] as num).toDouble(),
            date: DateTime.parse(r[0] as String),
            userId: '',
            accountId: '',
            categoryId: (r.length > 3 && (r[3] as String).isNotEmpty)
                ? r[3] as String
                : null,
            tags: r.length > 4 && (r[4] as String).isNotEmpty
                ? (r[4] as String).split('|')
                : <String>[],
          ),
        )
        .toList();
  }
}
