import '../services/user_service.dart';
import '../models/user/user_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class UserRepository {
  final UserService _userService = UserService();

  // Profile Management
  Future<ApiResponse<UserProfile>> getProfile() async {
    final response = await _userService.getProfile();
    
    // Update cached user data if successful
    if (response.success && response.data != null) {
      await SecureStorage.saveUserData(response.data!.toJson());
    }
    
    return response;
  }

  Future<ApiResponse<UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? profileImageUrl,
  }) async {
    final request = UpdateProfileRequest(
      fullName: fullName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
      city: city,
      state: state,
      country: country,
      profileImageUrl: profileImageUrl,
    );

    final response = await _userService.updateProfile(request);
    
    // Update cached user data if successful
    if (response.success && response.data != null) {
      await SecureStorage.saveUserData(response.data!.toJson());
    }
    
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    final response = await _userService.deleteAccount();
    
    // Clear all stored data if account deleted successfully
    if (response.success) {
      await SecureStorage.clearAll();
    }
    
    return response;
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

  // Profile Helpers
  Future<bool> isProfileComplete() async {
    final profile = await getCachedUserProfile();
    if (profile == null) return false;
    
    return profile.fullName?.isNotEmpty == true &&
           profile.phone?.isNotEmpty == true;
  }

  Future<String?> getUserId() async {
    final profile = await getCachedUserProfile();
    return profile?.id;
  }

  Future<String?> getUserEmail() async {
    final profile = await getCachedUserProfile();
    return profile?.email;
  }

  Future<String?> getUserFullName() async {
    final profile = await getCachedUserProfile();
    return profile?.fullName;
  }

  Future<String?> getUserPhone() async {
    final profile = await getCachedUserProfile();
    return profile?.phone;
  }

  Future<String?> getUserType() async {
    final profile = await getCachedUserProfile();
    return profile?.userType;
  }

  Future<String?> getProfileImageUrl() async {
    final profile = await getCachedUserProfile();
    return profile?.profileImageUrl;
  }

  // Profile Update Helpers
  Future<ApiResponse<UserProfile>> updateFullName(String fullName) async {
    return await updateProfile(fullName: fullName);
  }

  Future<ApiResponse<UserProfile>> updatePhone(String phone) async {
    return await updateProfile(phone: phone);
  }

  Future<ApiResponse<UserProfile>> updateProfileImage(String imageUrl) async {
    return await updateProfile(profileImageUrl: imageUrl);
  }

  Future<ApiResponse<UserProfile>> updateAddress({
    String? address,
    String? city,
    String? state,
    String? country,
  }) async {
    return await updateProfile(
      address: address,
      city: city,
      state: state,
      country: country,
    );
  }

  // Validation Helpers
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    // Malaysian phone number validation
    return RegExp(r'^(\+?6?01)[0-46-9]-*[0-9]{7,8}$').hasMatch(phone);
  }

  bool isValidName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  // Account Status
  Future<bool> isAccountActive() async {
    final profile = await getCachedUserProfile();
    return profile?.isActive == true;
  }

  Future<bool> isAccountVerified() async {
    final profile = await getCachedUserProfile();
    return profile?.isVerified == true;
  }

  // Refresh Profile Data
  Future<ApiResponse<UserProfile>> refreshProfile() async {
    // Clear cached data and fetch fresh data
    await clearCachedUserData();
    return await getProfile();
  }
}