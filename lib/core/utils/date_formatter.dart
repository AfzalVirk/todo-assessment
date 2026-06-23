import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _fullFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  static String toDisplay(DateTime date) => _displayFormat.format(date);

  static String toApi(DateTime date) => _apiFormat.format(date);

  static String toFull(DateTime date) => _fullFormat.format(date);

  static String toTime(DateTime date) => _timeFormat.format(date);

  static DateTime? parseApi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) return toDisplay(date);
    if (difference.inDays >= 1) return '${difference.inDays}d ago';
    if (difference.inHours >= 1) return '${difference.inHours}h ago';
    if (difference.inMinutes >= 1) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }
}
