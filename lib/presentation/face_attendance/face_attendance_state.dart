// lib/presentation/face_attendance/face_attendance_state.dart
import 'package:staff_mate/domain/entities/attendance.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class FaceAttendanceState {}

class FaceAttendanceInitial extends FaceAttendanceState {}

class FaceAttendancePermissionLoading extends FaceAttendanceState {}

class FaceAttendancePermissionDenied extends FaceAttendanceState {
  final List<String> missing;
  FaceAttendancePermissionDenied({required this.missing});
}

class FaceAttendanceReady extends FaceAttendanceState {}

class FaceAttendanceLoading extends FaceAttendanceState {}

class FaceAttendanceLiveness extends FaceAttendanceState {}

class FaceAttendanceSuccess extends FaceAttendanceState {
  final Attendance attendance;
  FaceAttendanceSuccess({required this.attendance});
}

class FaceAttendanceError extends FaceAttendanceState {
  final String message;
  FaceAttendanceError({required this.message});
}
