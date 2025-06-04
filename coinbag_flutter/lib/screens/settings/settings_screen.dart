import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'category_settings_screen.dart';
import 'tag_settings_screen.dart';
import 'automatic_rules_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService authService;
  final VoidCallback onLogout;

  const SettingsScreen({
    Key? key,
    required this.authService,
    required this.onLogout,
  }) : super(key: key);

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
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              ListTile(
                title: const Text('Categories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategorySettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Tags'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TagSettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Automatic Rules'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AutomaticRulesScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Sign Out'),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  try {
                    await authService.signOut();
                    onLogout();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
