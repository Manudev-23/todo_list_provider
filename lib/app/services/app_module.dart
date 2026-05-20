import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/database/sqlite_connection_factory.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository_impl.dart';
import 'package:todo_list_provider/app/services/app_widget.dart';
import 'package:todo_list_provider/app/services/user_service.dart';
import 'package:todo_list_provider/app/services/user_service_impl.dart';

class AppModule extends StatelessWidget {

  const AppModule({ super.key });

   @override
   Widget build(BuildContext context) {
       return MultiProvider(
        providers: [ 
          Provider(create: (_) => FirebaseAuth.instance, lazy: false),
          Provider(create: (_)=> SqliteConnectionFactory(), lazy: false),
         Provider(create: (context) => UserRepositoryImpl(firebaseAuth: context.read<FirebaseAuth>())),
         Provider<UserService>(create: (context) => UserServiceImpl(userRepository: context.read<UserRepositoryImpl>())),
         
         
       ],
       child: AppWidget(),
       );
  }
}