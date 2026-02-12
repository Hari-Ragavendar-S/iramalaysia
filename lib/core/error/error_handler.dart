import 'package:flutter/foundation.dart';
import 'api_exception.dart';
import '../api/api_response.dart';

class ErrorHandler {
  static ApiResponse<T> handleError<T>(dynamic error) {
    if (kDebugMode) {
      print('ErrorHandler: $error');
    }

    if (error is ApiException) {
      return ApiResponse<T>.error(
        error: error.message,
        message: error.error,
        statusCode: error.statusCode,
        metadata: error.details,
      );
    }

    // Handle other types of errors
    String errorMessage;
    if (error is FormatException) {
      errorMessage = 'Invalid data format received from server';
    } else if (error is TypeError) {
      errorMessage = 'Data type mismatch. Please try again.';
    } else {
      errorMessage = error.toString();
    }

    return ApiResponse<T>.error(
      error: errorMessage,
      statusCode: 500,
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }

  static bool shouldRetry(ApiException exception) {
    // Don't retry on client errors (4xx) except 408 (timeout)
    if (exception.isClientError && exception.statusCode != 408) {
      return false;
    }
    
    // Don't retry on authentication errors
    if (exception.isUnauthorized || exception.isForbidden) {
      return false;
    }
    
    // Retry on server errors and network errors
    return exception.isServerError || exception.isNetworkError;
  }

  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      print('Context: $context');
      print('Error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      print('================');
    }
  }
}