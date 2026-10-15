import 'package:intl/intl.dart';

/// Formats API ISO dates and the legacy `15 Aug 2026` display format.
class HolidayDateLabel {
  final String day;
  final String month;

  const HolidayDateLabel(this.day, this.month);

  factory HolidayDateLabel.fromDate(String value) {
    final input = value.trim();
    DateTime? date;
    // Preserve the date supplied by the API without timezone conversion.
    final isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}(?:$|[T ])').firstMatch(input);
    if (isoDate != null) {
      try {
        date = DateFormat(
          'yyyy-MM-dd',
          'en_US',
        ).parseStrict(input.substring(0, 10));
      } on FormatException {
        // Invalid API dates use the placeholder below.
      }
    } else {
      final normalized = input.replaceAll(RegExp(r'\s+'), ' ');
      for (final pattern in ['d MMM yyyy', 'd MMMM yyyy']) {
        try {
          date = DateFormat(pattern, 'en_US').parseStrict(normalized);
          break;
        } on FormatException {
          continue;
        }
      }
    }
    if (date == null) return const HolidayDateLabel('--', '');
    return HolidayDateLabel(
      DateFormat('dd', 'en_US').format(date),
      DateFormat('MMM', 'en_US').format(date),
    );
  }
}
