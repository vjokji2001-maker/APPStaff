// lib/domain/usecases/face_recognition_usecase.dart

abstract class FaceRecognitionUseCase {
  /// Extracts a face embedding from the given [image].
  /// Returns a dynamic representation (e.g., Uint8List) that can be stored.
  Future<dynamic> extractEmbedding(dynamic image);
}
