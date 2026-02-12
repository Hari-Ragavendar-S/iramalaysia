import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/busker_pod.dart';
import '../models/pod_booking.dart';
import 'api_service.dart';

class PodService {
  static final ApiService _apiService = ApiService();

  // Get all pods
  static Future<Map<String, dynamic>> getPods({
    int page = 1,
    int perPage = 20,
    String? city,
    String? mall,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      
      if (city != null) queryParams['city'] = city;
      if (mall != null) queryParams['mall'] = mall;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      final response = await _apiService.get(
        '/pods',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> podsData = data['pods'] ?? [];
        final pods = podsData.map((json) => BuskerPod.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': pods,
          'total': data['total'],
          'page': data['page'],
          'per_page': data['per_page'],
          'pages': data['pages'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load pods',
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

  // Search pods
  static Future<Map<String, dynamic>> searchPods({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/pods/search',
        queryParameters: {
          'q': query,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> podsData = data['pods'] ?? [];
        final pods = podsData.map((json) => BuskerPod.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': pods,
          'total': data['total'],
          'page': data['page'],
          'per_page': data['per_page'],
          'pages': data['pages'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to search pods',
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

  // Get pod by ID
  static Future<Map<String, dynamic>> getPodById(String podId) async {
    try {
      final response = await _apiService.get('/pods/$podId');

      if (response.statusCode == 200) {
        final pod = BuskerPod.fromJson(response.data);
        return {
          'success': true,
          'data': pod,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load pod details',
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

  // Get pod availability
  static Future<Map<String, dynamic>> getPodAvailability({
    required String podId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        '/pods/$podId/availability',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load availability',
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

  // Create booking
  static Future<Map<String, dynamic>> createBooking({
    required String podId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/pods/bookings/simple',
        data: {
          'pod_id': podId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'total_amount': totalAmount,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final booking = PodBooking.fromJson(response.data);
        return {
          'success': true,
          'message': 'Booking created successfully',
          'data': booking,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create booking',
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

  // Get user bookings
  static Future<Map<String, dynamic>> getUserBookings({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/pods/bookings',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> bookingsData = data['bookings'] ?? [];
        final bookings = bookingsData.map((json) => PodBooking.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': bookings,
          'total': data['total'],
          'page': data['page'],
          'per_page': data['per_page'],
          'pages': data['pages'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load bookings',
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

  // Upload payment proof
  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String bookingId,
    required File proofFile,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'booking_id': bookingId,
        'file': await MultipartFile.fromFile(
          proofFile.path,
          filename: proofFile.path.split('/').last,
        ),
        if (notes != null) 'notes': notes,
      });

      final response = await _apiService.post(
        '/payment-proof/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Payment proof uploaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload payment proof',
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

  // Cancel booking
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await _apiService.put('/pods/bookings/$bookingId/cancel');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Booking cancelled successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to cancel booking',
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