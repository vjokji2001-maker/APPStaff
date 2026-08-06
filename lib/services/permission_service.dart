import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission handling service.
class PermissionService {
  /// Request a single permission with optional rationale.
  Future<bool> requestPermission(
    Permission permission, {
    String? rationale,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    // Show rationale if provided.
    if (rationale != null && rationale.isNotEmpty) {
      debugPrint('Permission rationale: $rationale');
    }

    final result = await permission.request();

    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      debugPrint(
        '${permission.toString()} permanently denied. Opening app settings.',
      );
      await openAppSettings();
    }

    return false;
  }

  /// Location Permission
  Future<bool> requestLocation({String? rationale}) async {
    return requestPermission(
      Permission.locationWhenInUse,
      rationale: rationale,
    );
  }

  /// Camera Permission
  Future<bool> requestCamera({String? rationale}) async {
    return requestPermission(
      Permission.camera,
      rationale: rationale,
    );
  }

  /// Microphone Permission
  Future<bool> requestMicrophone({String? rationale}) async {
    return requestPermission(
      Permission.microphone,
      rationale: rationale,
    );
  }

  /// Storage Permission (Android < 13)
  Future<bool> requestStorage({String? rationale}) async {
    return requestPermission(
      Permission.storage,
      rationale: rationale,
    );
  }

  /// Photos Permission (Android 13+ / iOS)
  Future<bool> requestPhotos({String? rationale}) async {
    return requestPermission(
      Permission.photos,
      rationale: rationale,
    );
  }

  /// Notification Permission
  Future<bool> requestNotification({String? rationale}) async {
    return requestPermission(
      Permission.notification,
      rationale: rationale,
    );
  }

  /// Check if permission already granted
  Future<bool> isGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Open app settings manually
  Future<void> openSettings() async {
    await openAppSettings();
  }
}

/// Riverpod Provider
final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);