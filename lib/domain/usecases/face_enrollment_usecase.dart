// lib/domain/usecases/face_enrollment_usecase.dart
import 'package:staff_mate/domain/entities/attendance.dart';

abstract class FaceEnrollmentUseCase {
  /// Records attendance using the provided parameters.
  /// Returns an [Attendance] entity representing the recorded punch-in/out.
  Future<Attendance> recordAttendance({
    required String empId,
    required String punchType,
    required String punchDirection,
    required String faceEmbedding,
    required double latitude,
    required double longitude,
  });
}
