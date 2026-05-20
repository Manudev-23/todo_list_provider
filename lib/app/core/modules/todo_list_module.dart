import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';
import 'package:todo_list_provider/app/core/modules/todo_list_page.dart';

abstract class TodoListModule {
  final Map<String, WidgetBuilder> _routers;
  final List<SingleChildWidget> _bindings;

  TodoListModule({
    List<SingleChildWidget>? bindings,
    required Map<String, WidgetBuilder> routers,
  })  : _bindings = bindings ?? [],
        _routers = routers;

  Map<String, WidgetBuilder> get routers {
      return _routers.map((key, pagebuilder) => MapEntry(key, (context) => TodoListPage
      (bindings: _bindings, page: pagebuilder)));
  }
}
