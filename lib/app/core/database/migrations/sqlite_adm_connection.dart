import 'package:flutter/widgets.dart';
import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';

class SqliteAdmConnection with WidgetsBindingObserver{


  final connection = SqliteConnectionFactory();
  
  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      connection.openConnection();
      break;
    default: // pega inactive, paused, detached e hidden
      connection.closeConnection();
      break;
  }

  super.didChangeAppLifecycleState(state);
}


   

}