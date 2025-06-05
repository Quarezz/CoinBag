import 'package:coinbag_flutter/data/models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> fetchExpenses({int page = 0, int pageSize = 20});
  Future<void> addExpense(Expense expense);
  Future<void> removeExpense(String id);
  Future<void> editExpense(Expense expense);
  Future<void> upsertExpenses(List<Expense> expenses); // For cloud sync
  Future<List<Expense>> downloadAllExpenses(); // For cloud sync
}
