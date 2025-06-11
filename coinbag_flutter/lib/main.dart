import 'dart:developer' as developer;

import 'package:coinbag_flutter/core/network/http_client_logger.dart';
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_list_screen.dart';
import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

// New Imports
import 'domain/repositories/auth/auth_repository.dart';
import 'domain/auth/authentication_status.dart';
import 'dart:async';

import 'core/service_locator.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    ),
    httpClient: LoggingHttpClient(http.Client()),
  );

  setupServiceLocator();

  developer.log(
    'SUPABASE_URL: ${const String.fromEnvironment('SUPABASE_URL')}',
    name: 'CoinBagApp',
    level: 900,
  );
  developer.log(
    'SUPABASE_ANON_KEY: ${const String.fromEnvironment('SUPABASE_ANON_KEY')}',
    name: 'CoinBagApp',
    level: 900,
  );

  runApp(const CoinBagApp());
}

class CoinBagApp extends StatefulWidget {
  const CoinBagApp({Key? key}) : super(key: key);

  @override
  State<CoinBagApp> createState() => _CoinBagAppState();
}

class _CoinBagAppState extends State<CoinBagApp> {
  late AuthRepository _authRepository;
  late StreamSubscription<AuthenticationStatus> _authStatusSubscription;
  AuthenticationStatus _currentStatus = AuthenticationStatus.unknown;

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepository>();
    _authStatusSubscription = _authRepository.authenticationStatus.listen((
      status,
    ) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _authStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn;
    switch (_currentStatus) {
      case AuthenticationStatus.authenticated:
      case AuthenticationStatus.mockAuthenticated:
        isLoggedIn = true;
        break;
      case AuthenticationStatus.unauthenticated:
      case AuthenticationStatus.unknown:
        isLoggedIn = false;
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoinBag',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: isLoggedIn
          ? HomePage(onLogout: () => setState(() {}))
          : LoginScreen(onLogin: () => setState(() {}), allowSkip: true),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const HomePage({Key? key, required this.onLogout}) : super(key: key);

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
      AccountScreen(onLogout: widget.onLogout),
      SettingsScreen(onLogout: widget.onLogout),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Expenses'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
