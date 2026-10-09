class ApiFailure implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const ApiFailure({required this.message, this.statusCode, this.cause});

  @override
  String toString() => message;
}

class ApiResult<T> {
  final T? data;
  final ApiFailure? failure;

  const ApiResult._({this.data, this.failure});

  factory ApiResult.success(T data) => ApiResult._(data: data);

  factory ApiResult.failure(ApiFailure failure) =>
      ApiResult._(failure: failure);

  bool get isSuccess => failure == null;

  T get value => data as T;
}
