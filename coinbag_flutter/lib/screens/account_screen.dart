import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;
  const AccountScreen({Key? key, required this.authService, required this.onLogout}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500))
        .then((_) => setState(() => _loading = false));
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final loggedIn = widget.authService.isLoggedIn;
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Center(
        child: !loggedIn
            ? LoginScreen(
                authService: widget.authService,
                onLogin: () => setState(() {}),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Logged in as ${widget.authService.currentEmail ?? ''}') ,
                  const SizedBox(height: 12),
                  ElevatedButton(
                    key: const Key('signOutButton'),
                    onPressed: () async {
                      await widget.authService.signOut();
                      widget.onLogout();
                    },
                    child: const Text('Sign Out'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Bank linking and account details'),
                ],
              ),
      ),
    );
  }
}
