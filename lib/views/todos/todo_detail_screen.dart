import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/todos/priority_chip.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoModel todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TodoModel _todo;
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _refreshTodo();
  }

  Future<void> _refreshTodo() async {
    final todoVM = context.read<TodoViewModel>();
    final fresh = await todoVM.fetchTodoById(_todo.id);
    if (fresh != null && mounted) {
      setState(() => _todo = fresh);
    }
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 20),
            _buildTitle(context),
            const SizedBox(height: 16),
            if (_todo.description != null && _todo.description!.isNotEmpty)
              _buildDescription(context),
            const SizedBox(height: 16),
            _buildDetailsCard(context),
            const SizedBox(height: 24),
            _buildToggleButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isCompleted = _todo.completed;
    final isOverdue = _todo.isOverdue;

    Color bannerColor;
    String bannerText;
    IconData bannerIcon;

    if (isCompleted) {
      bannerColor = AppColors.primary;
      bannerText = 'Completed';
      bannerIcon = Icons.check_circle;
    } else if (isOverdue) {
      bannerColor = AppColors.error;
      bannerText = 'Overdue';
      bannerIcon = Icons.warning_amber;
    } else {
      bannerColor = AppColors.priorityMedium;
      bannerText = 'In Progress';
      bannerIcon = Icons.hourglass_bottom;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 20),
          const SizedBox(width: 8),
          Text(
            bannerText,
            style: TextStyle(
              color: bannerColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _todo.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            decoration: _todo.completed ? TextDecoration.lineThrough : null,
            color: _todo.completed ? AppColors.completedColor : null,
          ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          _todo.description!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: null,
            widget: PriorityChip(priority: _todo.priority),
          ),
          if (_todo.dueDate != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Due Date',
              value: DateFormatter.toDisplay(_todo.dueDate!),
              valueColor: _todo.isOverdue ? AppColors.error : null,
            ),
          ],
          if (_todo.createdAt != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Created',
              value: DateFormatter.toFull(_todo.createdAt!),
            ),
          ],
          if (_todo.updatedAt != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              context,
              icon: Icons.update,
              label: 'Updated',
              value: DateFormatter.formatRelative(_todo.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    Widget? widget,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Spacer(),
        widget ??
            Text(
              value ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
            ),
      ],
    );
  }

  Widget _buildToggleButton(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (_, todoVM, __) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: todoVM.isLoading
              ? null
              : () async {
                  final success = await todoVM.toggleComplete(_todo);
                  if (success && mounted) {
                    setState(() {
                      _todo = _todo.copyWith(completed: !_todo.completed);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _todo.completed
                              ? 'Task marked as completed!'
                              : 'Task marked as pending',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
          icon: todoVM.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  _todo.completed ? Icons.replay : Icons.check_circle_outline),
          label: Text(_todo.completed ? 'Mark as Pending' : 'Mark as Complete'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _todo.completed ? AppColors.textSecondary : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.editTodo,
      arguments: _todo,
    );
    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This task will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final todoVM = context.read<TodoViewModel>();
              final success = await todoVM.deleteTodo(_todo.id);
              if (mounted) {
                if (success) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(todoVM.errorMessage ?? 'Failed to delete task'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
