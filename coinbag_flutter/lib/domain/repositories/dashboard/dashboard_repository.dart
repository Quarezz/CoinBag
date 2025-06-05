abstract class DashboardRepository {
  Future<Map<String, dynamic>> fetchDashboardInfo(String accountId);
  Future<Map<String, dynamic>> fetchDashboardSummary();
}
