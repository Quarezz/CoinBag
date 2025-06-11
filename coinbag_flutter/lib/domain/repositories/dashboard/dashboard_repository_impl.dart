import 'package:coinbag_flutter/gateway/network_data_source.dart';
import 'package:coinbag_flutter/domain/repositories/currency/currency_repository.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final NetworkDataSource _networkDataSource;
  final CurrencyRepository _currencyRepository;

  DashboardRepositoryImpl(this._networkDataSource, this._currencyRepository);

  @override
  Future<Map<String, dynamic>> fetchDashboardInfo({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dashboardData = await _networkDataSource.fetchDashboardInfo(
      startDate: startDate,
      endDate: endDate,
    );
    final preferredCurrency = await _currencyRepository.getPreferredCurrency();
    dashboardData['preferredCurrency'] = preferredCurrency?.code ?? 'USD';
    return dashboardData;
  }
}
