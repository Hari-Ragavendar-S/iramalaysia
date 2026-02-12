import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/user/user_models.dart';

class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  // Get User Profile
  Future<ApiResponse<User>> getProfile() async {
    return await _apiClient.get<User>(
      ApiEndpoints.usersProfile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Update User Profile
  Future<ApiResponse<User>> updateProfile(UpdateUserRequest request) async {
    return await _apiClient.put<User>(
      ApiEndpoints.usersProfile,
      data: request.toJson(),
      fromJson: (json) => User.fromJson(json),
    );
  }

  // Delete User Account
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    return await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.usersAccount,
    );
  }

  // Update specific profile fields
  Future<ApiResponse<User>> updateFullName(String fullName) async {
    return await updateProfile(UpdateUserRequest(fullName: fullName));
  }

  Future<ApiResponse<User>> updatePhone(String phone) async {
    return await updateProfile(UpdateUserRequest(phone: phone));
  }

  Future<ApiResponse<User>> updateProfileImage(String imageUrl) async {
    return await updateProfile(UpdateUserRequest(profileImageUrl: imageUrl));
  }

  // Batch update
  Future<ApiResponse<User>> updateMultipleFields({
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    return await updateProfile(UpdateUserRequest(
      fullName: fullName,
      phone: phone,
      profileImageUrl: profileImageUrl,
    ));
  }
}