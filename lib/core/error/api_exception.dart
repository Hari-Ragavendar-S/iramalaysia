import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;
  final Map<String, dynamic>? details;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.details,
  });

  factory ApiException.fromDioException(DioException dioException) {
    String message;
    int? statusCode;
    String? error;
    Map<String, dynamic>? details;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;
        
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 
                   responseData['detail'] ?? 
                   responseData['error'] ?? 
                   'Server error occurred';
          error = responseData['error']?.toString();
          details = responseData;
        } else {
          message = 'Server error occurred';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error. Please try again.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'An unexpected error occurred. Please try again.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      error: error,
      details: details,
    );
  }

  factory ApiException.unauthorized([String? message]) {
    return ApiException(
      message: message ?? 'Unauthorized access. Please login again.',
      statusCode: 401,
      error: 'unauthorized',
    );
  }

  factory ApiException.forbidden([String? message]) {
    return ApiException(
      message: message ?? 'Access forbidden. You don\'t have permission.',
      statusCode: 403,
      error: 'forbidden',
    );
  }

  factory ApiException.notFound([String? message]) {
    return ApiException(
      message: message ?? 'Resource not found.',
      statusCode: 404,
      error: 'not_found',
    );
  }

  factory ApiException.serverError([String? message]) {
    return ApiException(
      message: message ?? 'Internal server error. Please try again later.',
      statusCode: 500,
      error: 'server_error',
    );
  }

  factory ApiException.networkError([String? message]) {
    return ApiException(
      message: message ?? 'Network error. Please check your connection.',
      statusCode: null,
      error: 'network_error',
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, error: $error)';
  }
}