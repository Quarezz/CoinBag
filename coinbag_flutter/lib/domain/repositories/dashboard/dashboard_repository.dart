abstract class DashboardRepository {
  Future<Map<String, dynamic>> fetchDashboardInfo({
    required DateTime startDate,
    required DateTime endDate,
  });
}
