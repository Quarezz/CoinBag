import 'dart:developer' as developer;

import 'package:coinbag_flutter/domain/repositories/auth/auth_repository.dart';
import 'package:coinbag_flutter/domain/repositories/expense/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Assuming GetIt for DI

import '../../data/models/account.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/models/tag.dart';
import '../domain/repositories/account/account_repository.dart';
import '../domain/repositories/categories/category_repository.dart';
import '../domain/repositories/tags/tag_repository.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  late final CategoryRepository _categoryRepository;
  late final AccountRepository _accountRepository;
  late final ExpenseRepository _expenseRepository;
  late final AuthRepository _authRepository;
  late final TagRepository _tagRepository;

  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Account> _accounts = [];
  Account? _selectedAccount;
  List<Tag> _tags = [];
  final List<Tag> _selectedTags = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categoryRepository = GetIt.I.get<CategoryRepository>();
    _accountRepository = GetIt.I.get<AccountRepository>();
    _expenseRepository = GetIt.I.get<ExpenseRepository>();
    _authRepository = GetIt.I.get<AuthRepository>();
    _tagRepository = GetIt.I.get<TagRepository>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _categories = await _categoryRepository.getCategories();
      _accounts = await _accountRepository.fetchAccounts();
      _tags = await _tagRepository.getTags();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null || _selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category and an account.'),
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final expense = Expense(
          id: const Uuid().v4(),
          userId: _authRepository.currentUserId!,
          accountId: _selectedAccount!.id,
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          date: DateTime.now(),
          categoryId: _selectedCategory!.id,
          tags: _selectedTags.map((t) => t.id).toList(),
        );

        await _expenseRepository.addExpense(expense);

        developer.log(
          'Expense to save: ${expense.description}, ${expense.amount}, ${expense.categoryId}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save expense: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be positive';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Account>(
                      value: _selectedAccount,
                      hint: const Text('Select Account'),
                      isExpanded: true,
                      items: _accounts.map((Account account) {
                        return DropdownMenuItem<Account>(
                          value: account,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (Account? newValue) {
                        setState(() {
                          _selectedAccount = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select an account' : null,
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      hint: const Text('Select Category'),
                      isExpanded: true,
                      items: _categories.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category, // Uses the Category object itself
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tags'),
                    Wrap(
                      spacing: 8.0,
                      children: _tags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveExpense,
                            child: const Text('Save Expense'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
