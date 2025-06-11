import 'package:coinbag_flutter/data/models/currency.dart';
import 'package:coinbag_flutter/domain/repositories/currency/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  // This could be replaced with a network call or local storage in the future
  final List<Currency> _availableCurrencies = [
    Currency(code: 'USD', name: 'US Dollar'),
    Currency(code: 'EUR', name: 'Euro'),
    Currency(code: 'GBP', name: 'British Pound'),
    Currency(code: 'UAH', name: 'Ukrainian Hryvnia'),
  ];

  // Placeholder for storing preferred currency, could be SharedPreferences or similar
  String? _preferredCurrencyCode;

  @override
  Future<List<Currency>> getAvailableCurrencies() async {
    return _availableCurrencies;
  }

  @override
  Future<Currency?> getPreferredCurrency() async {
    if (_preferredCurrencyCode == null) {
      return null;
    }
    return _availableCurrencies.firstWhere(
      (currency) => currency.code == _preferredCurrencyCode,
      orElse: () => _availableCurrencies[0],
    );
  }

  @override
  Future<void> setPreferredCurrency(String currencyCode) async {
    _preferredCurrencyCode = currencyCode;
  }
}
