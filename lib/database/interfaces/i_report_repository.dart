abstract class IReportRepository {
  Future<double> getTotalStockValue();
  Future<Map<String, dynamic>> getStatistics();
  Future<List<Map<String, dynamic>>> getStockByCategory();
}
