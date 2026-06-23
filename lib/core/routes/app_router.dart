import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/todos/todo_list_screen.dart';
import '../../views/todos/add_edit_todo_screen.dart';
import '../../views/todos/todo_detail_screen.dart';
import '../../views/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String todoList = '/todos';
  static const String addTodo = '/todos/add';
  static const String editTodo = '/todos/edit';
  static const String todoDetail = '/todos/detail';
  static const String profile = '/profile';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);

      case AppRoutes.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      case AppRoutes.todoList:
        return _buildRoute(const TodoListScreen(), settings);

      case AppRoutes.addTodo:
        return _buildRoute(const AddEditTodoScreen(), settings);

      case AppRoutes.editTodo:
        final todo = settings.arguments as TodoModel;
        return _buildRoute(AddEditTodoScreen(todo: todo), settings);

      case AppRoutes.todoDetail:
        final todo = settings.arguments as TodoModel;
        return _buildRoute(TodoDetailScreen(todo: todo), settings);

      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen(), settings);

      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
