import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:coinbag_flutter/services/monobank_service.dart';
import 'package:coinbag_flutter/screens/monobank/monobank_account_selection_screen.dart';

class AddMonobankScreen extends StatefulWidget {
  const AddMonobankScreen({Key? key}) : super(key: key);

  @override
  _AddMonobankScreenState createState() => _AddMonobankScreenState();
}

class _AddMonobankScreenState extends State<AddMonobankScreen> {
  final _tokenController = TextEditingController();
  final _monobankService = GetIt.I.get<MonobankService>();
  bool _isLoading = false;

  Future<void> _saveTokenAndSync() async {
    final token = _tokenController.text;
    if (token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a token')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clientInfo = await _monobankService.getClientInfo(token);
      if (mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => MonobankAccountSelectionScreen(
              clientInfo: clientInfo,
              token: token,
            ),
          ),
        );
        if (result == true && mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Monobank Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please obtain your API token from the Monobank app and enter it below.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Monobank X-Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveTokenAndSync,
                    child: const Text('Save Token and Sync'),
                  ),
          ],
        ),
      ),
    );
  }
}
