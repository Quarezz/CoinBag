import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coinbag_flutter/data/models/expense.dart';
import 'package:coinbag_flutter/data/models/account.dart';
import 'package:coinbag_flutter/data/models/category.dart';
import 'dart:developer' as developer;
import '../network_data_source.dart';

class SupabaseNetworkDataSource implements NetworkDataSource {
  final SupabaseClient _client;
  static const String _logName = 'SupabaseNetworkDataSource';
  static const String _categoriesTable = 'categories';

  SupabaseNetworkDataSource(this._client);

  @override
  Future<Map<String, dynamic>> fetchDashboardInfo(String accountId) async {
    developer.log(
      'Fetching dashboard info for accountId: $accountId',
      name: _logName,
    );
    try {
      final data = await _client
          .from('dashboard_info')
          .select<Map<String, dynamic>>()
          .eq('account_id', accountId)
          .single();
      developer.log(
        'Successfully fetched dashboard info for accountId: $accountId. Data: $data',
        name: _logName,
      );
      return data;
    } catch (e, s) {
      developer.log(
        'Error fetching dashboard info for accountId: $accountId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardSummary() async {
    developer.log('Fetching dashboard summary via RPC', name: _logName);
    try {
      final data = await _client.rpc('fetch_dashboard_info').single();
      final result = Map<String, dynamic>.from(data);
      developer.log(
        'Successfully fetched dashboard summary. Data: $result',
        name: _logName,
      );
      return result;
    } catch (e, s) {
      developer.log(
        'Error fetching dashboard summary via RPC',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<Expense>> fetchExpenses({
    required String accountId,
    int page = 0,
    int pageSize = 20,
  }) async {
    developer.log(
      'Fetching expenses for accountId: $accountId, page: $page, pageSize: $pageSize',
      name: _logName,
    );
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      final data = await _client
          .from('expenses')
          .select<List<Map<String, dynamic>>>()
          .eq('account_id', accountId)
          .range(from, to)
          .order('date', ascending: false);
      final expenses = data.map(_mapExpense).toList();
      developer.log(
        'Successfully fetched ${expenses.length} expenses for accountId: $accountId',
        name: _logName,
      );
      return expenses;
    } catch (e, s) {
      developer.log(
        'Error fetching expenses for accountId: $accountId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    developer.log(
      'Adding expense: ${expense.id} for accountId: ${expense.accountId}\n${_expenseToMap(expense)}',
      name: _logName,
    );
    try {
      await _client.from('expenses').insert(_expenseToMap(expense));
      developer.log(
        'Successfully added expense: ${expense.id}',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error adding expense: ${expense.id}',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> removeExpense(String id) async {
    developer.log('Removing expense: $id', name: _logName);
    try {
      await _client.from('expenses').delete().eq('id', id);
      developer.log('Successfully removed expense: $id', name: _logName);
    } catch (e, s) {
      developer.log(
        'Error removing expense: $id',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> editExpense(Expense expense) async {
    developer.log('Editing expense: ${expense.id}', name: _logName);
    try {
      await _client
          .from('expenses')
          .update(_expenseToMap(expense))
          .eq('id', expense.id);
      developer.log(
        'Successfully edited expense: ${expense.id}',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error editing expense: ${expense.id}',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> addAccount(Account account) async {
    developer.log('Adding account via RPC: ${account.name}', name: _logName);
    try {
      final params = {
        'name': account.name,
        'initial_debit_balance': account.debitBalance,
        'initial_credit_balance': account.creditBalance,
      };
      await _client.rpc('create_account', params: params);
      developer.log(
        'Successfully called create_account RPC for: ${account.name}',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error calling create_account RPC for: ${account.name}',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateAccount(Account account) async {
    developer.log(
      'Updating account via RPC: ${account.id} - ${account.name}',
      name: _logName,
    );
    try {
      final params = {
        'p_account_id': account.id,
        'p_new_name': account.name,
        'p_debit_balance': account.debitBalance,
        'p_credit_balance': account.creditBalance,
      };
      await _client.rpc('update_account', params: params);
      developer.log(
        'Successfully called update_account RPC for: ${account.id}',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error calling update_account RPC for: ${account.id}',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> addBankSync(
    String accountId,
    Map<String, dynamic> syncData,
  ) async {
    developer.log(
      'Adding bank sync for accountId: $accountId. Data: $syncData',
      name: _logName,
    );
    try {
      await _client.from('bank_syncs').insert({
        'account_id': accountId,
        ...syncData,
      });
      developer.log(
        'Successfully added bank sync for accountId: $accountId',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error adding bank sync for accountId: $accountId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> upsertExpenses(List<Expense> expenses) async {
    if (expenses.isEmpty) return;
    developer.log('Upserting ${expenses.length} expenses', name: _logName);
    try {
      final List<Map<String, dynamic>> expenseMaps = expenses
          .map(_expenseToMap)
          .toList();
      await _client.from('expenses').upsert(expenseMaps);
      developer.log(
        'Successfully upserted ${expenses.length} expenses',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error upserting expenses',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<Expense>> downloadAllExpenses() async {
    developer.log('Downloading all expenses', name: _logName);
    try {
      final data = await _client
          .from('expenses')
          .select<List<Map<String, dynamic>>>();
      final expenses = data.map(_mapExpense).toList();
      developer.log(
        'Successfully downloaded ${expenses.length} expenses',
        name: _logName,
      );
      return expenses;
    } catch (e, s) {
      developer.log(
        'Error downloading all expenses',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<Account>> fetchAccounts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      developer.log(
        'Cannot fetch accounts: User not authenticated.',
        name: _logName,
        level: 900,
      ); // Warning/Error level
      throw Exception('User not authenticated. Cannot fetch accounts.');
    }

    developer.log('Fetching accounts for userId: $userId', name: _logName);
    try {
      final data = await _client
          .from('accounts')
          .select<List<Map<String, dynamic>>>()
          .eq(
            'user_id',
            userId,
          ); // Assuming 'user_id' column in 'accounts' table

      final accounts = data.map(_mapAccount).toList();
      developer.log(
        'Successfully fetched ${accounts.length} accounts for userId: $userId',
        name: _logName,
      );
      return accounts;
    } catch (e, s) {
      developer.log(
        'Error fetching accounts for userId: $userId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Map<String, dynamic> _expenseToMap(Expense e) {
    return {
      'id': e.id,
      'description': e.description,
      'amount': e.amount,
      'date': e.date.toIso8601String(),
      'user_id': e.userId,
      'account_id': e.accountId,
      'category_id': e.categoryId,
      'tags': e.tags,
    };
  }

  Expense _mapExpense(Map<String, dynamic> r) {
    return Expense(
      id: r['id'] as String,
      description: r['description'] as String,
      amount: (r['amount'] as num).toDouble(),
      date: DateTime.parse(r['date'] as String),
      userId: r['user_id'] as String,
      accountId: r['account_id'] as String,
      categoryId: r['category_id'] as String?,
      tags: (r['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }

  Account _mapAccount(Map<String, dynamic> r) {
    return Account(
      id: r['id'] as String,
      name: r['name'] as String,
      debitBalance: (r['debit_balance'] as num?)?.toDouble() ?? 0.0,
      creditBalance: (r['credit_balance'] as num?)?.toDouble() ?? 0.0,
      // userId: r['user_id'] as String, // Assuming Account model has userId if needed elsewhere
    );
  }

  @override
  Future<List<Category>> fetchCategories({required String userId}) async {
    developer.log('Fetching categories for userId: $userId', name: _logName);
    try {
      final data = await _client
          .from(_categoriesTable)
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId)
          .order('name', ascending: true);
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e, s) {
      developer.log(
        'Error fetching categories for userId: $userId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<Category> addCategory(CategoryCreationDTO category) async {
    final createParams = {
      'in_name': category.name,
      'in_icon': category.icon,
      'in_color': category.color,
    };
    developer.log(
      'Calling RPC create_category with params: $createParams',
      name: _logName,
    );
    try {
      final List<Map<String, dynamic>> result = await _client
          .rpc('create_category', params: createParams)
          .select();

      if (result.isEmpty) {
        throw Exception('Failed to add category via RPC, no data returned.');
      }
      return Category.fromJson(result.first);
    } catch (e, s) {
      developer.log(
        'Error calling RPC create_category with params: $createParams',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<Category> updateCategory(CategoryUpdateDTO category) async {
    final updateParams = {
      'p_id': category.id,
      'p_name': category.name,
      'p_icon_name': category.iconName,
      'p_color_hex': category.colorHex,
    };
    developer.log(
      'Calling RPC update_category for id ${category.id} with params: $updateParams',
      name: _logName,
    );
    try {
      final List<Map<String, dynamic>> result = await _client
          .rpc('update_category', params: updateParams)
          .select();

      if (result.isEmpty) {
        throw Exception(
          'Failed to update category via RPC, no data returned or category not found.',
        );
      }
      return Category.fromJson(result.first);
    } catch (e, s) {
      developer.log(
        'Error calling RPC update_category for id ${category.id} with params: $updateParams',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final deleteParams = {'category_id': categoryId};
    developer.log(
      'Calling RPC delete_category for id $categoryId',
      name: _logName,
    );
    try {
      await _client.rpc('delete_category', params: deleteParams);
      developer.log(
        'Successfully called RPC delete_category for id $categoryId',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error calling RPC delete_category for id $categoryId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    developer.log('Deleting account via RPC: $accountId', name: _logName);
    try {
      final params = {'p_account_id': accountId};
      await _client.rpc('delete_account', params: params);
      developer.log(
        'Successfully called delete_account RPC for: $accountId',
        name: _logName,
      );
    } catch (e, s) {
      developer.log(
        'Error calling delete_account RPC for: $accountId',
        name: _logName,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
