import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/categories/category_controller.dart';
import 'package:todo_list_provider/app/core/auth_provider/app_auth_provider.dart';
import 'package:todo_list_provider/app/home/home_controller.dart';
import 'package:todo_list_provider/app/home/widgets/task_form_bottom_sheet.dart';
import 'package:todo_list_provider/app/models/category_model.dart';
import 'package:todo_list_provider/app/models/subtask_model.dart';
import 'package:todo_list_provider/app/models/task_model.dart';

const kPrimary = Color(0xFF7E57C2);
const kBackground = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF333333);
const kTextLight = Color(0xFF666666);
const kCardBorder = Color(0xFFEEEEEE);
const kTodayHighlight = Color(0xFF7E57C2);
const kTomorrowHighlight = Color(0xFF2196F3);
const kWeekHighlight = Color(0xFFFF9800);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<int> _expandedTasks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadAll();
    });
  }

  // ─── Abertura do formulário (criar ou editar) ───────────────────────────────
  Future<void> _openForm(HomeController controller, DateTime date,
      {TaskModel? task}) async {
    // Carrega categorias sob demanda antes de abrir o formulário
    final categoryController = context.read<CategoryController>();
    await categoryController.ensureLoaded();

    if (!mounted) return;

    final result = await showModalBottomSheet<TaskModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormBottomSheet(
        initialDate: date,
        task: task,
        categories: categoryController.categories,
      ),
    );
    if (result == null || !mounted) return;

    if (task == null) {
      await controller.addTask(result);
    } else {
      await controller.updateTask(result);
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final controller = context.watch<HomeController>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          'Todo List',
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kTextDark),
      ),
      drawer: _buildDrawer(context, user, authProvider),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(controller, user),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: () => _openForm(controller, controller.selectedDate),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(HomeController controller, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "E aí, ${user?.displayName?.split(' ')[0] ?? 'Usuário'}!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'FILTROS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildFilters(controller),
          const SizedBox(height: 32),
          const Text(
            'DIA DA SEMANA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeekDays(controller),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(
                _sectionTitle(controller.selectedDate),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextLight,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    _openForm(controller, controller.selectedDate),
                icon: const Icon(Icons.add, size: 18, color: kPrimary),
                label: const Text('Adicionar',
                    style: TextStyle(color: kPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTaskList(controller),
          const SizedBox(height: 80), // espaço para o FAB
        ],
      ),
    );
  }

  String _sectionTitle(DateTime date) {
    final now = DateTime.now();
    if (_sameDay(date, now)) return "TASKS DE HOJE";
    if (_sameDay(date, now.add(const Duration(days: 1)))) {
      return "TASKS DE AMANHÃ";
    }
    const months = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
    ];
    return 'TASKS DE ${date.day} ${months[date.month - 1]}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ─── Filtros HOJE / AMANHÃ / SEMANA ─────────────────────────────────────────
  Widget _buildFilters(HomeController controller) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      children: [
        _filterCard(
          '${controller.todayCount}',
          'HOJE',
          kTodayHighlight,
          onTap: () => controller.selectDay(now),
          isSelected: _sameDay(controller.selectedDate, now),
        ),
        _filterCard(
          '${controller.tomorrowCount}',
          'AMANHÃ',
          kTomorrowHighlight,
          onTap: () => controller.selectDay(now.add(const Duration(days: 1))),
          isSelected: _sameDay(
              controller.selectedDate, now.add(const Duration(days: 1))),
        ),
        _filterCard(
          '${controller.weekCount}',
          'SEMANA',
          kWeekHighlight,
          onTap: () => controller.selectDay(monday),
          isSelected: _sameDay(controller.selectedDate, monday),
        ),
      ],
    );
  }

  Widget _filterCard(
    String count,
    String label,
    Color color, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : kCardBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : kTextDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dias da semana ─────────────────────────────────────────────────────────
  Widget _buildWeekDays(HomeController controller) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const months = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
    ];
    const weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (_, index) {
          final date = monday.add(Duration(days: index));
          final isToday = _sameDay(date, now);
          final isSelected = _sameDay(date, controller.selectedDate);

          return GestureDetector(
            // Toque simples: seleciona o dia
            onTap: () => controller.selectDay(date),
            // Toque longo: abre o formulário para criar task nesse dia
            onLongPress: () => _openForm(controller, date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? kPrimary
                      : isToday
                          ? kPrimary.withValues(alpha: 0.5)
                          : kCardBorder,
                  width: isSelected || isToday ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    months[date.month - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kTextLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekdays[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kTextLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Lista de tasks ──────────────────────────────────────────────────────────
  Widget _buildTaskList(HomeController controller) {
    final tasks = controller.tasks;

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCardBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.task_outlined, size: 48, color: kTextLight),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma tarefa para este dia.',
              style: TextStyle(color: kTextLight),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  _openForm(controller, controller.selectedDate),
              icon: const Icon(Icons.add, color: kPrimary),
              label: const Text('Adicionar tarefa',
                  style: TextStyle(color: kPrimary)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return _buildDismissibleTask(controller, task);
      },
    );
  }

  // ─── Dismissible (swipe para excluir) ───────────────────────────────────────
  Widget _buildDismissibleTask(HomeController controller, TaskModel task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Excluir', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Excluir tarefa'),
            content: Text('Deseja excluir "${task.titulo}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: kTextLight)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        if (task.id != null) await controller.deleteTask(task.id!);
      },
      child: _buildTaskCard(controller, task),
    );
  }

  // ─── Card da task ────────────────────────────────────────────────────────────
  Widget _buildTaskCard(HomeController controller, TaskModel task) {
    final priorityColor = task.finalizado ? kCardBorder : task.priority.color;
    final hasSubTasks = task.subtasks.isNotEmpty;
    final doneCount = task.subtasks.where((s) => s.finalizado).length;
    final isExpanded = _expandedTasks.contains(task.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Linha principal ──────────────────────────────────────────
              GestureDetector(
                onTap: () =>
                    _openForm(controller, controller.selectedDate, task: task),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Checkbox circular
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => controller.toggleComplete(task),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.finalizado
                                ? kPrimary
                                : Colors.transparent,
                            border: Border.all(
                              color:
                                  task.finalizado ? kPrimary : kTextLight,
                              width: 2,
                            ),
                          ),
                          child: task.finalizado
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Título + badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.titulo,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: task.finalizado
                                    ? kTextLight
                                    : kTextDark,
                                decoration: task.finalizado
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _PriorityBadge(
                                    priority: task.priority,
                                    dimmed: task.finalizado),
                                if (task.category != null) ...[
                                  const SizedBox(width: 8),
                                  _CategoryBadge(
                                      category: task.category!,
                                      dimmed: task.finalizado),
                                ],
                                if (hasSubTasks) ...[
                                  const SizedBox(width: 8),
                                  _SubTaskBadge(
                                      done: doneCount,
                                      total: task.subtasks.length),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right,
                          color: kTextLight, size: 20),
                    ],
                  ),
                ),
              ),

              // ── Barra de progresso ───────────────────────────────────────
              if (hasSubTasks) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: doneCount / task.subtasks.length,
                      backgroundColor: kCardBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        task.finalizado ? kTextLight : priorityColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),

                // ── Toggle expandir ────────────────────────────────────────
                GestureDetector(
                  onTap: () => setState(() {
                    if (isExpanded) {
                      _expandedTasks.remove(task.id);
                    } else {
                      _expandedTasks.add(task.id!);
                    }
                  }),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded
                              ? 'Ocultar subtarefas'
                              : '$doneCount/${task.subtasks.length} subtarefas',
                          style: const TextStyle(
                              fontSize: 11, color: kTextLight),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 16,
                          color: kTextLight,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Lista de subtarefas ────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(height: 1, color: kCardBorder),
                            ...task.subtasks.map(
                              (sub) => _buildSubTaskRow(controller, sub),
                            ),
                            const SizedBox(height: 4),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTaskRow(HomeController controller, SubTaskModel sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.toggleSubTask(sub),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sub.finalizado ? kPrimary : Colors.transparent,
                border: Border.all(
                  color: sub.finalizado ? kPrimary : kTextLight,
                  width: 1.5,
                ),
              ),
              child: sub.finalizado
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sub.titulo,
              style: TextStyle(
                fontSize: 13,
                color: sub.finalizado ? kTextLight : kTextDark,
                decoration: sub.finalizado
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Drawer ──────────────────────────────────────────────────────────────────
  Widget _buildDrawer(
      BuildContext context, User? user, AppAuthProvider auth) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kPrimary),
            accountName: Text(
              user?.displayName ?? 'Usuário',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            accountEmail: Text(
              user?.email ?? 'email@exemplo.com',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                    fontSize: 26,
                    color: kPrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerItem(
              Icons.home, 'Início', () => Navigator.pop(context)),
          _drawerItem(Icons.category_outlined, 'Categorias', () {
            Navigator.pop(context);
            context.push('/categories');
          }),
          const Divider(color: kCardBorder),
          _drawerItem(Icons.help_outline, 'Ajuda', () {
            Navigator.pop(context);
            _showHelpDialog(context);
          }),
          _drawerItem(Icons.info_outline, 'Sobre', () {
            Navigator.pop(context);
            _showAboutDialog(context);
          }),
          const Spacer(),
          const Divider(color: kCardBorder),
          _drawerItem(Icons.logout, 'Sair', () {
            Navigator.pop(context);
            _showLogoutDialog(context, auth);
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color color = kPrimary}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color == Colors.red ? Colors.red : kTextDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Ajuda', style: TextStyle(color: kTextDark)),
        content: const Text(
          '• Toque em um dia para ver as tarefas\n'
          '• Segure um dia para criar uma task nele\n'
          '• Toque em uma task para editar\n'
          '• Deslize a task para a esquerda para excluir\n'
          '• Toque no círculo para marcar como concluída',
          style: TextStyle(color: kTextLight, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Sobre', style: TextStyle(color: kTextDark)),
        content: const Text('Todo List Provider\nVersão 1.0.0',
            style: TextStyle(color: kTextLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppAuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title:
            const Text('Confirmar saída', style: TextStyle(color: kTextDark)),
        content: const Text('Deseja realmente sair?',
            style: TextStyle(color: kTextLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: kTextLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            child:
                const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Badge de prioridade ──────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool dimmed;

  const _PriorityBadge({required this.priority, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? kTextLight : priority.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(priority.icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          priority.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

// ── Badge de categoria ───────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final CategoryModel category;
  final bool dimmed;

  const _CategoryBadge({required this.category, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? kTextLight : category.cor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(category.icone, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          category.nome,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

// ── Badge de subtarefas ──────────────────────────────────────────────────────

class _SubTaskBadge extends StatelessWidget {
  final int done;
  final int total;

  const _SubTaskBadge({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.checklist_rounded, size: 12, color: kTextLight),
        const SizedBox(width: 3),
        Text(
          '$done/$total',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: kTextLight),
        ),
      ],
    );
  }
}
