// lib/di/providers.dart
import 'package:staff_mate/domain/entities/attendance.dart';
import 'package:get_it/get_it.dart';
import 'package:staff_mate/presentation/face_attendance/face_attendance_cubit.dart';
import 'package:staff_mate/domain/usecases/face_enrollment_usecase.dart';
import 'package:staff_mate/domain/usecases/face_recognition_usecase.dart';
import 'package:staff_mate/domain/usecases/liveness_check_usecase.dart';

final GetIt getIt = GetIt.instance;

void setupProviders() {
  // Register use cases (you may replace with real implementations later)
  getIt.registerLazySingleton<FaceEnrollmentUseCase>(() => FaceEnrollmentUseCaseImpl());
  getIt.registerLazySingleton<FaceRecognitionUseCase>(() => FaceRecognitionUseCaseImpl());
  getIt.registerLazySingleton<LivenessCheckUseCase>(() => LivenessCheckUseCaseImpl());

  // Register FaceAttendanceCubit
  getIt.registerFactory<FaceAttendanceCubit>(() => FaceAttendanceCubit(
        enrollmentUseCase: getIt<FaceEnrollmentUseCase>(),
        recognitionUseCase: getIt<FaceRecognitionUseCase>(),
        livenessUseCase: getIt<LivenessCheckUseCase>(),
      ));
}

// Stub implementations – replace with real logic later
class FaceEnrollmentUseCaseImpl implements FaceEnrollmentUseCase {
  @override
  Future<Attendance> recordAttendance(dynamic embedding) async {
    // Dummy attendance record
    return Attendance(id: 'dummy', timestamp: DateTime.now());
  }
}

class FaceRecognitionUseCaseImpl implements FaceRecognitionUseCase {
  @override
  Future<dynamic> extractEmbedding(dynamic image) async {
    // Return dummy embedding
    return image;
  }
}

class LivenessCheckUseCaseImpl implements LivenessCheckUseCase {
  @override
  Future<bool> checkLiveness(dynamic image) async {
    // Always true for placeholder
    return true;
  }
}
