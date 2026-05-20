import 'package:sqflite/sqlite_api.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV4 implements Migration {
  @override
  void create(Batch batch) {
    batch.execute('''
      CREATE TABLE subtasks (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id   INTEGER NOT NULL,
        descricao VARCHAR(200) NOT NULL,
        finalizado INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  @override
  void update(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS subtasks (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id   INTEGER NOT NULL,
        descricao VARCHAR(200) NOT NULL,
        finalizado INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
