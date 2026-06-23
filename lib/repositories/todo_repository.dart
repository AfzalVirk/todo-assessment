import 'package:dio/dio.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

class TodoRepository {
  final TodoService _todoService;

  TodoRepository({TodoService? todoService})
      : _todoService = todoService ?? TodoService();

  Future<List<TodoModel>> getAllTodos() async {
    try {
      return await _todoService.getAllTodos();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      return await _todoService.createTodo(todo);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TodoModel> getTodoById(String id) async {
    try {
      return await _todoService.getTodoById(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TodoModel> updateTodo(String id, TodoModel todo) async {
    try {
      return await _todoService.updateTodo(id, todo);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoService.deleteTodo(id);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            'An error occurred';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
