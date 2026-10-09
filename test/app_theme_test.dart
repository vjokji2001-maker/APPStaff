import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_mate/app/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('buildTheme light mode returns expected defaults', () {
      final theme = AppTheme.buildTheme(false, 16);

      expect(theme.primaryColor, const Color(0xFF1A237E));
      expect(theme.brightness, Brightness.light);
      expect(theme.textTheme.bodyMedium?.fontSize, 16);
    });

    test('buildTheme dark mode returns expected defaults', () {
      final theme = AppTheme.buildTheme(true, 18);

      expect(theme.primaryColor, const Color(0xFF1A237E));
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });
  });
}
