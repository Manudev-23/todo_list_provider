import 'package:flutter/foundation.dart';
import 'package:todo_list_provider/app/models/subtask_model.dart';
import 'package:todo_list_provider/app/models/task_model.dart';
import 'package:todo_list_provider/app/repositories/subtasks/subtask_repository.dart';
import 'package:todo_list_provider/app/repositories/tasks/task_repository.dart';

class HomeController extends ChangeNotifier {
  final TaskRepository _repository;
  final SubTaskRepository _subTaskRepository;

  HomeController({
    required TaskRepository repository,
    required SubTaskRepository subTaskRepository,
  })  : _repository = repository,
        _subTaskRepository = subTaskRepository;

  DateTime _selectedDate = DateTime.now();
  List<TaskModel> _tasks = [];
  bool _loading = false;
  String? _error;

  int _todayCount = 0;
  int _tomorrowCount = 0;
  int _weekCount = 0;

  DateTime get selectedDate => _selectedDate;
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get loading => _loading;
  String? get error => _error;
  int get todayCount => _todayCount;
  int get tomorrowCount => _tomorrowCount;
  int get weekCount => _weekCount;

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      final results = await Future.wait([
        _repository.findByDay(_selectedDate),
        _repository.countByDay(now),
        _repository.countByDay(tomorrow),
        _repository.countByWeek(monday, sunday),
      ]);

      _tasks = results[0] as List<TaskModel>;
      _todayCount = results[1] as int;
      _tomorrowCount = results[2] as int;
      _weekCount = results[3] as int;

      // Attach subtasks in one batch query
      final taskIds = _tasks.map((t) => t.id).whereType<int>().toList();
      if (taskIds.isNotEmpty) {
        final allSubtasks = await _subTaskRepository.findByTaskIds(taskIds);
        _tasks = _tasks.map((t) {
          final subs = allSubtasks.where((s) => s.taskId == t.id).toList();
          return t.copyWith(subtasks: subs);
        }).toList();
      }
    } catch (e) {
      _error = 'Erro ao carregar tarefas';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectDay(DateTime date) async {
    _selectedDate = date;
    await loadAll();
  }

  // ── Task CRUD ──────────────────────────────────────────────────────────────

  Future<void> addTask(TaskModel task) async {
    try {
      final newId = await _repository.save(task);
      for (final s in task.subtasks) {
        await _subTaskRepository.save(s.copyWith(taskId: newId));
      }
      await loadAll();
    } catch (e) {
      _error = 'Erro ao salvar tarefa';
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.update(task);
      await _syncSubTasks(task);
      await loadAll();
    } catch (e) {
      _error = 'Erro ao atualizar tarefa';
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.delete(id); // also deletes subtasks via cascade in impl
      await loadAll();
    } catch (e) {
      _error = 'Erro ao excluir tarefa';
      notifyListeners();
    }
  }

  Future<void> toggleComplete(TaskModel task) async {
    final updated = task.copyWith(finalizado: !task.finalizado);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks = List.from(_tasks)..[index] = updated;
      notifyListeners();
    }
    try {
      await _repository.update(updated);
    } catch (_) {
      if (index != -1) {
        _tasks = List.from(_tasks)..[index] = task;
        notifyListeners();
      }
    }
  }

  // ── SubTask CRUD ───────────────────────────────────────────────────────────

  Future<void> toggleSubTask(SubTaskModel subtask) async {
    final updated = subtask.copyWith(finalizado: !subtask.finalizado);
    final taskIndex = _tasks.indexWhere((t) => t.id == subtask.taskId);
    List<TaskModel>? rollback;

    if (taskIndex != -1) {
      rollback = List.from(_tasks);
      final task = _tasks[taskIndex];
      final subIndex = task.subtasks.indexWhere((s) => s.id == subtask.id);
      if (subIndex != -1) {
        final newSubs = List<SubTaskModel>.from(task.subtasks)
          ..[subIndex] = updated;
        _tasks = List.from(_tasks)
          ..[taskIndex] = task.copyWith(subtasks: newSubs);
        notifyListeners();
      }
    }

    try {
      await _subTaskRepository.update(updated);
    } catch (_) {
      if (rollback != null) {
        _tasks = rollback;
        notifyListeners();
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _syncSubTasks(TaskModel task) async {
    if (task.id == null) return;
    final existing = await _subTaskRepository.findByTaskId(task.id!);
    final newSubs = task.subtasks;

    for (final s in existing) {
      if (!newSubs.any((n) => n.id == s.id)) {
        await _subTaskRepository.delete(s.id!);
      }
    }
    for (final s in newSubs) {
      if (s.id == null) {
        await _subTaskRepository.save(s.copyWith(taskId: task.id!));
      } else {
        await _subTaskRepository.update(s);
      }
    }
  }
}
