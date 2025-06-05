import 'package:coinbag_flutter/data/models/account.dart';
import 'package:coinbag_flutter/data/models/expense.dart';
import 'package:coinbag_flutter/data/models/category.dart'; // Added import
import 'package:coinbag_flutter/data/models/tag.dart';

abstract class NetworkDataSource {
  // Existing specific methods
  Future<Map<String, dynamic>> fetchDashboardInfo(String accountId);
  Future<Map<String, dynamic>> fetchDashboardSummary();
  Future<List<Expense>> fetchExpenses({int page = 0, int pageSize = 20});
  Future<void> addExpense(Expense expense);
  Future<void> removeExpense(String id);
  Future<void> editExpense(Expense expense);
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String accountId);
  Future<List<Account>> fetchAccounts();
  Future<void> addBankSync(String accountId, Map<String, dynamic> syncData);
  Future<void> upsertExpenses(List<Expense> expenses);
  Future<List<Expense>> downloadAllExpenses();

  // New Category-specific methods
  Future<List<Category>> fetchCategories({required String userId});
  Future<Category> addCategory(CategoryCreationDTO category);
  Future<Category> updateCategory(CategoryUpdateDTO category);
  Future<void> deleteCategory(String categoryId);

  // New Tag-specific methods
  Future<List<Tag>> fetchTags();
}
