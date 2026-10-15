import 'package:flutter_test/flutter_test.dart';
import 'package:staff_mate/my_hr/utils/leave_form_rules.dart';

void main() {
  test('inclusive day count ignores time of day', () {
    expect(
      LeaveFormRules.totalDays(
        DateTime(2026, 10, 13, 18),
        DateTime(2026, 10, 24),
        'FULL_DAY',
        'FULL_DAY',
      ),
      12,
    );
    expect(
      LeaveFormRules.totalDays(
        DateTime(2026, 10, 13, 18),
        DateTime(2026, 10, 13),
        'FULL_DAY',
        'FULL_DAY',
      ),
      1,
    );
  });
  test('half-day endpoints and same-day duration validation', () {
    final day = DateTime(2026, 10, 13);
    expect(LeaveFormRules.totalDays(day, day, 'FIRST_HALF', 'FIRST_HALF'), .5);
    expect(
      LeaveFormRules.totalDays(day, day, 'SECOND_HALF', 'SECOND_HALF'),
      .5,
    );
    expect(LeaveFormRules.totalDays(day, day, 'SECOND_HALF', 'FIRST_HALF'), 0);
    expect(LeaveFormRules.totalDays(day, day, 'FULL_DAY', 'FIRST_HALF'), 0);
    expect(
      LeaveFormRules.totalDays(
        day,
        DateTime(2026, 10, 14),
        'SECOND_HALF',
        'FIRST_HALF',
      ),
      1,
    );
    expect(
      LeaveFormRules.totalDays(
        day,
        DateTime(2026, 10, 12),
        'FULL_DAY',
        'FULL_DAY',
      ),
      0,
    );
  });
  test('current year is selected by dates rather than first ACTIVE cycle', () {
    final cycles = [
      {'id': 1, 'name': 'FY 2024-25', 'status': 'ACTIVE'},
      {'yearId': '2', 'name': 'FY 2026-27', 'status': 'ACTIVE'},
    ];
    expect(LeaveFormRules.currentCycleId(cycles, DateTime(2026, 10, 13)), 2);
    expect(
      LeaveFormRules.currentCycleId([cycles.first], DateTime(2026, 10, 13)),
      isNull,
    );
    expect(
      LeaveFormRules.covers(
        cycles.first,
        DateTime(2026, 10, 13),
        DateTime(2026, 10, 24),
      ),
      isFalse,
    );
  });
  test('server cycle bounds override FY label and include boundary days', () {
    final cycle = {
      'name': 'FY 2024-25',
      'startDate': '2026-01-01',
      'endDate': '2026-12-31',
    };
    expect(
      LeaveFormRules.covers(
        cycle,
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      ),
      isTrue,
    );
    expect(
      LeaveFormRules.covers(
        cycle,
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
      ),
      isFalse,
    );
  });
}
