class AppConstants {
  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Todo priority levels
  static const String priorityHigh = 'high';
  static const String priorityMedium = 'medium';
  static const String priorityLow = 'low';

  static const List<String> priorities = [
    priorityHigh,
    priorityMedium,
    priorityLow,
  ];

  // Connection timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
