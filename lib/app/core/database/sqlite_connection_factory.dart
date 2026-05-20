import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:todo_list_provider/app/core/database/sqlite_migration_factory.dart';

class SqliteConnectionFactory {
  static const _VERSION = 4;
  static const _DATABASE_NAME = 'TODO_LIST_PROVIDER.db';

  // Singleton
  static SqliteConnectionFactory? _instance;
  SqliteConnectionFactory._();
  factory SqliteConnectionFactory() {
    _instance ??= SqliteConnectionFactory._();
    return _instance!;
  }

  Database? _db;
  final _lock = Lock(); // evita múltiplas aberturas simultâneas

  // 🔹 Abre a conexão com lock
  Future<Database> openConnection() async {
    return await _lock.synchronized(() async {
      if (_db != null && _db!.isOpen) return _db!;

      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _DATABASE_NAME);

      _db = await openDatabase(
        path,
        version: _VERSION,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );

      return _db!;
    });
  }

  // 🔹 Fecha a conexão
  Future<void> closeConnection() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  // 🔹 Configurações do banco
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 🔹 Criação da tabela
  
  // aplica as mudanças
 Future<void> _onCreate(Database db, int version) async {
  final batch = db.batch();

  final migrations = SqliteMigrationFactory().getCreateMigration();

  for (var migration in migrations) {
    migration.create(batch);
  }

  await batch.commit();
}
  // Migração para versões superiores
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();

  final migrations = SqliteMigrationFactory().getUpgradeMigration(oldVersion);

  for (var migration in migrations) {
    migration.update(batch);
  }

  await batch.commit();
  }

  //  Migração para versões inferiores
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Normalmente não usado, mas  pode reverter alterações se necessário
  }
}
