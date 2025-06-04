import 'package:flutter/material.dart';

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
        return Scaffold(
          appBar: AppBar(title: const Text('Expenses')),
          body: ListView(
            children: const [
              ListTile(title: Text('Sample expense 1'), subtitle: Text('\$20')),
              ListTile(title: Text('Sample expense 2'), subtitle: Text('\$12')),
            ],
          ),
        );
      },
    );
  }
}
