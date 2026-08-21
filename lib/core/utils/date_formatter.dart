import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String shortDate(DateTime date) => DateFormat.yMMMd().format(date.toLocal());

  static String time(DateTime date) => DateFormat.jm().format(date.toLocal());

  static String dateTime(DateTime date) => '${shortDate(date)} · ${time(date)}';

  static String relative(DateTime date) {
    final now = DateTime.now();
    final target = date.toLocal();
    final difference = now.difference(target);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return shortDate(target);
  }

  static bool isOverdue(DateTime dueDate) {
    return dueDate.toLocal().isBefore(DateTime.now());
  }
}
