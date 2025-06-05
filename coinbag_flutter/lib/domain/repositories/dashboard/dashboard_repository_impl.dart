import 'package:coinbag_flutter/gateway/network_data_source.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final NetworkDataSource _networkDataSource;

  DashboardRepositoryImpl(this._networkDataSource);

  @override
  Future<Map<String, dynamic>> fetchDashboardInfo(String accountId) {
    return _networkDataSource.fetchDashboardInfo(accountId);
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardSummary() {
    return _networkDataSource.fetchDashboardSummary();
  }
}
