import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/models/category_model.dart';
import 'package:todo_list_provider/app/models/subtask_model.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50);
      case TaskPriority.medium:
        return const Color(0xFFFF9800);
      case TaskPriority.high:
        return const Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }
}

class TaskModel {
  final int? id;
  final String titulo;
  final DateTime? dataHora;
  final bool finalizado;
  final TaskPriority priority;
  final int? categoryId;

  /// Populado via JOIN no repositório — não salvo no banco diretamente.
  final CategoryModel? category;

  /// Populado via query separada — não salvo no banco diretamente.
  final List<SubTaskModel> subtasks;

  const TaskModel({
    this.id,
    required this.titulo,
    this.dataHora,
    this.finalizado = false,
    this.priority = TaskPriority.low,
    this.categoryId,
    this.category,
    this.subtasks = const [],
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final priorityIndex = (map['prioridade'] as int?) ?? 0;

    CategoryModel? category;
    if (map['cat_nome'] != null) {
      category = CategoryModel(
        id: map['category_id'] as int?,
        nome: map['cat_nome'] as String,
        cor: Color(map['cat_cor'] as int),
        icone: IconData(map['cat_icone'] as int, fontFamily: 'MaterialIcons'),
      );
    }

    return TaskModel(
      id: map['id'] as int?,
      titulo: map['descricao'] as String,
      dataHora: map['data_hora'] != null
          ? DateTime.tryParse(map['data_hora'] as String)
          : null,
      finalizado: (map['finalizado'] as int? ?? 0) == 1,
      priority: TaskPriority.values[priorityIndex.clamp(0, 2)],
      categoryId: map['category_id'] as int?,
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'descricao': titulo,
      // Trunca para 'YYYY-MM-DDTHH:MM:SS' — o SQLite só reconhece até 3
      // casas decimais nos segundos; 6 casas (microsegundos do Dart) fazem
      // date() retornar NULL e a task nunca aparece nas queries por dia.
      'data_hora': dataHora?.toIso8601String().split('.').first,
      'finalizado': finalizado ? 1 : 0,
      'prioridade': priority.index,
      'category_id': categoryId,
    };
  }

  TaskModel copyWith({
    int? id,
    String? titulo,
    DateTime? dataHora,
    bool? finalizado,
    TaskPriority? priority,
    int? categoryId,
    CategoryModel? category,
    List<SubTaskModel>? subtasks,
    bool clearCategory = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      dataHora: dataHora ?? this.dataHora,
      finalizado: finalizado ?? this.finalizado,
      priority: priority ?? this.priority,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      category: clearCategory ? null : (category ?? this.category),
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
