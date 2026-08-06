// lib/domain/entities/attendance.dart
import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final DateTime timestamp;
  // Add more fields as needed, e.g., employeeId, status, etc.
  const Attendance({required this.id, required this.timestamp});

  @override
  List<Object?> get props => [id, timestamp];
}
