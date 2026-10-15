import 'package:flutter_test/flutter_test.dart';
import 'package:staff_mate/my_hr/utils/holiday_date_label.dart';

void main() {
  test('formats ISO and legacy holiday dates without shifting the day', () {
    for (final input in [
      '2026-08-15',
      '2026-08-15T00:00:00Z',
      '2026-08-15T23:00:00-05:00',
      '15 Aug 2026',
      ' 15   August 2026 ',
    ]) {
      final label = HolidayDateLabel.fromDate(input);
      expect(label.day, '15', reason: input);
      expect(label.month, 'Aug', reason: input);
    }
  });

  test('missing and malformed holiday dates use a safe placeholder', () {
    for (final input in ['', ' ', '15', 'invalid', '2026-02-30', '15 A 2026']) {
      final label = HolidayDateLabel.fromDate(input);
      expect(label.day, '--', reason: input);
      expect(label.month, '', reason: input);
    }
  });
}
