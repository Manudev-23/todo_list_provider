// Use ponto e vírgula aqui

import 'package:sqflite/sqflite.dart';

abstract class Migration {
  void create(Batch batch);
  void update(Batch batch);
}