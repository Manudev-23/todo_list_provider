import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/models/category_model.dart';
import 'package:todo_list_provider/app/models/subtask_model.dart';
import 'package:todo_list_provider/app/models/task_model.dart';

const _kPrimary = Color(0xFF7E57C2);
const _kTextDark = Color(0xFF333333);
const _kCardBorder = Color(0xFFEEEEEE);

class TaskFormBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final TaskModel? task;
  final List<CategoryModel> categories;

  const TaskFormBottomSheet({
    super.key,
    required this.initialDate,
    required this.categories,
    this.task,
  });

  @override
  State<TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends State<TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _subTaskController;
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;
  int? _selectedCategoryId;
  late List<SubTaskModel> _subtasks;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.task?.titulo ?? '');
    _subTaskController = TextEditingController();
    _selectedDate = widget.task?.dataHora ?? widget.initialDate;
    _selectedPriority = widget.task?.priority ?? TaskPriority.low;
    _selectedCategoryId = widget.task?.categoryId;
    _subtasks = List.from(widget.task?.subtasks ?? []);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TaskModel(
        id: widget.task?.id,
        titulo: _tituloController.text.trim(),
        dataHora: _selectedDate,
        finalizado: widget.task?.finalizado ?? false,
        priority: _selectedPriority,
        categoryId: _selectedCategoryId,
        subtasks: _subtasks,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _addSubTask() {
    final text = _subTaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks = [
        ..._subtasks,
        SubTaskModel(taskId: widget.task?.id ?? 0, titulo: text),
      ];
      _subTaskController.clear();
    });
  }

  void _toggleSubTask(int index) {
    setState(() {
      final s = _subtasks[index];
      _subtasks = List.from(_subtasks)
        ..[index] = s.copyWith(finalizado: !s.finalizado);
    });
  }

  void _removeSubTask(int index) {
    setState(() => _subtasks = List.from(_subtasks)..removeAt(index));
  }

  String _formatDate(DateTime d) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabeçalho ───────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      isEditing ? 'Editar tarefa' : 'Nova tarefa',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _kTextDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Título ───────────────────────────────────────────────────
                TextFormField(
                  controller: _tituloController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título da tarefa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt, color: _kPrimary),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),

                // ── Data ─────────────────────────────────────────────────────
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: _kPrimary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                              fontSize: 15, color: _kTextDark),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: _kPrimary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Prioridade ───────────────────────────────────────────────
                const _SectionLabel('Prioridade'),
                const SizedBox(height: 8),
                _PrioritySelector(
                  selected: _selectedPriority,
                  onChanged: (p) => setState(() => _selectedPriority = p),
                ),
                const SizedBox(height: 16),

                // ── Categoria ────────────────────────────────────────────────
                if (widget.categories.isNotEmpty) ...[
                  const _SectionLabel('Categoria'),
                  const SizedBox(height: 8),
                  _CategorySelector(
                    categories: widget.categories,
                    selectedId: _selectedCategoryId,
                    onChanged: (id) =>
                        setState(() => _selectedCategoryId = id),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Subtarefas ───────────────────────────────────────────────
                const _SectionLabel('Subtarefas'),
                const SizedBox(height: 8),

                ..._subtasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sub = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleSubTask(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sub.finalizado
                                  ? _kPrimary
                                  : Colors.transparent,
                              border: Border.all(
                                color: sub.finalizado
                                    ? _kPrimary
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: sub.finalizado
                                ? const Icon(Icons.check,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sub.titulo,
                            style: TextStyle(
                              fontSize: 14,
                              color: sub.finalizado
                                  ? Colors.grey
                                  : _kTextDark,
                              decoration: sub.finalizado
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeSubTask(index),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }),

                // Input para nova subtarefa
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subTaskController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Nova subtarefa...',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _addSubTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addSubTask,
                      child: const Icon(Icons.add_circle,
                          color: _kPrimary, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Botão salvar ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      isEditing ? 'Salvar alterações' : 'Adicionar tarefa',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? priority.color.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? priority.color : _kCardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(priority.icon,
                      size: 18,
                      color: isSelected ? priority.color : Colors.grey),
                  const SizedBox(height: 4),
                  Text(
                    priority.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? priority.color : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'Nenhuma',
            icon: Icons.block_outlined,
            color: Colors.grey,
            isSelected: selectedId == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: cat.nome,
                  icon: cat.icone,
                  color: cat.cor,
                  isSelected: cat.id == selectedId,
                  onTap: () => onChanged(cat.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : _kCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
