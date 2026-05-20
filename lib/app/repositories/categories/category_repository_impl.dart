import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/models/category_model.dart';
import 'category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SqliteConnectionFactory _factory;

  CategoryRepositoryImpl({required SqliteConnectionFactory factory})
      : _factory = factory;

  @override
  Future<List<CategoryModel>> findAll() async {
    final db = await _factory.openConnection();
    final rows = await db.query('categories', orderBy: 'nome ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<void> save(CategoryModel category) async {
    final db = await _factory.openConnection();
    await db.insert('categories', category.toMap());
  }

  @override
  Future<void> update(CategoryModel category) async {
    final db = await _factory.openConnection();
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _factory.openConnection();
    // Remove a referência nas tasks antes de deletar a categoria
    await db.update(
      'todo',
      {'category_id': null},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
