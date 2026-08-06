// lib/domain/usecases/face_enrollment_usecase.dart
import 'package:staff_mate/domain/entities/attendance.dart';

abstract class FaceEnrollmentUseCase {
  /// Records attendance using the provided [embedding] generated from a face image.
  /// Returns an [Attendance] entity representing the recorded punch-in/out.
  Future<Attendance> recordAttendance(dynamic embedding);
}
