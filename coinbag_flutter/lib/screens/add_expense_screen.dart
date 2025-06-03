import 'package:flutter/material.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Description')),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(decoration: InputDecoration(labelText: 'Category')),
            TextField(decoration: InputDecoration(labelText: 'Tags')),
            TextField(
              decoration:
                  InputDecoration(labelText: 'Recurring interval (days)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
