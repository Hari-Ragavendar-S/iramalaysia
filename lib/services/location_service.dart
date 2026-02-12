import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/busking_location.dart';
import 'api_service.dart';

class LocationService {
  static final ApiService _apiService = ApiService();
  
  // Get all states
  static Future<Map<String, dynamic>> getStates() async {
    try {
      final response = await _apiService.get(ApiConfig.states);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load states',
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
  
  // Get cities by state
  static Future<Map<String, dynamic>> getCitiesByState(String state) async {
    try {
      final response = await _apiService.get(ApiConfig.cities(state));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load cities',
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
  
  // Get locations by state and city
  static Future<Map<String, dynamic>> getLocationsByCity(String state, String city) async {
    try {
      final response = await _apiService.get(ApiConfig.locations(state, city));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final locations = data.map((json) => BuskingLocation.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': locations,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load locations',
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
  
  // Get grouped locations
  static Future<Map<String, dynamic>> getGroupedLocations() async {
    try {
      final response = await _apiService.get(ApiConfig.groupedLocations);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': LocationsGrouped.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load grouped locations',
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
  
  // Get single location by ID
  static Future<Map<String, dynamic>> getLocation(String locationId) async {
    try {
      final response = await _apiService.get('/locations/$locationId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': BuskingLocation.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load location',
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