import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:todo_list_provider/app/categories/category_controller.dart';
import 'package:todo_list_provider/app/core/auth_provider/app_auth_provider.dart';
import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/home/home_controller.dart';
import 'package:todo_list_provider/app/modules/auth/login/login_controller.dart';
import 'package:todo_list_provider/app/modules/auth/register/register_controller.dart';
import 'package:todo_list_provider/app/repositories/categories/category_repository.dart';
import 'package:todo_list_provider/app/repositories/categories/category_repository_impl.dart';
import 'package:todo_list_provider/app/repositories/subtasks/subtask_repository.dart';
import 'package:todo_list_provider/app/repositories/subtasks/subtask_repository_impl.dart';
import 'package:todo_list_provider/app/repositories/tasks/task_repository.dart';
import 'package:todo_list_provider/app/repositories/tasks/task_repository_impl.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository_impl.dart';
import 'package:todo_list_provider/app/services/app_widget.dart';
import 'package:todo_list_provider/app/services/user_service.dart';
import 'package:todo_list_provider/app/services/user_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAL3llrcYuREmAyETfHjaNbXoHzAZY1YfE",
      appId: "1:922011572875:android:983b87246ea897898ed28e",
      messagingSenderId: "922011572875",
      projectId: "todo-list-providerr",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // ── Infraestrutura ──────────────────────────────────────────────────
        Provider<SqliteConnectionFactory>(
          create: (_) => SqliteConnectionFactory(),
        ),

        // ── Repositórios ────────────────────────────────────────────────────
        Provider<UserRepository>(
          create: (_) => UserRepositoryImpl(),
        ),
        Provider<TaskRepository>(
          create: (context) => TaskRepositoryImpl(
            factory: context.read<SqliteConnectionFactory>(),
          ),
        ),
        Provider<CategoryRepository>(
          create: (context) => CategoryRepositoryImpl(
            factory: context.read<SqliteConnectionFactory>(),
          ),
        ),
        Provider<SubTaskRepository>(
          create: (context) => SubTaskRepositoryImpl(
            factory: context.read<SqliteConnectionFactory>(),
          ),
        ),

        // ── Serviços ────────────────────────────────────────────────────────
        Provider<UserService>(
          create: (context) => UserServiceImpl(
            userRepository: context.read<UserRepository>(),
          ),
        ),

        // ── Controllers ─────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (context) => RegisterController(
            userService: context.read<UserService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginController(
            userService: context.read<UserService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeController(
            repository: context.read<TaskRepository>(),
            subTaskRepository: context.read<SubTaskRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryController(
            repository: context.read<CategoryRepository>(),
          ),
        ),

        // ── Auth ────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (context) => AppAuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            userService: context.read<UserService>(),
          ),
        ),
      ],
      child: const AppWidget(),
    ),
  );
}
