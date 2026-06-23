import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/todos/todo_card.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().fetchTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          Consumer<TodoViewModel>(
            builder: (_, todoVM, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todoVM.todos.length} tasks',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.of(context).pushNamed(AppRoutes.addTodo);
          if (result == true && mounted) {
            context.read<TodoViewModel>().fetchTodos(refresh: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            context.read<TodoViewModel>().setSearchQuery(value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: Consumer<TodoViewModel>(
            builder: (_, todoVM, __) => todoVM.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      todoVM.clearSearch();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Colors.white38, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TodoViewModel>(
      builder: (_, todoVM, __) {
        if (todoVM.isLoading) {
          return const LoadingWidget(message: 'Loading tasks...');
        }

        if (todoVM.state == TodoState.error && todoVM.allTodos.isEmpty) {
          return ErrorStateWidget(
            message: todoVM.errorMessage ?? 'Failed to load tasks',
            onRetry: () => todoVM.fetchTodos(),
          );
        }

        final todos = todoVM.todos;

        if (todos.isEmpty) {
          if (todoVM.searchQuery.isNotEmpty) {
            return EmptyStateWidget(
              title: 'No results found',
              subtitle: 'Try a different search term',
              icon: Icons.search_off,
              actionLabel: 'Clear Search',
              onAction: () {
                _searchController.clear();
                todoVM.clearSearch();
              },
            );
          }
          return EmptyStateWidget(
            title: 'No tasks yet',
            subtitle: 'Tap the + button to create your first task',
            icon: Icons.check_circle_outline,
            actionLabel: 'Create Task',
            onAction: () => Navigator.of(context).pushNamed(AppRoutes.addTodo),
          );
        }

        return RefreshIndicator(
          onRefresh: () => todoVM.fetchTodos(refresh: true),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: todos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoCard(
                todo: todo,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.todoDetail, arguments: todo),
                onToggleComplete: () => todoVM.toggleComplete(todo),
                onDelete: () => _confirmDelete(context, todoVM, todo.id),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, TodoViewModel todoVM, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await todoVM.deleteTodo(id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(todoVM.errorMessage ?? 'Failed to delete task'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
