import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';
import '../models/account.dart';

class SupabaseApiService {
  final SupabaseClient _client;

  SupabaseApiService({required String supabaseUrl, required String supabaseAnonKey})
      : _client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<Map<String, dynamic>> fetchDashboardInfo(String accountId) async {
    final data = await _client
        .from('dashboard_info')
        .select<Map<String, dynamic>>()
        .eq('account_id', accountId)
        .single();
    return data;
  }

  Future<List<Expense>> fetchExpenses({required String accountId, int page = 0, int pageSize = 20}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final data = await _client
        .from('expenses')
        .select<List<Map<String, dynamic>>>()
        .eq('account_id', accountId)
        .range(from, to)
        .order('date', ascending: false);
    return data.map(_mapExpense).toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _client.from('expenses').insert({
      'id': expense.id,
      'description': expense.description,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'account_id': expense.accountId,
    });
  }

  Future<void> removeExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  Future<void> editExpense(Expense expense) async {
    await _client.from('expenses').update({
      'description': expense.description,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'account_id': expense.accountId,
    }).eq('id', expense.id);
  }

  Future<void> addAccount(Account account) async {
    await _client.from('accounts').insert({
      'id': account.id,
      'name': account.name,
      'debit_balance': account.debitBalance,
      'credit_balance': account.creditBalance,
    });
  }

  Future<void> updateAccount(Account account) async {
    await _client.from('accounts').update({
      'name': account.name,
      'debit_balance': account.debitBalance,
      'credit_balance': account.creditBalance,
    }).eq('id', account.id);
  }

  Future<void> addBankSync(String accountId, Map<String, dynamic> syncData) async {
    await _client.from('bank_syncs').insert({
      'account_id': accountId,
      ...syncData,
    });
  }

  Expense _mapExpense(Map<String, dynamic> r) {
    return Expense(
      id: r['id'] as String,
      description: r['description'] as String,
      amount: (r['amount'] as num).toDouble(),
      date: DateTime.parse(r['date'] as String),
      accountId: r['account_id'] as String,
    );
  }
}
