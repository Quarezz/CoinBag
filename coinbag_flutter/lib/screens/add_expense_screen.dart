import 'dart:developer' as developer;

import 'package:coinbag_flutter/domain/repositories/auth/auth_repository.dart';
import 'package:coinbag_flutter/domain/repositories/expense/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Assuming GetIt for DI

import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../domain/repositories/categories/category_repository.dart';
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
  late final ExpenseRepository _expenseRepository;
  late final AuthRepository _authRepository;

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categoryRepository = GetIt.I.get<CategoryRepository>();
    _expenseRepository = GetIt.I.get<ExpenseRepository>();
    _authRepository = GetIt.I.get<AuthRepository>();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      _categories = await _categoryRepository.getCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.')),
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
          accountId: '',
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          date: DateTime.now(),
          categoryId: _selectedCategory!.id,
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
      body: _isLoadingCategories
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
                    const TextField(
                      decoration: InputDecoration(labelText: 'Tags (Optional'),
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
