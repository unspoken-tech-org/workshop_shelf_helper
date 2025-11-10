import '../database/interfaces/i_component_repository.dart';
import '../database/interfaces/i_database.dart';
import '../models/component.dart';

class ComponentRepository implements IComponentRepository {
  final IDatabase _database;

  ComponentRepository(this._database);

  @override
  Future<int> create(Component component) async {
    final db = await _database.database;
    return await db.insert('components', component.toMap());
  }

  @override
  Future<List<Component>> getAll() async {
    final db = await _database.database;
    final result = await db.query('components', orderBy: 'model ASC');
    return result.map((map) => Component.fromMap(map)).toList();
  }

  @override
  Future<Component?> getById(int id) async {
    final db = await _database.database;
    final result = await db.query('components', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Component.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<List<Component>> getByCategory(int categoryId) async {
    final db = await _database.database;
    final result = await db.query(
      'components',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'model ASC',
    );
    return result.map((map) => Component.fromMap(map)).toList();
  }

  @override
  Future<int> update(Component component) async {
    final db = await _database.database;
    return await db.update(
      'components',
      component.toMap(),
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
  Future<List<Component>> search({
    String? searchTerm,
    int? categoryId,
    double? minCost,
    double? maxCost,
    String? orderBy,
  }) async {
    final db = await _database.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      whereClause += '(model LIKE ? OR location LIKE ?)';
      whereArgs.add('%$searchTerm%');
      whereArgs.add('%$searchTerm%');
    }

    if (categoryId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category_id = ?';
      whereArgs.add(categoryId);
    }

    if (minCost != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit_cost >= ?';
      whereArgs.add(minCost);
    }

    if (maxCost != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit_cost <= ?';
      whereArgs.add(maxCost);
    }

    final result = await db.query(
      'components',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy ?? 'model ASC',
    );

    return result.map((map) => Component.fromMap(map)).toList();
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
    return result.map((map) => Component.fromMap(map)).toList();
  }
}
