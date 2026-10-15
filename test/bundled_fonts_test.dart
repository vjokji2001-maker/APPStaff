import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'all app font families and weights load from assets without networking',
    () async {
      final previous = GoogleFonts.config.allowRuntimeFetching;
      GoogleFonts.config.allowRuntimeFetching = false;
      addTearDown(() => GoogleFonts.config.allowRuntimeFetching = previous);
      final styles = <TextStyle>[];
      for (final family in ['Poppins', 'Inter', 'Nunito', 'Roboto Mono']) {
        for (final weight in FontWeight.values) {
          for (final style in FontStyle.values) {
            styles.add(
              GoogleFonts.getFont(family, fontWeight: weight, fontStyle: style),
            );
          }
        }
      }
      await GoogleFonts.pendingFonts(styles);
    },
  );
}
