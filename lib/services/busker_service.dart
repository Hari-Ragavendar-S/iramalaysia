import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class BuskerService {
  static final ApiService _apiService = ApiService();

  // Register as busker
  static Future<Map<String, dynamic>> registerBusker({
    String? stageName,
    String? bio,
    List<String>? genres,
    int? experienceYears,
    List<String>? citiesPerformed,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.buskerRegister,
        data: {
          'stage_name': stageName,
          'bio': bio,
          'genres': genres,
          'experience_years': experienceYears,
          'cities_performed': citiesPerformed,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Busker registration successful',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Busker registration failed',
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



  // Get busker profile
  static Future<Map<String, dynamic>> getBuskerProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.buskerProfile);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get busker profile',
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

  // Update busker profile
  static Future<Map<String, dynamic>> updateBuskerProfile({
    String? stageName,
    String? bio,
    List<String>? genres,
    int? experienceYears,
    List<String>? citiesPerformed,
    bool? isAvailable,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (stageName != null) data['stage_name'] = stageName;
      if (bio != null) data['bio'] = bio;
      if (genres != null) data['genres'] = genres;
      if (experienceYears != null) data['experience_years'] = experienceYears;
      if (citiesPerformed != null) data['cities_performed'] = citiesPerformed;
      if (isAvailable != null) data['is_available'] = isAvailable;

      final response = await _apiService.put(
        ApiConfig.buskerProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile',
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

  // Upload ID proof
  static Future<Map<String, dynamic>> uploadIdProof({
    required File idProofFile,
    required String idProofType,
    Function(int, int)? onProgress,
  }) async {
    try {
      final response = await _apiService.uploadFile(
        ApiConfig.buskerUploadId,
        idProofFile,
        fieldName: 'file',
        additionalData: {
          'id_proof_type': idProofType,
        },
        onSendProgress: onProgress != null 
            ? (int sent, int total) => onProgress(sent, total)
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'ID proof uploaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload ID proof',
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

  // Get profile (alias for getBuskerProfile)
  static Future<Map<String, dynamic>> getProfile() async {
    return getBuskerProfile();
  }

  // Update profile (alias for updateBuskerProfile)
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return updateBuskerProfile(
      stageName: profileData['stage_name'],
      bio: profileData['bio'],
      genres: profileData['genres']?.cast<String>(),
      experienceYears: profileData['experience_years'],
      citiesPerformed: profileData['cities_performed']?.cast<String>(),
      isAvailable: profileData['is_available'],
    );
  }

  // Get verification status
  static Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await _apiService.get('/buskers/verification-status');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get verification status',
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