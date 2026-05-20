import 'package:todo_list_provider/app/core/database/migrations/migration.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration_v1.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration_v2.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration_v3.dart';
import 'package:todo_list_provider/app/core/database/migrations/migration_v4.dart';

class SqliteMigrationFactory {
  List<Migration> getCreateMigration() => [
        MigrationV1(),
        MigrationV2(),
        MigrationV3(),
        MigrationV4(),
      ];

  List<Migration> getUpgradeMigration(int oldVersion) {
    final migrations = <Migration>[];
    if (oldVersion <= 1) migrations.add(MigrationV2());
    if (oldVersion <= 2) migrations.add(MigrationV3());
    if (oldVersion <= 3) migrations.add(MigrationV4());
    return migrations;
  }
}
