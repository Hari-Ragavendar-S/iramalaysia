import 'dart:io';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../models/auth/auth_models.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  // Register User
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    final response = await _apiClient.post<AuthResponse>(
      ApiEndpoints.authRegister,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
    }

    return response;
  }

  // Login User
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    final response = await _apiClient.post<AuthResponse>(
      ApiEndpoints.authLogin,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
    }

    return response;
  }

  // Admin Login
  Future<ApiResponse<AuthResponse>> adminLogin(LoginRequest request) async {
    final response = await _apiClient.post<AuthResponse>(
      ApiEndpoints.authAdminLogin,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
    }

    return response;
  }

  // Get User Profile
  Future<ApiResponse<UserProfile>> getProfile() async {
    return await _apiClient.get<UserProfile>(
      ApiEndpoints.authProfile,
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  // Get Admin Profile
  Future<ApiResponse<UserProfile>> getAdminProfile() async {
    return await _apiClient.get<UserProfile>(
      ApiEndpoints.authAdminProfile,
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  // Refresh Token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse.error(error: 'No refresh token available');
    }

    final response = await _apiClient.post<AuthResponse>(
      ApiEndpoints.authRefresh,
      data: {'refresh_token': refreshToken},
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
    }

    return response;
  }

  // Forgot Password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authForgotPassword,
      data: request.toJson(),
    );
  }

  // Reset Password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authResetPassword,
      data: request.toJson(),
    );
  }

  // Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
    OtpRequest request,
  ) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authVerifyOtp,
      data: request.toJson(),
    );
  }

  // Resend OTP
  Future<ApiResponse<Map<String, dynamic>>> resendOtp(
    ResendOtpRequest request,
  ) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authResendOtp,
      data: request.toJson(),
    );
  }

  // Logout
  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await SecureStorage.isLoggedIn();
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    return await SecureStorage.getAccessToken();
  }

  // Check if token is valid (basic check)
  Future<bool> isTokenValid() async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) return false;

    try {
      // Try to get profile to validate token
      final response = await getProfile();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Auto login check
  Future<bool> autoLogin() async {
    if (!await isLoggedIn()) return false;

    // Try to refresh token if needed
    try {
      final response = await refreshToken();
      return response.success;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Private helper methods
  Future<void> _saveTokens(AuthResponse authResponse) async {
    await SecureStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
  }

  // Health check
  Future<bool> healthCheck() async {
    return await _apiClient.healthCheck();
  }
}