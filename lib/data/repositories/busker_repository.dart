import 'dart:io';
import '../services/busker_service.dart';
import '../models/busker/busker_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class BuskerRepository {
  final BuskerService _buskerService = BuskerService();

  // Busker Registration
  Future<ApiResponse<BuskerRegistrationResponse>> registerBusker({
    required String fullName,
    required String phone,
    required String icNumber,
    required String address,
    required String city,
    required String state,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? bankAccountNumber,
    String? bankName,
    List<String>? performanceTypes,
    String? bio,
  }) async {
    final request = BuskerRegistrationRequest(
      fullName: fullName,
      phone: phone,
      icNumber: icNumber,
      address: address,
      city: city,
      state: state,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      bankAccountNumber: bankAccountNumber,
      bankName: bankName,
      performanceTypes: performanceTypes,
      bio: bio,
    );

    return await _buskerService.registerBusker(request);
  }

  // ID Proof Upload
  Future<ApiResponse<Map<String, dynamic>>> uploadIdProof({
    required File frontImage,
    required File backImage,
  }) async {
    return await _buskerService.uploadIdProof(
      frontImage: frontImage,
      backImage: backImage,
    );
  }

  // Profile Management
  Future<ApiResponse<BuskerProfile>> getProfile() async {
    final response = await _buskerService.getProfile();
    
    // Cache busker profile data
    if (response.success && response.data != null) {
      await _cacheBuskerProfile(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<BuskerProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? bankAccountNumber,
    String? bankName,
    List<String>? performanceTypes,
    String? bio,
    String? profileImageUrl,
  }) async {
    final request = UpdateBuskerProfileRequest(
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      state: state,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      bankAccountNumber: bankAccountNumber,
      bankName: bankName,
      performanceTypes: performanceTypes,
      bio: bio,
      profileImageUrl: profileImageUrl,
    );

    final response = await _buskerService.updateProfile(request);
    
    // Update cached profile
    if (response.success && response.data != null) {
      await _cacheBuskerProfile(response.data!);
    }
    
    return response;
  }

  // Verification Status
  Future<ApiResponse<BuskerVerificationStatus>> getVerificationStatus() async {
    return await _buskerService.getVerificationStatus();
  }

  // Cached Data Management
  Future<BuskerProfile?> getCachedBuskerProfile() async {
    final profileData = await SecureStorage.get('busker_profile');
    if (profileData != null) {
      try {
        return BuskerProfile.fromJson(profileData);
      } catch (e) {
        await SecureStorage.delete('busker_profile');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheBuskerProfile(BuskerProfile profile) async {
    await SecureStorage.save('busker_profile', profile.toJson());
  }

  Future<void> clearCachedBuskerData() async {
    await SecureStorage.delete('busker_profile');
  }

  // Profile Helpers
  Future<bool> isBuskerProfileComplete() async {
    final profile = await getCachedBuskerProfile();
    if (profile == null) return false;
    
    return profile.fullName?.isNotEmpty == true &&
           profile.phone?.isNotEmpty == true &&
           profile.icNumber?.isNotEmpty == true &&
           profile.address?.isNotEmpty == true;
  }

  Future<bool> isBuskerVerified() async {
    final status = await getVerificationStatus();
    return status.success && 
           status.data?.verificationStatus == 'verified';
  }

  Future<bool> isBuskerPending() async {
    final status = await getVerificationStatus();
    return status.success && 
           status.data?.verificationStatus == 'pending';
  }

  Future<bool> isBuskerRejected() async {
    final status = await getVerificationStatus();
    return status.success && 
           status.data?.verificationStatus == 'rejected';
  }

  Future<String?> getBuskerId() async {
    final profile = await getCachedBuskerProfile();
    return profile?.id;
  }

  Future<String?> getBuskerFullName() async {
    final profile = await getCachedBuskerProfile();
    return profile?.fullName;
  }

  Future<String?> getBuskerPhone() async {
    final profile = await getCachedBuskerProfile();
    return profile?.phone;
  }

  Future<List<String>?> getBuskerPerformanceTypes() async {
    final profile = await getCachedBuskerProfile();
    return profile?.performanceTypes;
  }

  Future<String?> getBuskerBio() async {
    final profile = await getCachedBuskerProfile();
    return profile?.bio;
  }

  // Validation Helpers
  bool isValidIcNumber(String icNumber) {
    // Malaysian IC number validation (12 digits: YYMMDD-PB-###G)
    return RegExp(r'^\d{6}-\d{2}-\d{4}$').hasMatch(icNumber);
  }

  bool isValidBankAccount(String accountNumber) {
    // Basic bank account validation (8-20 digits)
    return RegExp(r'^\d{8,20}$').hasMatch(accountNumber);
  }

  bool isValidPhone(String phone) {
    // Malaysian phone number validation
    return RegExp(r'^(\+?6?01)[0-46-9]-*[0-9]{7,8}$').hasMatch(phone);
  }

  // Performance Types
  List<String> getAvailablePerformanceTypes() {
    return [
      'Music - Acoustic Guitar',
      'Music - Electric Guitar',
      'Music - Piano/Keyboard',
      'Music - Violin',
      'Music - Drums',
      'Music - Singing',
      'Music - Band Performance',
      'Dance - Traditional',
      'Dance - Modern',
      'Dance - Hip Hop',
      'Dance - Ballet',
      'Magic Show',
      'Comedy',
      'Storytelling',
      'Art - Painting',
      'Art - Sketching',
      'Art - Caricature',
      'Acrobatics',
      'Juggling',
      'Mime',
      'Other',
    ];
  }

  // Profile Update Helpers
  Future<ApiResponse<BuskerProfile>> updateBio(String bio) async {
    return await updateProfile(bio: bio);
  }

  Future<ApiResponse<BuskerProfile>> updatePerformanceTypes(
    List<String> performanceTypes,
  ) async {
    return await updateProfile(performanceTypes: performanceTypes);
  }

  Future<ApiResponse<BuskerProfile>> updateBankDetails({
    required String bankAccountNumber,
    required String bankName,
  }) async {
    return await updateProfile(
      bankAccountNumber: bankAccountNumber,
      bankName: bankName,
    );
  }

  Future<ApiResponse<BuskerProfile>> updateEmergencyContact({
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) async {
    return await updateProfile(
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );
  }

  // Refresh Profile Data
  Future<ApiResponse<BuskerProfile>> refreshProfile() async {
    await clearCachedBuskerData();
    return await getProfile();
  }
}