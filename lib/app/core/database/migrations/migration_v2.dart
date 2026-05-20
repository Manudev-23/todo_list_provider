import 'package:sqflite/sqlite_api.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration.dart';

class MigrationV2 implements Migration {
  @override
  void create(Batch batch) {
    // Chamado em instalações novas após MigrationV1 já ter criado a tabela todo.
    // Adiciona a coluna de prioridade: 0=baixa, 1=média, 2=alta.
    batch.execute(
      'ALTER TABLE todo ADD COLUMN prioridade integer not null default 0',
    );
  }

  @override
  void update(Batch batch) {
    // Chamado ao atualizar de v1 → v2 em dispositivos que já tinham o app.
    batch.execute(
      'ALTER TABLE todo ADD COLUMN prioridade integer not null default 0',
    );
  }
}
