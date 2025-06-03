import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class CloudSyncService {
  final SupabaseClient _client;

  CloudSyncService({required String supabaseUrl, required String supabaseAnonKey})
      : _client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<void> uploadData(List<Expense> expenses) async {
    final rows = expenses
        .map((e) => {
              'id': e.id,
              'description': e.description,
              'amount': e.amount,
              'date': e.date.toIso8601String(),
              'account_id': e.accountId,
            })
        .toList();
    await _client.from('expenses').upsert(rows);
  }

  Future<List<Expense>> downloadData() async {
    final data = await _client.from('expenses').select<List<Map<String, dynamic>>>().order('date');
    return data
        .map((r) => Expense(
              id: r['id'] as String,
              description: r['description'] as String,
              amount: (r['amount'] as num).toDouble(),
              date: DateTime.parse(r['date'] as String),
              accountId: r['account_id'] as String,
            ))
        .toList();
  }
}
