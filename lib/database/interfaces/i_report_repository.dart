import 'package:workshop_shelf_helper/models/component_alert.dart';
import 'package:workshop_shelf_helper/models/category_stock.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';

abstract class IReportRepository {
  Future<double> getTotalStockValue();
  Future<Statistics> getStatistics();
  Future<List<CategoryStock>> getStockByCategory();
  Future<List<ComponentAlert>> getLowStockComponents(int threshold);
  Future<List<ComponentAlert>> getLowStockComponentsPaginated(int threshold, int offset, int limit);
  Future<List<ComponentAlert>> getOutOfStockComponents();
  Future<List<CategoryStock>> getTopCategoriesByValue(int limit);
}
