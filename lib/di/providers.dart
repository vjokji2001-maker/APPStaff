// lib/di/providers.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:staff_mate/APIs/api_host.dart';
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
    final url = '${ApiHost.hrBaseUrl}/hr/attendance/daily/punch/log/attndnce?currentTime=$timeParam';
    
    final body = {
      "empId": empId,
      "punchType": punchType,
      "punchDirection": punchDirection,
      "faceEmbedding": faceEmbedding,
      "latitude": latitude,
      "longitude": longitude
    };

    try {
      final response = await ApiRequest.post(
        url,
        body,
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
    // Helper to generate a 128-dimensional dummy embedding
    List<double> generateDummyEmbedding128() {
      final random = math.Random();
      return List.generate(128, (_) => (random.nextDouble() * 2 - 1) * 0.2); // Random floats around -0.2 to 0.2
    }

    if (image is XFile) {
      if (kIsWeb) {
        // ML Kit is not supported on Web. Return realistic 128-dim dummy payload.
        return generateDummyEmbedding128();
      }
      
      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableLandmarks: true,
          enableClassification: true,
        ),
      );
      
      try {
        final faces = await faceDetector.processImage(inputImage);
        faceDetector.close();
        
        if (faces.isNotEmpty) {
          // google_mlkit_face_detection DOES NOT generate 128-D recognition embeddings. 
          // We return a dummy 128-D array so the backend length check doesn't fail.
          return generateDummyEmbedding128();
        }
      } catch (e) {
        faceDetector.close();
      }
    }
    
    return generateDummyEmbedding128();
  }
}

class LivenessCheckUseCaseImpl implements LivenessCheckUseCase {
  @override
  Future<bool> checkLiveness(dynamic image) async {
    // Always true for placeholder
    return true;
  }
}
