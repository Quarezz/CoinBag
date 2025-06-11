import 'package:coinbag_flutter/data/monobank/client_info.dart';
import 'package:coinbag_flutter/services/monobank_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MonobankAccountSelectionScreen extends StatefulWidget {
  final ClientInfo clientInfo;
  final String token;

  const MonobankAccountSelectionScreen({
    super.key,
    required this.clientInfo,
    required this.token,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MonobankAccountSelectionScreenState createState() =>
      _MonobankAccountSelectionScreenState();
}

class _MonobankAccountSelectionScreenState
    extends State<MonobankAccountSelectionScreen> {
  final Set<String> _selectedAccountIds = {};
  bool _isLoading = false;
  String _progressMessage = '';

  final _monobankService = GetIt.I.get<MonobankService>();

  @override
  void initState() {
    super.initState();
    _monobankService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _progressMessage = progress.message;
          if (progress.isCompleted) {
            _isLoading = false;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(progress.message)));
            Navigator.of(context).pop(true); // Pop back to the previous screen
          }
        });
      }
    });
  }

  void _onAccountSelected(bool? selected, String accountId) {
    setState(() {
      if (selected == true) {
        _selectedAccountIds.add(accountId);
      } else {
        _selectedAccountIds.remove(accountId);
      }
    });
  }

  Future<void> _importAccounts() async {
    if (_selectedAccountIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one account.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _progressMessage = 'Starting import...';
    });

    // The actual work is now kicked off, but the UI updates are driven by the stream.
    // We don't need to await this anymore.
    _monobankService.setupSync(
      widget.token,
      widget.clientInfo,
      _selectedAccountIds.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAccounts = [
      ...widget.clientInfo.accounts,
      ...widget.clientInfo.jars,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Monobank Accounts')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allAccounts.length,
              itemBuilder: (context, index) {
                final account = allAccounts[index];
                final String title;
                final String subtitle;
                final String accountId;

                if (account is Account) {
                  title = 'Card (${account.maskedPan.first})';
                  subtitle = 'Type: ${account.type}';
                  accountId = account.id;
                } else if (account is Jar) {
                  title = account.title;
                  subtitle = 'Jar';
                  accountId = account.id;
                } else {
                  return const SizedBox.shrink();
                }

                return CheckboxListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  value: _selectedAccountIds.contains(accountId),
                  onChanged: (selected) =>
                      _onAccountSelected(selected, accountId),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_progressMessage, textAlign: TextAlign.center),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _importAccounts,
                    child: const Text('Import Selected Accounts'),
                  ),
          ),
        ],
      ),
    );
  }
}
