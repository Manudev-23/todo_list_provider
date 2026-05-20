import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String nome;
  final Color cor;
  final IconData icone;

  const CategoryModel({
    this.id,
    required this.nome,
    required this.cor,
    required this.icone,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      cor: Color(map['cor'] as int),
      icone: IconData(map['icone'] as int, fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'cor': cor.toARGB32(),
      'icone': icone.codePoint,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? nome,
    Color? cor,
    IconData? icone,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
    );
  }
}
