import 'package:flutter/material.dart';
import 'add_expense_screen.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final items = List.generate(50, (i) {
          final date = DateTime.now().subtract(Duration(days: i));
          return ListTile(
            title: Text('Expense ${i + 1}'),
            subtitle: Text(
                '\$${((i + 1) * 2).toStringAsFixed(2)} - ${date.month}/${date.day}/${date.year}'),
          );
        });
        return Scaffold(
          appBar: AppBar(title: const Text('Expenses')),
          body: ListView(children: items),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
