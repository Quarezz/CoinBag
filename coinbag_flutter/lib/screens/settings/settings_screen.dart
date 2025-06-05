import 'package:flutter/material.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../domain/auth/auth_failures.dart';
import 'category_settings_screen.dart';
import 'tag_settings_screen.dart';
import 'automatic_rules_screen.dart';
import '../../core/service_locator.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsScreen({Key? key, required this.onLogout}) : super(key: key);

  // Future<void> _load() async { // Removed unnecessary load method
  //   await Future.delayed(const Duration(milliseconds: 500));
  // }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<void>( // Removed FutureBuilder
    //   future: _load(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState != ConnectionState.done) {
    //       return const Scaffold(
    //         body: Center(child: CircularProgressIndicator()),
    //       );
    //     }
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
                  builder: (_) =>
                      const CategorySettingsScreen(), // These sub-screens might need refactoring too
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
                  builder: (_) =>
                      const TagSettingsScreen(), // These sub-screens might need refactoring too
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
                  builder: (_) =>
                      const AutomaticRulesScreen(), // These sub-screens might need refactoring too
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
                final authRepository =
                    getIt<AuthRepository>(); // Added GetIt call
                await authRepository.signOut();
                onLogout();
              } on AuthFailure catch (f) {
                // Catch specific AuthFailure
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: ${f.message}')),
                  );
                }
              } catch (e) {
                // Catch any other unexpected error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An unexpected error occurred: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
