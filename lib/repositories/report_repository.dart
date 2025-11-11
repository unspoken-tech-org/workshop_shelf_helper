import 'package:workshop_shelf_helper/models/statistics.dart';

import '../database/interfaces/i_report_repository.dart';
import '../database/interfaces/i_database.dart';
import '../models/component_alert.dart';
import '../models/category_stock.dart';

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
  Future<Statistics> getStatistics() async {
    final db = await _database.database;

    final totalCategoriesResult = await db.rawQuery('SELECT COUNT(*) FROM categories');
    final totalCategories = totalCategoriesResult.first.values.first as int? ?? 0;

    final totalComponentsResult = await db.rawQuery('SELECT COUNT(*) FROM components');
    final totalComponents = totalComponentsResult.first.values.first as int? ?? 0;

    final totalValue = await getTotalStockValue();

    final totalStockItemsResult = await db.rawQuery('SELECT SUM(quantity) FROM components');
    final totalStockItems = totalStockItemsResult.first.values.first as int? ?? 0;

    final statistics = Statistics(
      totalCategories: totalCategories,
      totalComponents: totalComponents,
      totalValue: totalValue,
      totalStockItems: totalStockItems,
    );

    return statistics;
  }

  @override
  Future<List<CategoryStock>> getStockByCategory() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        COUNT(comp.id) as component_count,
        SUM(comp.quantity) as item_quantity,
        SUM(comp.quantity * comp.unit_cost) as total_value
      FROM categories c
      LEFT JOIN components comp ON c.id = comp.category_id
      GROUP BY c.id, c.name
      ORDER BY c.name
    ''');

    return result.map((map) => CategoryStock.fromDatabaseMap(map)).toList();
  }

  @override
  Future<List<ComponentAlert>> getLowStockComponents(int threshold) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT c.id, c.model, c.quantity, c.location, c.category_id,
             cat.name as category_name
      FROM components c
      JOIN categories cat ON c.category_id = cat.id
      WHERE c.quantity < ? AND c.quantity > 0
      ORDER BY c.quantity ASC
    ''',
      [threshold],
    );

    return result.map((map) => ComponentAlert.fromDatabaseMap(map)).toList();
  }

  @override
  Future<List<ComponentAlert>> getLowStockComponentsPaginated(
    int threshold,
    int offset,
    int limit,
  ) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT c.id, c.model, c.quantity, c.location, c.category_id,
             cat.name as category_name
      FROM components c
      JOIN categories cat ON c.category_id = cat.id
      WHERE c.quantity < ? AND c.quantity > 0
      ORDER BY c.quantity ASC
      LIMIT ? OFFSET ?
    ''',
      [threshold, limit, offset],
    );

    return result.map((map) => ComponentAlert.fromDatabaseMap(map)).toList();
  }

  @override
  Future<List<ComponentAlert>> getOutOfStockComponents() async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT c.id, c.model, c.quantity, c.location, c.category_id,
             cat.name as category_name
      FROM components c
      JOIN categories cat ON c.category_id = cat.id
      WHERE c.quantity = 0
      ORDER BY c.model
    ''');

    return result.map((map) => ComponentAlert.fromDatabaseMap(map)).toList();
  }

  @override
  Future<List<CategoryStock>> getTopCategoriesByValue(int limit) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      '''
      SELECT c.id, c.name, 
             COUNT(comp.id) as component_count,
             SUM(comp.quantity) as item_quantity,
             SUM(comp.quantity * comp.unit_cost) as total_value
      FROM categories c
      LEFT JOIN components comp ON c.id = comp.category_id
      GROUP BY c.id, c.name
      HAVING total_value > 0
      ORDER BY total_value DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result.map((map) => CategoryStock.fromDatabaseMap(map)).toList();
  }
}
