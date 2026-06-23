class ApiConstants {
  static const String baseUrl = 'https://karyana.shop';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';

  // Todos
  static const String todos = '/api/todos';
  static String todoById(String id) => '/api/todos/$id';
}
