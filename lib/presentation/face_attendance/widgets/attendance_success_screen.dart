// lib/presentation/face_attendance/widgets/attendance_success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/domain/entities/attendance.dart';

/// Simple UI displayed after a successful attendance record.
class AttendanceSuccessScreen extends StatelessWidget {
  final Attendance attendance;

  const AttendanceSuccessScreen({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Recorded').withGoogleFonts,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text('ID: ${attendance.id}', style: GoogleFonts.poppins()),
            Text('Time: ${attendance.timestamp}', style: GoogleFonts.poppins()),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Dashboard'),
            )
          ],
        ),
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
