import 'package:todo_list_provider/app/models/subtask_model.dart';

abstract class SubTaskRepository {
  Future<List<SubTaskModel>> findByTaskId(int taskId);
  Future<List<SubTaskModel>> findByTaskIds(List<int> taskIds);
  Future<void> save(SubTaskModel subtask);
  Future<void> update(SubTaskModel subtask);
  Future<void> delete(int id);
  Future<void> deleteByTaskId(int taskId);
}
