import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/common/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (_, authVM, __) {
          if (authVM.isLoading) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          final user = authVM.user;
          if (user == null) {
            return const Center(child: Text('Failed to load profile'));
          }

          return RefreshIndicator(
            onRefresh: () => authVM.fetchProfile(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(context, authVM),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInfoCard(context, user),
                        const SizedBox(height: 16),
                        _buildStatsCard(context),
                        const SizedBox(height: 16),
                        _buildAccountSection(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthViewModel authVM) {
    final user = authVM.user!;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.initials,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return _SectionCard(
      title: 'Account Info',
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          icon: Icons.badge_outlined,
          label: 'Full Name',
          value: user.name,
        ),
        const Divider(height: 1),
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        if (user.createdAt != null) ...[
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: DateFormatter.toDisplay(user.createdAt!),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (_, todoVM, __) => _SectionCard(
        title: 'Task Statistics',
        icon: Icons.bar_chart,
        children: [
          _StatRow(label: 'Total Tasks', value: todoVM.totalCount),
          const Divider(height: 1),
          _StatRow(
            label: 'Completed',
            value: todoVM.completedCount,
            color: AppColors.primary,
          ),
          const Divider(height: 1),
          _StatRow(
            label: 'Pending',
            value: todoVM.pendingCount,
            color: AppColors.priorityMedium,
          ),
          const Divider(height: 1),
          _StatRow(
            label: 'Overdue',
            value: todoVM.overdueCount,
            color: AppColors.priorityHigh,
          ),
          if (todoVM.totalCount > 0) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completion Rate',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        '${(todoVM.completedCount / todoVM.totalCount * 100).toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: todoVM.completedCount / todoVM.totalCount,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _SectionCard(
      title: 'Account',
      icon: Icons.settings_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.list_alt, color: AppColors.primary),
          title: const Text('View All Tasks'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.todoList),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Logout',
              style: TextStyle(color: AppColors.error)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.error),
          onTap: () => _confirmLogout(context),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        ),
      ],
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
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.login);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _StatRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.textSecondary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
