// lib/di/providers.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:staff_mate/APIs/api_host.dart';
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
    final url = Uri.parse('${ApiHost.hrBaseUrl}/hr/attendance/daily/punch/log/attndnce?currentTime=$timeParam');
    
    final body = {
      "empId": empId,
      "punchType": punchType,
      "punchDirection": punchDirection,
      "faceEmbedding": faceEmbedding,
      "latitude": latitude,
      "longitude": longitude
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Attendance(id: empId, timestamp: DateTime.now());
      } else {
        throw Exception('Failed to record attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calling attendance API: $e');
    }
  }
}

class FaceRecognitionUseCaseImpl implements FaceRecognitionUseCase {
  @override
  Future<dynamic> extractEmbedding(dynamic image) async {
    if (image is XFile) {
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
          final face = faces.first;
          final box = face.boundingBox;
          
          // Generate a dynamic "pseudo-embedding" array based on actual detected face features.
          // This replaces the hardcoded string with dynamic data.
          final embeddingList = [
            box.left / 1000.0,
            box.top / 1000.0,
            box.width / 1000.0,
            box.height / 1000.0,
            (face.smilingProbability ?? 0.5),
            (face.leftEyeOpenProbability ?? 0.5),
            (face.rightEyeOpenProbability ?? 0.5),
          ];
          
          return embeddingList.toString();
        }
      } catch (e) {
        faceDetector.close();
        // Fallback below if error
      }
    }
    
    // Fallback if no face detected or image is invalid format
    return "[0.0, 0.0, 0.0, 0.0, 0.0]";
  }
}

class LivenessCheckUseCaseImpl implements LivenessCheckUseCase {
  @override
  Future<bool> checkLiveness(dynamic image) async {
    // Always true for placeholder
    return true;
  }
}
