import 'package:flutter_test/flutter_test.dart';
import 'package:staff_mate/pages/vitals_page.dart';

void main() {
  test('spoken decimals and digit sequences map to field values', () {
    expect(SmartVoiceParser.extractNumber('98 point 6'), '98.6');
    expect(SmartVoiceParser.extractNumber('ninety eight point six'), '98.6');
    expect(SmartVoiceParser.extractNumber('one two zero'), '120');
    expect(SmartVoiceParser.extractNumber('fluid 250 ml'), '250');
    expect(SmartVoiceParser.extractNumber('SpO2 98'), '98');
    expect(SmartVoiceParser.parseAll('BP 120 over 80'), {
      'systolicBp': '120',
      'diastolicBp': '80',
    });
  });
}
