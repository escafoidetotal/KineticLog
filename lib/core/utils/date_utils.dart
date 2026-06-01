import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('EEE, d MMM', 'es_ES');
  static final DateFormat _displayLongFormat = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _backupFormat = DateFormat('yyyyMMdd_HHmmss');

  static String toKey(DateTime date) => _dateFormat.format(date);

  static String toDisplay(DateTime date) => _displayFormat.format(date);

  static String toDisplayLong(DateTime date) => _displayLongFormat.format(date);

  static String toTime(DateTime date) => _timeFormat.format(date);

  static String toBackupName(DateTime date) => _backupFormat.format(date);

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
