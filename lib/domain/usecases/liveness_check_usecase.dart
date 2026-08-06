// lib/domain/usecases/liveness_check_usecase.dart

abstract class LivenessCheckUseCase {
  /// Returns true if the provided [image] passes a liveness check.
  /// In a real implementation you would run a ML model; here we stub.
  Future<bool> checkLiveness(dynamic image);
}
