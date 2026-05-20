// app_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/auth_provider/app_auth_provider.dart';
import 'package:todo_list_provider/app/core/database/migrations/sqlite_adm_connection.dart';
import 'package:todo_list_provider/app/routes/app_routes.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  final sqliteAdmConnection = SqliteAdmConnection();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AppAuthProvider>();
    _router ??= createRouter(authProvider);

    return MaterialApp.router(
      title: 'Todo List Provider',
      routerConfig: _router!,
      debugShowCheckedModeBanner: false,
    );
  }
}
