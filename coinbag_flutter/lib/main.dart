import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
  );
  runApp(const CoinBagApp());
}

class CoinBagApp extends StatefulWidget {
  const CoinBagApp({Key? key}) : super(key: key);

  @override
  State<CoinBagApp> createState() => _CoinBagAppState();
}

class _CoinBagAppState extends State<CoinBagApp> {
  final AuthService _auth = AuthService();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinBag',
      theme: lightTheme,
      home: _auth.isLoggedIn
          ? HomePage(authService: _auth, onLogout: _refresh)
          : LoginScreen(
              authService: _auth,
              onLogin: _refresh,
              allowSkip: true,
            ),
    );
  }
}

class HomePage extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;
  const HomePage({Key? key, required this.authService, required this.onLogout})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const ExpensesListScreen(),
      const AddExpenseScreen(),
      AccountScreen(
        authService: widget.authService,
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
