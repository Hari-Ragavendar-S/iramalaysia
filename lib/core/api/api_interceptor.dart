import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../constants/app_constants.dart';
import '../error/api_exception.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  final Dio _dio;
  
  ApiInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add base URL if not already present
    if (!options.path.startsWith('http')) {
      options.baseUrl = AppConstants.apiBaseUrl;
    }

    // Add access token to headers
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    if (kDebugMode) {
      print('🚀 REQUEST: ${options.method} ${options.uri}');
      print('📤 Headers: ${options.headers}');
      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      print('📥 Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('💥 Message: ${err.message}');
      print('📥 Response: ${err.response?.data}');
    }

    // Handle 401 Unauthorized - Try to refresh token
    if (err.response?.statusCode == 401) {
      final refreshed = await _handleTokenRefresh(err.requestOptions);
      if (refreshed) {
        // Retry the original request
        try {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, continue with original error
        }
      } else {
        // Refresh failed, clear tokens and redirect to login
        await SecureStorage.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _handleTokenRefresh(RequestOptions originalRequest) async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio();
      refreshDio.options.baseUrl = AppConstants.apiBaseUrl;
      refreshDio.options.connectTimeout = AppConstants.connectTimeout;
      refreshDio.options.receiveTimeout = AppConstants.receiveTimeout;
      refreshDio.options.sendTimeout = AppConstants.sendTimeout;

      final response = await refreshDio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null && newRefreshToken != null) {
          await SecureStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Update the original request with new token
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔄 Token refresh failed: $e');
      }
    }

    return false;
  }
}

class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final apiException = ApiException.fromDioException(err);
    
    // Check if we should retry
    if (_shouldRetry(apiException, err.requestOptions)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < AppConstants.maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Wait before retrying
        await Future.delayed(AppConstants.retryDelay);
        
        try {
          final dio = Dio();
          dio.options.baseUrl = err.requestOptions.baseUrl;
          dio.options.headers = err.requestOptions.headers;
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue with original error if retry fails
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(ApiException exception, RequestOptions options) {
    // Don't retry POST requests with data (to avoid duplicate submissions)
    if (options.method.toUpperCase() == 'POST' && options.data != null) {
      return false;
    }
    
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
}