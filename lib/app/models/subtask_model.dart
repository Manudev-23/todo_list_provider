class SubTaskModel {
  final int? id;
  final int taskId;
  final String titulo;
  final bool finalizado;

  const SubTaskModel({
    this.id,
    required this.taskId,
    required this.titulo,
    this.finalizado = false,
  });

  factory SubTaskModel.fromMap(Map<String, dynamic> map) => SubTaskModel(
        id: map['id'] as int?,
        taskId: map['task_id'] as int,
        titulo: map['descricao'] as String,
        finalizado: (map['finalizado'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'task_id': taskId,
        'descricao': titulo,
        'finalizado': finalizado ? 1 : 0,
      };

  SubTaskModel copyWith({
    int? id,
    int? taskId,
    String? titulo,
    bool? finalizado,
  }) =>
      SubTaskModel(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        titulo: titulo ?? this.titulo,
        finalizado: finalizado ?? this.finalizado,
      );
}
