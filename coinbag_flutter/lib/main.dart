import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/account_screen.dart';

void main() {
  runApp(const CoinBagApp());
}

class CoinBagApp extends StatelessWidget {
  const CoinBagApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinBag',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    ExpensesListScreen(),
    AddExpenseScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Accounts'),
        ],
      ),
    );
  }
}
