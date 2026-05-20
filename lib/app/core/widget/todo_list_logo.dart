import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/core/ui/theme_extensions.dart';

class TodoListLogo extends StatelessWidget {
  const TodoListLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', height: 200),
        Text(
          'Todo List',
          style: context.lato(
            color: const Color(0xFF424242), // Preto suave personalizado
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}