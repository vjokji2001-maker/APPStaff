// lib/di/providers.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:staff_mate/APIs/api_host.dart';
import 'package:staff_mate/APIs/api_headers.dart';
import 'package:staff_mate/APIs/api_request.dart';
import 'package:staff_mate/domain/entities/attendance.dart';
import 'package:get_it/get_it.dart';
import 'package:staff_mate/presentation/face_attendance/face_attendance_cubit.dart';
import 'package:staff_mate/domain/usecases/face_enrollment_usecase.dart';
import 'package:staff_mate/domain/usecases/face_recognition_usecase.dart';
import 'package:staff_mate/domain/usecases/liveness_check_usecase.dart';

final GetIt getIt = GetIt.instance;

void setupProviders() {
  // Register use cases (you may replace with real implementations later)
  getIt.registerLazySingleton<FaceEnrollmentUseCase>(
    () => FaceEnrollmentUseCaseImpl(),
  );
  getIt.registerLazySingleton<FaceRecognitionUseCase>(
    () => FaceRecognitionUseCaseImpl(),
  );
  getIt.registerLazySingleton<LivenessCheckUseCase>(
    () => LivenessCheckUseCaseImpl(),
  );

  // Register FaceAttendanceCubit
  getIt.registerFactory<FaceAttendanceCubit>(
    () => FaceAttendanceCubit(
      enrollmentUseCase: getIt<FaceEnrollmentUseCase>(),
      recognitionUseCase: getIt<FaceRecognitionUseCase>(),
      livenessUseCase: getIt<LivenessCheckUseCase>(),
    ),
  );
}

// Stub implementations – replace with real logic later
class FaceEnrollmentUseCaseImpl implements FaceEnrollmentUseCase {
  @override
  Future<Attendance> recordAttendance({
    required String empId,
    required String punchType,
    required String punchDirection,
    required String faceEmbedding,
    required double latitude,
    required double longitude,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final timeParam = Uri.encodeComponent(nowIso);
    final url =
        '${ApiHost.hrBaseUrl}/hr/attendance/daily/punch/log/attndnce?currentTime=$timeParam';

    final body = {
      "empId": empId,
      "punchType": punchType,
      "punchDirection": punchDirection,
      "faceEmbedding": faceEmbedding,
      "latitude": latitude,
      "longitude": longitude,
    };

    try {
      final response = await ApiRequest.post(
        url,
        body,
        headers: await ApiHeaders.getHeaders(isHrRequest: true),
      );

      // ApiRequest.post handles parsing and throws on error based on status code
      return Attendance(id: empId, timestamp: DateTime.now());
    } catch (e) {
      throw Exception('Error calling attendance API: $e');
    }
  }
}

class FaceRecognitionUseCaseImpl implements FaceRecognitionUseCase {
  @override
  Future<dynamic> extractEmbedding(dynamic image) async {
    if (image is! XFile) {
      throw StateError('Invalid camera image for face recognition.');
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Face recognition is not available on web because no recognition model is configured.',
      );
    }

    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
      ),
    );

    try {
      final faces = await faceDetector.processImage(
        InputImage.fromFilePath(image.path),
      );
      if (faces.isEmpty) {
        throw StateError('No face was detected. Please try again.');
      }
    } finally {
      await faceDetector.close();
    }

    throw UnsupportedError(
      'Face detection succeeded, but face matching is not configured. '
      'A trained recognition model and matching enrollment data are required.',
    );
  }
}

class LivenessCheckUseCaseImpl implements LivenessCheckUseCase {
  @override
  Future<bool> checkLiveness(dynamic image) async {
    // Always true for placeholder
    return true;
  }
}
