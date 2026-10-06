import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaceAttendanceErrorDialog extends StatelessWidget {
  final String rawError;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const FaceAttendanceErrorDialog({
    super.key,
    required this.rawError,
    required this.onCancel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = rawError.trim();

    return AlertDialog(
      backgroundColor: const Color(0xFF0E1720),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Attendance issue',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          message.isNotEmpty
              ? message
              : 'Something went wrong while checking attendance.',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('Retry', style: GoogleFonts.poppins()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C897),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
