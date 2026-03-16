import 'package:ready_pro/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByEvent(String eventId);
  Future<List<Task>> getTasksByAssignee(String userId);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}
