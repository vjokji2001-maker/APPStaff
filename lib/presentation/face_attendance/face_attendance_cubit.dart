import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_device/safe_device.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String? _empId;
  String? _punchDirection;
  double? _currentLat;
  double? _currentLng;

  FaceAttendanceCubit({
    required this.enrollmentUseCase,
    required this.recognitionUseCase,
    required this.livenessUseCase,
  }) : super(FaceAttendanceInitial());

  Future<void> initialize(String punchDirection) async {
    _punchDirection = punchDirection;
    emit(FaceAttendancePermissionLoading());

    final prefs = await SharedPreferences.getInstance();
    _empId = prefs.getString('empId');
    if (_empId == null || _empId!.isEmpty) {
      // Fallback to userId if empId is not found (some APIs use userId)
      _empId = prefs.getString('userId');
    }
    
    if (_empId == null || _empId!.isEmpty) {
      emit(FaceAttendanceError(message: 'Employee ID not found. Please login again.'));
      return;
    }

    List<String> missing = await _checkPermissions();
    if (missing.isNotEmpty) {
      // Only request the specific permissions that are missing
      List<Permission> toRequest = [];
      if (missing.contains('Camera')) toRequest.add(Permission.camera);
      if (missing.contains('Location')) toRequest.add(Permission.location);
      
      await toRequest.request();
      missing = await _checkPermissions();
    }
    
    if (missing.isEmpty) {
      await _checkLocationAndProceed();
    } else {
      emit(FaceAttendancePermissionDenied(missing: missing));
    }
  }

  Future<List<String>> _checkPermissions() async {
    List<String> missing = [];
    if (!(await Permission.camera.status.isGranted)) {
      missing.add('Camera');
    }
    if (!(await Permission.location.status.isGranted)) {
      missing.add('Location');
    }
    return missing;
  }

  Future<void> requestPermissions() async {
    List<String> missing = await _checkPermissions();
    List<Permission> toRequest = [];
    if (missing.contains('Camera')) toRequest.add(Permission.camera);
    if (missing.contains('Location')) toRequest.add(Permission.location);
    
    if (toRequest.isNotEmpty) {
      await toRequest.request();
    }
    
    if (_punchDirection != null) {
      await initialize(_punchDirection!);
    }
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

      _currentLat = position.latitude;
      _currentLng = position.longitude;

      // 3. Mock Location Detection (Anti-Cheat)
      if (position.isMocked) {
        emit(FaceAttendanceError(message: 'Security Alert: Fake GPS / Mock Location detected. Attendance blocked.'));
        return;
      }

      // Backend handles distance validation, so we just capture location and proceed.
      emit(FaceAttendanceReady());
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
      final attendance = await enrollmentUseCase.recordAttendance(
        empId: _empId!,
        punchType: 'MANUAL', // or 'FACE' if biometric
        punchDirection: _punchDirection ?? 'IN',
        faceEmbedding: embedding.toString(),
        latitude: _currentLat ?? 0.0,
        longitude: _currentLng ?? 0.0,
      );
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
    if (_punchDirection != null) {
      initialize(_punchDirection!);
    }
  }
}

