import 'package:flutter/material.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../domain/auth/auth_failures.dart';
import 'category_settings_screen.dart';
import 'tag_settings_screen.dart';
import 'automatic_rules_screen.dart';
import '../../core/service_locator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (_) => const AutomaticRulesScreen()),
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
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final info = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Version ${info.version} (${info.buildNumber})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
