import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/event.dart';
import 'api_service.dart';

class EventsService {
  static final ApiService _apiService = ApiService();

  // Get all events
  static Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = 20,
    String? city,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPublished,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (isPublished != null) queryParams['is_published'] = isPublished;

      final response = await _apiService.get(
        ApiConfig.events,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final events = data.map((json) => Event.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': events,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load events',
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

  // Get event details
  static Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    try {
      final response = await _apiService.get('/events/$eventId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': Event.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load event details',
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

  // Book event
  static Future<Map<String, dynamic>> bookEvent({
    required String eventId,
    required int ticketQuantity,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.bookEvent(eventId),
        data: {
          'ticket_quantity': ticketQuantity,
          'total_amount': totalAmount,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Event booked successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to book event',
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

  // Get user's event bookings
  static Future<Map<String, dynamic>> getMyEventBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        ApiConfig.myEventBookings,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        
        return {
          'success': true,
          'data': data,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load event bookings',
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

  // Search events
  static Future<Map<String, dynamic>> searchEvents({
    required String query,
    int page = 1,
    int limit = 20,
    String? city,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };

      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/events/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final events = data.map((json) => Event.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': events,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to search events',
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

  // Get featured events
  static Future<Map<String, dynamic>> getFeaturedEvents({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/events/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final events = data.map((json) => Event.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': events,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load featured events',
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

  // Get events by category
  static Future<Map<String, dynamic>> getEventsByCategory({
    required String category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/events/category/$category',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final events = data.map((json) => Event.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': events,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load events by category',
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