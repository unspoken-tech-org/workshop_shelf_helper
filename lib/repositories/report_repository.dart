import '../database/interfaces/i_report_repository.dart';
import '../database/interfaces/i_database.dart';

class ReportRepository implements IReportRepository {
  final IDatabase _database;

  ReportRepository(this._database);

  @override
  Future<double> getTotalStockValue() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT SUM(quantity * unit_cost) as total FROM components');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _database.database;

    final totalCategoriesResult = await db.rawQuery('SELECT COUNT(*) FROM categories');
    final totalCategories = totalCategoriesResult.first.values.first as int? ?? 0;

    final totalComponentsResult = await db.rawQuery('SELECT COUNT(*) FROM components');
    final totalComponents = totalComponentsResult.first.values.first as int? ?? 0;

    final totalValue = await getTotalStockValue();

    final totalStockItemsResult = await db.rawQuery('SELECT SUM(quantity) FROM components');
    final totalStockItems = totalStockItemsResult.first.values.first as int? ?? 0;

    return {
      'totalCategories': totalCategories,
      'totalComponents': totalComponents,
      'totalValue': totalValue,
      'totalStockItems': totalStockItems,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getStockByCategory() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name as category,
        COUNT(comp.id) as component_count,
        SUM(comp.quantity) as item_quantity,
        SUM(comp.quantity * comp.unit_cost) as total_value
      FROM categories c
      LEFT JOIN components comp ON c.id = comp.category_id
      GROUP BY c.id, c.name
      ORDER BY c.name
    ''');

    return result;
  }
}
