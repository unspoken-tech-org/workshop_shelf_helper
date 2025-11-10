import '../database/interfaces/i_category_repository.dart';
import '../database/interfaces/i_database.dart';
import '../models/category.dart';

class CategoryRepository implements ICategoryRepository {
  final IDatabase _database;

  CategoryRepository(this._database);

  @override
  Future<int> create(Category category) async {
    final db = await _database.database;
    return await db.insert('categories', category.toMap());
  }

  @override
  Future<List<Category>> getAll() async {
    final db = await _database.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  @override
  Future<Category?> getById(int id) async {
    final db = await _database.database;
    final result = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Category.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> update(Category category) async {
    final db = await _database.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await _database.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
