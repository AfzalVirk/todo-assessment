import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.of(context).pushNamed(AppRoutes.addTodo);
          if (result == true && mounted) {
            context.read<TodoViewModel>().fetchTodos(refresh: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreeting(context),
                const SizedBox(height: 24),
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildRecentTodosSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      title: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 8),
          const Text('Todo'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          tooltip: 'Profile',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _confirmLogout(context),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, authVM, __) {
        final user = authVM.user;
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
                ? 'Good afternoon'
                : 'Good evening';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              user?.name ?? 'User',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (_, todoVM, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: 'Total',
                  value: todoVM.totalCount.toString(),
                  icon: Icons.list_alt,
                  color: AppColors.primary,
                ),
                _StatCard(
                  label: 'Completed',
                  value: todoVM.completedCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.primaryLight,
                ),
                _StatCard(
                  label: 'Pending',
                  value: todoVM.pendingCount.toString(),
                  icon: Icons.hourglass_empty,
                  color: AppColors.priorityMedium,
                ),
                _StatCard(
                  label: 'Overdue',
                  value: todoVM.overdueCount.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.priorityHigh,
                ),
              ],
            ),
            if (todoVM.totalCount > 0) ...[
              const SizedBox(height: 12),
              _buildProgressBar(context, todoVM),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, TodoViewModel todoVM) {
    final progress =
        todoVM.totalCount > 0 ? todoVM.completedCount / todoVM.totalCount : 0.0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.primaryContainer,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${todoVM.completedCount} of ${todoVM.totalCount} tasks completed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTodosSection(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (_, todoVM, __) {
        final recentTodos = todoVM.allTodos.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Tasks',
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.todoList),
                  child: const Text('View all'),
                ),
              ],
            ),
            if (todoVM.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recentTodos.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
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
                child: const Center(
                  child: Text(
                    'No tasks yet. Tap + to create one!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...recentTodos.map(
                (todo) => _RecentTodoTile(
                  todo: todo,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.todoDetail,
                    arguments: todo,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTodoTile extends StatelessWidget {
  final dynamic todo;
  final VoidCallback onTap;

  const _RecentTodoTile({required this.todo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: todo.completed
                ? AppColors.primaryContainer
                : AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            todo.completed ? Icons.check : Icons.radio_button_unchecked,
            color: todo.completed ? AppColors.primary : AppColors.textSecondary,
            size: 18,
          ),
        ),
        title: Text(
          todo.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
                color: todo.completed ? AppColors.completedColor : null,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
