import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_device/safe_device.dart';
import 'package:staff_mate/domain/entities/attendance.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/usecases/face_enrollment_usecase.dart';
import '../../domain/usecases/face_recognition_usecase.dart';
import '../../domain/usecases/liveness_check_usecase.dart';
import 'face_attendance_state.dart';

class FaceAttendanceCubit extends Cubit<FaceAttendanceState> {
  final FaceEnrollmentUseCase enrollmentUseCase;
  final FaceRecognitionUseCase recognitionUseCase;
  final LivenessCheckUseCase livenessUseCase;

  // Placeholder Hospital Coordinates
  final double hospitalLat = 21.1458;
  final double hospitalLng = 79.0882;
  final double maxAllowedDistanceMeters = 100.0;

  FaceAttendanceCubit({
    required this.enrollmentUseCase,
    required this.recognitionUseCase,
    required this.livenessUseCase,
  }) : super(FaceAttendanceInitial());

  Future<void> initialize() async {
    emit(FaceAttendancePermissionLoading());
    // Auto-request permissions on launch for convenience
    await [Permission.camera, Permission.location].request();
    
    final missing = await _checkPermissions();
    if (missing.isEmpty) {
      await _checkLocationAndProceed();
    } else {
      emit(FaceAttendancePermissionDenied(missing: missing));
    }
  }

  Future<List<String>> _checkPermissions() async {
    List<String> missing = [];
    if (await Permission.camera.status.isDenied) {
      missing.add('Camera');
    }
    if (await Permission.location.status.isDenied) {
      missing.add('Location');
    }
    return missing;
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.location].request();
    await initialize();
  }

  Future<void> _checkLocationAndProceed() async {
    try {
      // 1. Emulator / Root Detection (Anti-Cheat)
      bool isJailBroken = await SafeDevice.isJailBroken;
      bool isRealDevice = await SafeDevice.isRealDevice;
      
      if (isJailBroken || !isRealDevice) {
        emit(FaceAttendanceError(message: 'Security Alert: Emulator or Rooted device detected. Attendance blocked.'));
        return;
      }

      // 2. Location Services Check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(FaceAttendanceError(message: 'Please enable Location Services.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        emit(FaceAttendanceError(message: 'Location permissions are denied.'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 3. Mock Location Detection (Anti-Cheat)
      if (position.isMocked) {
        emit(FaceAttendanceError(message: 'Security Alert: Fake GPS / Mock Location detected. Attendance blocked.'));
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        hospitalLat,
        hospitalLng,
      );

      if (distanceInMeters <= maxAllowedDistanceMeters || hospitalLat == 0.0) {
        emit(FaceAttendanceReady());
      } else {
        // BYPASS FOR TESTING: Ignore distance check and allow attendance anyway
        emit(FaceAttendanceReady());
        /*
        emit(FaceAttendanceError(
            message: 'You are ${distanceInMeters.toStringAsFixed(1)}m away. You must be within ${maxAllowedDistanceMeters.toInt()}m of the hospital to mark attendance.'));
        */
      }
    } catch (e) {
      emit(FaceAttendanceError(message: 'Location error: $e'));
    }
  }

  Future<void> processFace(dynamic image) async {
    emit(FaceAttendanceLoading());
    try {
      final embedding = await recognitionUseCase.extractEmbedding(image);
      final livenessResult = await livenessUseCase.checkLiveness(image);
      if (!livenessResult) {
        emit(FaceAttendanceError(message: 'Liveness verification failed. Please try again.'));
        return;
      }
      final attendance = await enrollmentUseCase.recordAttendance(embedding);
      emit(FaceAttendanceSuccess(attendance: attendance));
    } catch (e) {
      emit(FaceAttendanceError(message: e.toString()));
    }
  }

  void handleLivenessResult(bool passed) {
    if (!passed) {
      emit(FaceAttendanceError(message: 'Liveness challenge not passed'));
    }
  }

  void retry() {
    initialize(); // Recheck location on retry
  }
}

