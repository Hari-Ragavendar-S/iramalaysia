import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/busker/busker_models.dart';

class BuskerService {
  final ApiClient _apiClient = ApiClient.instance;

  // Register as Busker
  Future<ApiResponse<BuskerProfile>> register(BuskerRegisterRequest request) async {
    return await _apiClient.post<BuskerProfile>(
      ApiEndpoints.buskersRegister,
      data: request.toJson(),
      fromJson: (json) => BuskerProfile.fromJson(json),
    );
  }

  // Get Busker Profile
  Future<ApiResponse<BuskerProfile>> getProfile() async {
    return await _apiClient.get<BuskerProfile>(
      ApiEndpoints.buskersProfile,
      fromJson: (json) => BuskerProfile.fromJson(json),
    );
  }

  // Update Busker Profile
  Future<ApiResponse<BuskerProfile>> updateProfile(BuskerUpdateRequest request) async {
    return await _apiClient.put<BuskerProfile>(
      ApiEndpoints.buskersProfile,
      data: request.toJson(),
      fromJson: (json) => BuskerProfile.fromJson(json),
    );
  }

  // Get Verification Status
  Future<ApiResponse<VerificationStatus>> getVerificationStatus() async {
    return await _apiClient.get<VerificationStatus>(
      ApiEndpoints.buskersVerificationStatus,
      fromJson: (json) => VerificationStatus.fromJson(json),
    );
  }

  // Upload ID Proof
  Future<ApiResponse<Map<String, dynamic>>> uploadIdProof({
    required File idProofFile,
    required IdProofType idProofType,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        idProofFile.path,
        filename: idProofFile.path.split('/').last,
      ),
      'id_proof_type': idProofType.value,
    });

    return await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.buskersUploadIdProof,
      formData: formData,
      onSendProgress: onProgress,
    );
  }

  // Update specific profile fields
  Future<ApiResponse<BuskerProfile>> updateStageName(String stageName) async {
    return await updateProfile(BuskerUpdateRequest(stageName: stageName));
  }

  Future<ApiResponse<BuskerProfile>> updateBio(String bio) async {
    return await updateProfile(BuskerUpdateRequest(bio: bio));
  }

  Future<ApiResponse<BuskerProfile>> updateGenres(List<String> genres) async {
    return await updateProfile(BuskerUpdateRequest(genres: genres));
  }

  Future<ApiResponse<BuskerProfile>> updateExperience(int years) async {
    return await updateProfile(BuskerUpdateRequest(experienceYears: years));
  }

  Future<ApiResponse<BuskerProfile>> updateCitiesPerformed(List<String> cities) async {
    return await updateProfile(BuskerUpdateRequest(citiesPerformed: cities));
  }

  Future<ApiResponse<BuskerProfile>> updateAvailability(bool isAvailable) async {
    return await updateProfile(BuskerUpdateRequest(isAvailable: isAvailable));
  }

  // Batch update
  Future<ApiResponse<BuskerProfile>> updateMultipleFields({
    String? stageName,
    String? bio,
    List<String>? genres,
    int? experienceYears,
    List<String>? citiesPerformed,
    bool? isAvailable,
  }) async {
    return await updateProfile(BuskerUpdateRequest(
      stageName: stageName,
      bio: bio,
      genres: genres,
      experienceYears: experienceYears,
      citiesPerformed: citiesPerformed,
      isAvailable: isAvailable,
    ));
  }

  // Helper methods
  bool isVerified(BuskerProfile profile) {
    return profile.verificationStatus == 'approved';
  }

  bool isPending(BuskerProfile profile) {
    return profile.verificationStatus == 'pending';
  }

  bool isRejected(BuskerProfile profile) {
    return profile.verificationStatus == 'rejected';
  }

  BuskerVerificationStatus getVerificationStatusEnum(BuskerProfile profile) {
    return BuskerVerificationStatus.fromString(profile.verificationStatus);
  }
}