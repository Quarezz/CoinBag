import 'package:coinbag_flutter/screens/account_details_screen.dart';
import 'package:coinbag_flutter/screens/add_account_screen.dart';
import 'package:coinbag_flutter/screens/monobank/add_monobank_screen.dart';
import 'package:flutter/material.dart';
import '../domain/repositories/account/account_repository.dart';
import '../data/models/account.dart';
import '../core/service_locator.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AccountScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountRepository _accountRepository;

  bool _loading = true;
  List<Account> _accounts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
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

  void _navigateToAddAccount() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddAccountScreen()));
    if (result == true) {
      _loadAccounts();
    }
  }

  void _navigateToAddMonobank() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddMonobankScreen()));
    if (result == true) {
      _loadAccounts();
    }
  }

  void _navigateToAccountDetails(Account account) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)),
    );
    if (result == true) {
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountOptions(),
        tooltip: 'Add Account',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Manual Account'),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToAddAccount();
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Bank Account'),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToAddMonobank();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No accounts found.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddAccountOptions,
              child: const Text('Add your first account'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          final balance = account.debitBalance - account.creditBalance;
          return ListTile(
            title: Text(account.name),
            trailing: Text(
              '\$${balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _navigateToAccountDetails(account),
          );
        },
      ),
    );
  }
}
