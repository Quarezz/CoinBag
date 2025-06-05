import 'package:flutter/material.dart';
import 'package:coinbag_flutter/domain/repositories/expense/expense_repository.dart';
import 'package:coinbag_flutter/domain/repositories/auth/auth_repository.dart';
import 'package:coinbag_flutter/data/models/expense.dart';
import 'add_expense_screen.dart';
import '../core/service_locator.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late ExpenseRepository _expenseRepository; // Added
  late AuthRepository _authRepository; // Added

  List<Expense> _expenses = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 0;
  bool _isLastPage = false;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _expenseRepository = getIt<ExpenseRepository>(); // Added
    _authRepository = getIt<AuthRepository>(); // Added
    _loadExpenses();
  }

  Future<void> _loadExpenses({bool loadNextPage = false}) async {
    if (!mounted) return;
    if (loadNextPage && (_loading || _isLastPage)) return;

    setState(() {
      _loading = true;
      if (!loadNextPage) {
        _error = null;
        _expenses = []; // Clear previous expenses if it's a fresh load/reload
        _currentPage = 0;
        _isLastPage = false;
      }
    });

    final accountId =
        _authRepository.currentUserId; // Changed to _authRepository
    if (accountId == null) {
      if (mounted) {
        setState(() {
          _error = "User not logged in. Cannot fetch expenses.";
          _loading = false;
        });
      }
      return;
    }

    try {
      final newExpenses = await _expenseRepository.fetchExpenses(
        // Changed to _expenseRepository
        accountId: accountId,
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (mounted) {
        setState(() {
          _expenses.addAll(newExpenses);
          _currentPage++;
          if (newExpenses.length < _pageSize) {
            _isLastPage = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load expenses: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading && _expenses.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loadExpenses(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (_expenses.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No expenses found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadExpenses(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    } else {
      body = ListView.builder(
        itemCount: _expenses.length + (_isLastPage || _loading ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == _expenses.length && !_isLastPage && !_loading) {
            // Load more indicator or button
            // Trigger load more when this item is almost visible
            // For simplicity, a button here. In a real app, use ScrollController listener.
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => _loadExpenses(loadNextPage: true),
                  child: const Text("Load More"),
                ),
              ),
            );
          }
          if (index >= _expenses.length) {
            return null; // Should not happen if logic is correct
          }

          final expense = _expenses[index];
          return ListTile(
            title: Text(expense.description),
            subtitle: Text(
              'Category: ${expense.categoryId ?? 'N/A'} - Date: ${expense.date.month}/${expense.date.day}/${expense.date.year}',
            ),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: expense.amount < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            // TODO: Add onTap to navigate to expense detail screen or edit screen
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: RefreshIndicator(
        onRefresh: () => _loadExpenses(), // Pull to refresh
        child: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddExpenseScreen. It will need ExpenseRepository and AuthRepository (for accountId).
          // For now, it might break if AddExpenseScreen is not updated yet.
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          if (result == true) {
            // Assuming AddExpenseScreen returns true on success
            _loadExpenses(); // Refresh the list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
