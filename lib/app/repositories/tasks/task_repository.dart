import 'package:todo_list_provider/app/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> findByDay(DateTime date);
  Future<int> countByDay(DateTime date);
  Future<int> countByWeek(DateTime weekStart, DateTime weekEnd);
  Future<int> save(TaskModel task);
  Future<void> update(TaskModel task);
  Future<void> delete(int id);
}
