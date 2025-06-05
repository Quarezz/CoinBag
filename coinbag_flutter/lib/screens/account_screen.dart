import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../domain/repositories/auth/auth_repository.dart';
import '../domain/services/bank_sync_service.dart';
import '../domain/repositories/account/account_repository.dart';
import '../data/models/account.dart';
import 'login_screen.dart';
import '../core/service_locator.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AccountScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AuthRepository _authRepository;
  late BankSyncService _bankSyncService;
  late AccountRepository _accountRepository;

  bool _loading = true;
  List<Account> _accounts = [];
  String? _error;
  bool _isSavingAccount = false;

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepository>();
    _bankSyncService = getIt<BankSyncService>();
    _accountRepository = getIt<AccountRepository>();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final accounts = await _accountRepository.fetchAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load accounts: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addBankAccount() async {
    final success = await _bankSyncService.linkBankAccount(
      'new_account_id_placeholder',
    );
    if (success) {
      _loadAccounts();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to link bank account. You may need premium or try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveManualAccount(String name, double initialBalance) async {
    if (!_authRepository.isLoggedIn || _authRepository.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Cannot save account.'),
        ),
      );
      return;
    }

    setState(() => _isSavingAccount = true);

    try {
      final newAccount = Account(
        id: const Uuid().v4(),
        name: name,
        debitBalance: initialBalance >= 0 ? initialBalance : 0.0,
        creditBalance: initialBalance < 0 ? initialBalance.abs() : 0.0,
      );

      await _accountRepository.addAccount(newAccount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account "${newAccount.name}" added successfully!'),
          ),
        );
        Navigator.of(context).pop();
        _loadAccounts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save account: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingAccount = false);
      }
    }
  }

  void _showAddManualAccountDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Manual Account'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an account name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Balance',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an initial balance';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    if (_isSavingAccount)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: _isSavingAccount
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: _isSavingAccount
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        final name = nameController.text;
                        final balance = double.parse(balanceController.text);
                        _saveManualAccount(name, balance).then((_) {});
                      }
                    },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _accounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accounts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_card_outlined),
              tooltip: 'Add Manual Account',
              onPressed: _showAddManualAccountDialog,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accounts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_card_outlined),
              tooltip: 'Add Manual Account',
              onPressed: _showAddManualAccountDialog,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadAccounts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final loggedIn = _authRepository.isLoggedIn;

    if (!loggedIn) {
      return LoginScreen(
        onLogin: () {
          _loadAccounts();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_outlined),
            tooltip: 'Add Manual Account',
            onPressed: _showAddManualAccountDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Logged in as ${_authRepository.currentUserEmail ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _authRepository.signOut();
                    widget.onLogout();
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _accounts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No accounts found.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _showAddManualAccountDialog,
                            icon: const Icon(Icons.add_card_outlined),
                            label: const Text('Add Manual Account'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _addBankAccount,
                            icon: const Icon(Icons.link),
                            label: const Text('Connect Bank Account'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      double displayBalance =
                          account.debitBalance - account.creditBalance;
                      String balanceText =
                          'Balance: ${displayBalance.toStringAsFixed(2)}';

                      return ListTile(
                        leading: Icon(Icons.account_balance_wallet),
                        title: Text(account.name),
                        subtitle: Text(balanceText),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Options for ${account.name} not implemented yet.',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
