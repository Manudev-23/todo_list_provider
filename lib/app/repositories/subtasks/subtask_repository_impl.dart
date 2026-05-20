import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/models/subtask_model.dart';
import 'subtask_repository.dart';

class SubTaskRepositoryImpl implements SubTaskRepository {
  final SqliteConnectionFactory _factory;

  SubTaskRepositoryImpl({required SqliteConnectionFactory factory})
      : _factory = factory;

  @override
  Future<List<SubTaskModel>> findByTaskId(int taskId) async {
    final db = await _factory.openConnection();
    final rows = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'id ASC',
    );
    return rows.map(SubTaskModel.fromMap).toList();
  }

  @override
  Future<List<SubTaskModel>> findByTaskIds(List<int> taskIds) async {
    if (taskIds.isEmpty) return [];
    final db = await _factory.openConnection();
    final placeholders = taskIds.map((_) => '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM subtasks WHERE task_id IN ($placeholders) ORDER BY id ASC',
      taskIds,
    );
    return rows.map(SubTaskModel.fromMap).toList();
  }

  @override
  Future<void> save(SubTaskModel subtask) async {
    final db = await _factory.openConnection();
    await db.insert('subtasks', subtask.toMap());
  }

  @override
  Future<void> update(SubTaskModel subtask) async {
    final db = await _factory.openConnection();
    await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _factory.openConnection();
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteByTaskId(int taskId) async {
    final db = await _factory.openConnection();
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
  }
}
