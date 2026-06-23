import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/todo_model.dart';

class TodoService {
  final Dio _dio = DioClient.instance;

  Future<List<TodoModel>> getAllTodos() async {
    final response = await _dio.get(ApiConstants.todos);
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('todos')) {
      list = data['todos'] as List<dynamic>;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List<dynamic>;
    } else {
      list = [];
    }
    return list
        .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await _dio.post(
      ApiConstants.todos,
      data: todo.toCreateJson(),
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('data')) {
      return TodoModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return TodoModel.fromJson(data);
  }

  Future<TodoModel> getTodoById(String id) async {
    final response = await _dio.get(ApiConstants.todoById(id));
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('data')) {
      return TodoModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return TodoModel.fromJson(data);
  }

  Future<TodoModel> updateTodo(String id, TodoModel todo) async {
    final response = await _dio.put(
      ApiConstants.todoById(id),
      data: todo.toUpdateJson(),
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('data')) {
      return TodoModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return TodoModel.fromJson(data);
  }

  Future<void> deleteTodo(String id) async {
    await _dio.delete(ApiConstants.todoById(id));
  }
}
