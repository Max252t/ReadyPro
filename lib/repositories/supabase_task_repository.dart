import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ready_pro/models/task.dart';
import 'package:ready_pro/repositories/task_repository.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  SupabaseTaskRepository(this._client);

  @override
  Future<List<Task>> getTasksByEvent(String eventId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('event_id', eventId)
        .order('due_date', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<List<Task>> getTasksByAssignee(String userId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('assignee_id', userId)
        .order('due_date', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    await _client.from('tasks').insert({
      'event_id': task.eventId,
      'assignee_id': task.assigneeId,
      'assigner_id': task.assignerId,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate.toIso8601String(),
      'status': task.isCompleted,
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    await _client.from('tasks').update({
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate.toIso8601String(),
      'status': task.isCompleted,
    }).eq('id', task.id);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
