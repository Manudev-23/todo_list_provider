import 'package:sqflite/sqlite_api.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV3 implements Migration {
  @override
  void create(Batch batch) {
    // Cria tabela de categorias (instalações novas)
    batch.execute('''
      CREATE TABLE categories (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        nome  VARCHAR(100) NOT NULL,
        cor   INTEGER NOT NULL,
        icone INTEGER NOT NULL
      )
    ''');
    // Adiciona FK opcional na tabela todo
    batch.execute('ALTER TABLE todo ADD COLUMN category_id INTEGER');
  }

  @override
  void update(Batch batch) {
    // Atualização de v2 → v3 em dispositivos existentes
    batch.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        nome  VARCHAR(100) NOT NULL,
        cor   INTEGER NOT NULL,
        icone INTEGER NOT NULL
      )
    ''');
    batch.execute('ALTER TABLE todo ADD COLUMN category_id INTEGER');
  }
}
