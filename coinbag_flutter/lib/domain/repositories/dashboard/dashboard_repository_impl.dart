import 'package:coinbag_flutter/gateway/network_data_source.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final NetworkDataSource _networkDataSource;

  DashboardRepositoryImpl(this._networkDataSource);

  @override
  Future<Map<String, dynamic>> fetchDashboardInfo({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _networkDataSource.fetchDashboardInfo(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
