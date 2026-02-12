import '../services/auth_service.dart';
import '../models/auth/auth_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  // Authentication Methods
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String userType = 'user',
  }) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      userType: userType,
    );
    
    final response = await _authService.register(request);
    
    // Save user data if successful
    if (response.success && response.data != null) {
      final profileResponse = await _authService.getProfile();
      if (profileResponse.success && profileResponse.data != null) {
        await SecureStorage.saveUserData(profileResponse.data!.toJson());
      }
    }
    
    return response;
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _authService.login(request);
    
    // Save user data if successful
    if (response.success && response.data != null) {
      final profileResponse = await _authService.getProfile();
      if (profileResponse.success && profileResponse.data != null) {
        await SecureStorage.saveUserData(profileResponse.data!.toJson());
      }
    }
    
    return response;
  }

  Future<ApiResponse<AuthResponse>> adminLogin({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _authService.adminLogin(request);
    
    // Save admin data if successful
    if (response.success && response.data != null) {
      final profileResponse = await _authService.getAdminProfile();
      if (profileResponse.success && profileResponse.data != null) {
        await SecureStorage.saveUserData(profileResponse.data!.toJson());
      }
    }
    
    return response;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // Profile Methods
  Future<ApiResponse<UserProfile>> getProfile() async {
    final response = await _authService.getProfile();
    
    // Update stored user data if successful
    if (response.success && response.data != null) {
      await SecureStorage.saveUserData(response.data!.toJson());
    }
    
    return response;
  }

  Future<ApiResponse<UserProfile>> getAdminProfile() async {
    final response = await _authService.getAdminProfile();
    
    // Update stored user data if successful
    if (response.success && response.data != null) {
      await SecureStorage.saveUserData(response.data!.toJson());
    }
    
    return response;
  }

  // Token Management
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    return await _authService.refreshToken();
  }

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  Future<String?> getAccessToken() async {
    return await _authService.getAccessToken();
  }

  Future<bool> isTokenValid() async {
    return await _authService.isTokenValid();
  }

  Future<bool> autoLogin() async {
    return await _authService.autoLogin();
  }

  // Password Management
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    final request = ForgotPasswordRequest(email: email);
    return await _authService.forgotPassword(request);
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final request = ResetPasswordRequest(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
    );
    return await _authService.resetPassword(request);
  }

  // OTP Management
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    String? email,
    String? phone,
    required String otpCode,
    required String otpType,
  }) async {
    final request = OtpRequest(
      email: email,
      phone: phone,
      otpCode: otpCode,
      otpType: otpType,
    );
    return await _authService.verifyOtp(request);
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOtp({
    String? email,
    String? phone,
    required String otpType,
  }) async {
    final request = ResendOtpRequest(
      email: email,
      phone: phone,
      otpType: otpType,
    );
    return await _authService.resendOtp(request);
  }

  // Cached User Data
  Future<UserProfile?> getCachedUserProfile() async {
    final userData = await SecureStorage.getUserData();
    if (userData != null) {
      try {
        return UserProfile.fromJson(userData);
      } catch (e) {
        // If cached data is corrupted, clear it
        await SecureStorage.delete('user_data');
        return null;
      }
    }
    return null;
  }

  Future<void> clearCachedUserData() async {
    await SecureStorage.delete('user_data');
  }

  // Health Check
  Future<bool> healthCheck() async {
    return await _authService.healthCheck();
  }

  // User Type Helpers
  Future<bool> isUserBusker() async {
    final profile = await getCachedUserProfile();
    return profile?.userType == 'busker';
  }

  Future<bool> isUserAdmin() async {
    final profile = await getCachedUserProfile();
    return profile?.userType == 'admin';
  }

  Future<bool> isUserRegular() async {
    final profile = await getCachedUserProfile();
    return profile?.userType == 'user';
  }

  // Registration Helpers
  Future<ApiResponse<AuthResponse>> registerBusker({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return await register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      userType: 'busker',
    );
  }

  Future<ApiResponse<AuthResponse>> registerUser({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return await register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      userType: 'user',
    );
  }
}