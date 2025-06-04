import 'package:coinbag_flutter/services/iap_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/bank_sync_service.dart';
import '../models/account.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;
  const AccountScreen(
      {Key? key, required this.authService, required this.onLogout})
      : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = true;
  final List<Account> _accounts = [];
  late final BankSyncService _bankSyncService;

  @override
  void initState() {
    super.initState();
    _bankSyncService = BankSyncService(iapService: IapService());
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    // TODO: Load accounts from database
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loading = false;
    });
  }

  Future<void> _addBankAccount() async {
    // TODO: Implement bank account linking
    final success = await _bankSyncService.linkBankAccount('new_account_id');
    if (success) {
      // Refresh accounts list
      _loadAccounts();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need premium to add more bank accounts'),
          ),
        );
      }
    }
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
      appBar: AppBar(title: const Text('Bank Accounts')),
      body: !loggedIn
          ? LoginScreen(
              authService: widget.authService,
              onLogin: () => setState(() {}),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Logged in as ${widget.authService.currentEmail ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: _accounts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('No bank accounts connected'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _addBankAccount,
                                icon: const Icon(Icons.add),
                                label: const Text('Connect Bank Account'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            final account = _accounts[index];
                            return ListTile(
                              leading: const Icon(Icons.account_balance),
                              title: Text(account.name),
                              subtitle: Text(
                                'Balance: \$${account.debitBalance.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.sync),
                                onPressed: () {
                                  // TODO: Implement sync
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: loggedIn && _accounts.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addBankAccount,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
