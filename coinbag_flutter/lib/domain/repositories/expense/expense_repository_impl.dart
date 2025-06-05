import 'package:coinbag_flutter/data/models/expense.dart';
import 'package:coinbag_flutter/gateway/network_data_source.dart';
import 'expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final NetworkDataSource _networkDataSource;

  ExpenseRepositoryImpl(this._networkDataSource);

  @override
  Future<List<Expense>> fetchExpenses({
    required String accountId,
    int page = 0,
    int pageSize = 20,
  }) {
    return _networkDataSource.fetchExpenses(
      accountId: accountId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> addExpense(Expense expense) {
    return _networkDataSource.addExpense(expense);
  }

  @override
  Future<void> removeExpense(String id) {
    return _networkDataSource.removeExpense(id);
  }

  @override
  Future<void> editExpense(Expense expense) {
    return _networkDataSource.editExpense(expense);
  }

  @override
  Future<void> upsertExpenses(List<Expense> expenses) {
    return _networkDataSource.upsertExpenses(expenses);
  }

  @override
  Future<List<Expense>> downloadAllExpenses() {
    return _networkDataSource.downloadAllExpenses();
  }
}
