import 'package:workshop_shelf_helper/models/component_filter.dart';

import '../database/interfaces/i_component_repository.dart';
import '../database/interfaces/i_database.dart';
import '../models/component.dart';

class ComponentRepository implements IComponentRepository {
  final IDatabase _database;

  ComponentRepository(this._database);

  @override
  Future<int> create(Component component) async {
    final db = await _database.database;
    return await db.insert('components', component.toDatabaseMap());
  }

  @override
  Future<List<Component>> getAll() async {
    final db = await _database.database;
    final result = await db.query('components', orderBy: 'model ASC');
    return result.map((map) => Component.fromDatabaseMap(map)).toList();
  }

  @override
  Future<Component?> getById(int id) async {
    final db = await _database.database;
    final result = await db.query('components', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Component.fromDatabaseMap(result.first);
    }
    return null;
  }

  @override
  Future<int> update(Component component) async {
    final db = await _database.database;
    return await db.update(
      'components',
      component.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [component.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete('components', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Component>> search(ComponentFilter filter) async {
    final db = await _database.database;

    String whereClause = 'WHERE 1 = 1';

    if (filter.searchTerm?.isNotEmpty ?? false) {
      whereClause +=
          " AND (model LIKE '%${filter.searchTerm}%' OR location LIKE '%${filter.searchTerm}%')";
    }

    if (filter.categoryId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category_id = ${filter.categoryId}';
    }

    if (filter.minCost != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit_cost >= ${filter.minCost}';
    }

    if (filter.maxCost != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit_cost <= ${filter.maxCost}';
    }

    final query = '''
      SELECT c.id, 
      c.category_id, 
      cat.name as category_name, 
      c.model, 
      c.quantity, 
      c.location, 
      c.polarity, 
      c.package, 
      c.unit_cost, 
      c.notes
      FROM components c
      LEFT JOIN categories cat ON c.category_id = cat.id
      $whereClause
      ORDER BY ${filter.orderBy}
      ''';

    final result = await db.rawQuery(query);

    return result.map((map) => Component.fromDatabaseMap(map)).toList();
  }

  @override
  Future<List<Component>> getLowStock(int threshold) async {
    final db = await _database.database;
    final result = await db.query(
      'components',
      where: 'quantity < ?',
      whereArgs: [threshold],
      orderBy: 'quantity ASC',
    );
    return result.map((map) => Component.fromDatabaseMap(map)).toList();
  }
}
