import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final ApiService _apiService = ApiService();

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String userType = 'user',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'user_type': userType,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Save tokens
        await _apiService.setTokens(
          data['access_token'],
          data['refresh_token'],
        );

        return {
          'success': true,
          'message': 'Registration successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save tokens
        await _apiService.setTokens(
          data['access_token'],
          data['refresh_token'],
        );

        return {
          'success': true,
          'message': 'Login successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get profile',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post(ApiConfig.refresh);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save new tokens
        await _apiService.setTokens(
          data['access_token'],
          data['refresh_token'],
        );

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to refresh token',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    await _apiService.clearTokens();
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _apiService.isAuthenticated;
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send reset email',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Verify OTP (Skip OTP - Always return success)
  static Future<Map<String, dynamic>> verifyOTP({
    String? email,
    String? phone,
    required String otpCode,
    required String otpType,
  }) async {
    // Skip actual OTP verification - always return success
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    return {
      'success': true,
      'message': 'OTP verified successfully',
    };
  }

  // Resend OTP (Skip OTP - Always return success)
  static Future<Map<String, dynamic>> resendOTP({
    String? email,
    String? phone,
    required String otpType,
  }) async {
    // Skip actual OTP sending - always return success
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    return {
      'success': true,
      'message': 'OTP sent successfully',
    };
  }

  // Helper method to extract error messages
  static String _getErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}