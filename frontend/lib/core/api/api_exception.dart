// lib/core/api/api_exception.dart

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(dynamic e) {
    if (e.response != null) {
      final data = e.response?.data;
      final message = data is Map ? (data['message'] ?? 'Something went wrong') : 'Server error';
      return ApiException(message: message, statusCode: e.response?.statusCode);
    }
    return ApiException(message: 'Network error. Please check your connection.');
  }
}
