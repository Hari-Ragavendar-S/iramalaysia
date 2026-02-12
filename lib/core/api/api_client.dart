import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../error/api_exception.dart';
import '../error/error_handler.dart';
import 'api_interceptor.dart';
import 'api_response.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio();
    _setupDio();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupDio() {
    // API Client connected to backend
    _dio.options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor(_dio));
    _dio.interceptors.add(RetryInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  // GET Request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PATCH Request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // File Upload
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Download File
  Future<ApiResponse<String>> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<String>.success(
        data: savePath,
        message: 'File downloaded successfully',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  // Handle Response
  ApiResponse<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    try {
      final data = response.data;
      
      // If response is already in ApiResponse format
      if (data is Map<String, dynamic> && data.containsKey('success')) {
        return ApiResponse<T>.fromJson(data, fromJson);
      }
      
      // Handle direct data response
      T? parsedData;
      if (data != null && fromJson != null) {
        parsedData = fromJson(data);
      } else {
        parsedData = data;
      }
      
      return ApiResponse<T>.success(
        data: parsedData,
        statusCode: response.statusCode,
        message: 'Request successful',
      );
    } catch (e) {
      return ApiResponse<T>.error(
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle Error
  ApiResponse<T> _handleError<T>(dynamic error) {
    ApiException apiException;
    
    if (error is DioException) {
      apiException = ApiException.fromDioException(error);
    } else {
      apiException = ApiException(
        message: error.toString(),
        statusCode: 500,
      );
    }
    
    ErrorHandler.logError('ApiClient', apiException);
    
    return ApiResponse<T>.error(
      error: apiException.message,
      statusCode: apiException.statusCode,
      metadata: apiException.details,
    );
  }

  // Health Check - OFFLINE MODE
  Future<bool> healthCheck() async {
    // Always return false - no backend connection
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
  }

  // Clear instance (for testing or logout)
  static void clearInstance() {
    _instance = null;
  }
}