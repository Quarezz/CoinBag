import 'package:flutter/material.dart';
import '../../../core/service_locator.dart';
import '../../../domain/repositories/currency/currency_repository.dart';
import '../../../data/models/currency.dart';

class CurrencySettingsScreen extends StatelessWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferred Currency')),
      body: FutureBuilder<List<Currency>>(
        future: getIt<CurrencyRepository>().getAvailableCurrencies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final currencies = snapshot.data ?? [];
          return FutureBuilder<Currency?>(
            future: getIt<CurrencyRepository>().getPreferredCurrency(),
            builder: (context, preferredSnapshot) {
              if (preferredSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final currentPreferred = preferredSnapshot.data;
              return ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  return ListTile(
                    title: Text(currency.name),
                    trailing: currentPreferred?.code == currency.code
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () async {
                      await getIt<CurrencyRepository>().setPreferredCurrency(
                        currency.code,
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
