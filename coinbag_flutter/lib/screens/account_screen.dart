import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Center(
        child: user == null
            ? LoginScreen(
                authService: _auth,
                onLogin: () => setState(() {}),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Logged in as ${user.email}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    key: const Key('signOutButton'),
                    onPressed: () async {
                      await _auth.signOut();
                      setState(() {});
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
