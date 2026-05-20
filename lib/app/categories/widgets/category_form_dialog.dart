import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/models/category_model.dart';

/// Paleta de 12 cores predefinidas (Feature 9 adicionará color picker livre).
const _kColors = [
  Color(0xFF7E57C2), // lilás
  Color(0xFF2196F3), // azul
  Color(0xFF4CAF50), // verde
  Color(0xFFFF9800), // laranja
  Color(0xFFF44336), // vermelho
  Color(0xFFE91E63), // rosa
  Color(0xFF00BCD4), // ciano
  Color(0xFF795548), // marrom
  Color(0xFF607D8B), // azul-cinza
  Color(0xFF9C27B0), // roxo
  Color(0xFFFF5722), // laranja escuro
  Color(0xFF009688), // teal
];

/// Grade de 16 ícones predefinidos.
const _kIcons = [
  Icons.work_outline,
  Icons.home_outlined,
  Icons.fitness_center,
  Icons.shopping_cart_outlined,
  Icons.school_outlined,
  Icons.favorite_outline,
  Icons.directions_car_outlined,
  Icons.restaurant_outlined,
  Icons.attach_money,
  Icons.sports_soccer,
  Icons.book_outlined,
  Icons.music_note_outlined,
  Icons.travel_explore,
  Icons.code,
  Icons.people_outline,
  Icons.pets,
];

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.category?.nome ?? '');
    _selectedColor = widget.category?.cor ?? _kColors.first;
    _selectedIcon = widget.category?.icone ?? _kIcons.first;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CategoryModel(
        id: widget.category?.id,
        nome: _nomeController.text.trim(),
        cor: _selectedColor,
        icone: _selectedIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? 'Editar categoria' : 'Nova categoria'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Nome ──────────────────────────────────────────────────
              TextFormField(
                controller: _nomeController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da categoria',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 20),

              // ── Cor ────────────────────────────────────────────────────
              const Text(
                'COR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kColors.map((color) {
                  final isSelected = color.toARGB32() == _selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black54 : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Ícone ──────────────────────────────────────────────────
              const Text(
                'ÍCONE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kIcons.map((icon) {
                  final isSelected = icon.codePoint == _selectedIcon.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? _selectedColor : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _submit,
          child: Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
