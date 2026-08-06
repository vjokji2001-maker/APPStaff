// lib/presentation/face_attendance/widgets/liveness_challenge.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder widget for the liveness challenge.
/// In a real implementation you would integrate a ML model that
/// asks the user to perform actions (blink, turn head) and returns a result.
class LivenessChallenge extends StatelessWidget {
  final void Function(bool passed) onChallengeResult;

  const LivenessChallenge({Key? key, required this.onChallengeResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => onChallengeResult(true),
        child: const Text('Liveness Passed')
            .withGoogleFonts,
      ),
    );
  }
}

extension _GoogleFontExtension on Widget {
  Widget get withGoogleFonts => DefaultTextStyle.merge(
        style: GoogleFonts.poppins(),
        child: this,
      );
}
