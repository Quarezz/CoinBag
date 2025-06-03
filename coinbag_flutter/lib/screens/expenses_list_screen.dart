import 'package:flutter/material.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ListView(
        children: const [
          ListTile(title: Text('Sample expense 1'), subtitle: Text('\$20')),
          ListTile(title: Text('Sample expense 2'), subtitle: Text('\$12')),
        ],
      ),
    );
  }
}
