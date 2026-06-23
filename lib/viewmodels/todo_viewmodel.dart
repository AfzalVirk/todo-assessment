import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';

enum TodoState { idle, loading, success, error }

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _repository;

  TodoState _state = TodoState.idle;
  String? _errorMessage;
  List<TodoModel> _todos = [];
  String _searchQuery = '';
  bool _isRefreshing = false;

  TodoViewModel({TodoRepository? repository})
      : _repository = repository ?? TodoRepository();

  TodoState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TodoState.loading && !_isRefreshing;
  bool get isRefreshing => _isRefreshing;

  List<TodoModel> get todos => _filterTodos(_todos);
  List<TodoModel> get allTodos => _todos;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.completed).length;
  int get pendingCount => _todos.where((t) => !t.completed).length;
  int get overdueCount => _todos.where((t) => t.isOverdue).length;

  String get searchQuery => _searchQuery;

  Future<void> fetchTodos({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      notifyListeners();
    } else {
      _setState(TodoState.loading);
    }

    try {
      _todos = await _repository.getAllTodos();
      _errorMessage = null;
      _setState(TodoState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<TodoModel?> createTodo(TodoModel todo) async {
    _setState(TodoState.loading);
    try {
      final created = await _repository.createTodo(todo);
      _todos.insert(0, created);
      _setState(TodoState.success);
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return null;
    }
  }

  Future<TodoModel?> updateTodo(String id, TodoModel todo) async {
    _setState(TodoState.loading);
    try {
      final updated = await _repository.updateTodo(id, todo);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updated;
      }
      _setState(TodoState.success);
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return null;
    }
  }

  Future<bool> toggleComplete(TodoModel todo) async {
    final updated = todo.copyWith(completed: !todo.completed);
    final result = await updateTodo(todo.id, updated);
    return result != null;
  }

  Future<bool> deleteTodo(String id) async {
    _setState(TodoState.loading);
    try {
      await _repository.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      _setState(TodoState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return false;
    }
  }

  Future<TodoModel?> fetchTodoById(String id) async {
    try {
      final todo = await _repository.getTodoById(id);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = todo;
      }
      return todo;
    } catch (e) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _setState(TodoState.idle);
  }

  List<TodoModel> _filterTodos(List<TodoModel> todos) {
    if (_searchQuery.isEmpty) return todos;
    final q = _searchQuery.toLowerCase();
    return todos.where((t) {
      return t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _setState(TodoState newState) {
    _state = newState;
    notifyListeners();
  }
}
