import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/models/task_model.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SqliteConnectionFactory _factory;

  TaskRepositoryImpl({required SqliteConnectionFactory factory})
      : _factory = factory;

  String _dateStr(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Future<List<TaskModel>> findByDay(DateTime date) async {
    final db = await _factory.openConnection();
    final rows = await db.rawQuery(
      '''
      SELECT
        t.*,
        c.nome  AS cat_nome,
        c.cor   AS cat_cor,
        c.icone AS cat_icone
      FROM todo t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE date(t.data_hora) = ?
      ORDER BY t.data_hora ASC
      ''',
      [_dateStr(date)],
    );
    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<int> countByDay(DateTime date) async {
    final db = await _factory.openConnection();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM todo WHERE date(data_hora) = ?',
      [_dateStr(date)],
    );
    return result.first['cnt'] as int? ?? 0;
  }

  @override
  Future<int> countByWeek(DateTime weekStart, DateTime weekEnd) async {
    final db = await _factory.openConnection();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM todo WHERE date(data_hora) BETWEEN ? AND ?',
      [_dateStr(weekStart), _dateStr(weekEnd)],
    );
    return result.first['cnt'] as int? ?? 0;
  }

  @override
  Future<int> save(TaskModel task) async {
    final db = await _factory.openConnection();
    return db.insert('todo', task.toMap());
  }

  @override
  Future<void> update(TaskModel task) async {
    final db = await _factory.openConnection();
    await db.update(
      'todo',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _factory.openConnection();
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [id]);
    await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }
}
