import 'package:coinbag_flutter/data/models/currency.dart';

abstract class CurrencyRepository {
  Future<List<Currency>> getAvailableCurrencies();
  Future<Currency?> getPreferredCurrency();
  Future<void> setPreferredCurrency(String currencyCode);
}
