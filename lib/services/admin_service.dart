import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/admin_models.dart';
import 'api_service.dart';

class AdminService {
  static final ApiService _apiService = ApiService();

  // Admin login
  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/admin/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save tokens
        await _apiService.setTokens(
          data['access_token'],
          data['refresh_token'],
        );

        return {
          'success': true,
          'message': 'Admin login successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid admin credentials',
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

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard/stats');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': DashboardStats.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load dashboard stats',
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

  // Get all users
  static Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _apiService.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final users = data.map((json) => AdminUser.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': users,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load users',
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

  // Get all bookings
  static Future<Map<String, dynamic>> getAllBookings({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/admin/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final bookings = data.map((json) => AdminBooking.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': bookings,
          'pagination': response.data['pagination'],
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

  // Get all events
  static Future<Map<String, dynamic>> getAllEvents({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isPublished,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isPublished != null) queryParams['is_published'] = isPublished;

      final response = await _apiService.get(
        '/admin/events',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final events = data.map((json) => AdminEvent.fromJson(json)).toList();
        
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

  // Get all buskers
  static Future<Map<String, dynamic>> getAllBuskers({
    int page = 1,
    int limit = 20,
    String? search,
    String? city,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _apiService.get(
        '/admin/buskers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final buskers = data.map((json) => AdminBusker.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': buskers,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load buskers',
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

  // Get all pods
  static Future<Map<String, dynamic>> getAllPods({
    int page = 1,
    int limit = 20,
    String? search,
    String? city,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _apiService.get(
        '/admin/pods',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['pods'] ?? [];
        final pods = data.map((json) => AdminPod.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': pods,
          'total': response.data['total'],
          'page': response.data['page'],
          'pages': response.data['pages'],
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
  static Future<Map<String, dynamic>> getAdmins({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/admins',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final admins = data.map((json) => AdminProfile.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': admins,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load admins',
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

  // Add new admin
  static Future<Map<String, dynamic>> addAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/admins',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Admin added successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add admin',
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

  // Update admin
  static Future<Map<String, dynamic>> updateAdmin({
    required String adminId,
    String? name,
    String? email,
    String? role,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (role != null) data['role'] = role;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiService.put(
        '/admin/admins/$adminId',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Admin updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update admin',
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

  // Delete admin
  static Future<Map<String, dynamic>> deleteAdmin(String adminId) async {
    try {
      final response = await _apiService.delete('/admin/admins/$adminId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Admin deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete admin',
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

  // Get user by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/admin/users/$userId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': AdminUser.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load user',
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

  // Suspend user
  static Future<Map<String, dynamic>> suspendUser(String userId) async {
    try {
      final response = await _apiService.put('/admin/users/$userId/suspend');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User suspended successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to suspend user',
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

  // Activate user
  static Future<Map<String, dynamic>> activateUser(String userId) async {
    try {
      final response = await _apiService.put('/admin/users/$userId/activate');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User activated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to activate user',
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

  // Get pending buskers
  static Future<Map<String, dynamic>> getPendingBuskers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/buskers/pending',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'] ?? response.data;
        final buskers = data.map((json) => AdminBusker.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': buskers,
          'pagination': response.data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load pending buskers',
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

  // Verify busker
  static Future<Map<String, dynamic>> verifyBusker({
    required String buskerId,
    required bool approved,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/buskers/$buskerId/verify',
        data: {
          'approved': approved,
          'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': approved ? 'Busker verified successfully' : 'Busker rejected',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to verify busker',
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

  // Verify booking
  static Future<Map<String, dynamic>> verifyBooking({
    required String bookingId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '/admin/bookings/$bookingId/verify',
        data: {
          'status': status,
          'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Booking status updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update booking status',
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

  // Create pod
  static Future<Map<String, dynamic>> createPod({
    required String name,
    required String description,
    required String location,
    required String city,
    required String mall,
    required double basePrice,
    required List<String> features,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/pods',
        data: {
          'name': name,
          'description': description,
          'location': location,
          'city': city,
          'mall': mall,
          'base_price': basePrice,
          'features': features,
          'image_url': imageUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Pod created successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create pod',
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

  // Update pod
  static Future<Map<String, dynamic>> updatePod({
    required String podId,
    String? name,
    String? description,
    String? location,
    String? city,
    String? mall,
    double? basePrice,
    List<String>? features,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (location != null) data['location'] = location;
      if (city != null) data['city'] = city;
      if (mall != null) data['mall'] = mall;
      if (basePrice != null) data['base_price'] = basePrice;
      if (features != null) data['features'] = features;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiService.put(
        '/admin/pods/$podId',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Pod updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update pod',
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

  // Delete pod
  static Future<Map<String, dynamic>> deletePod(String podId) async {
    try {
      final response = await _apiService.delete('/admin/pods/$podId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Pod deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete pod',
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

  // Create event
  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    required String city,
    required double ticketPrice,
    required int maxAttendees,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final response = await _apiService.post(
        '/admin/events',
        data: {
          'title': title,
          'description': description,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'location': location,
          'city': city,
          'ticket_price': ticketPrice,
          'max_attendees': maxAttendees,
          'image_url': imageUrl,
          'category': category,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Event created successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create event',
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

  // Update event
  static Future<Map<String, dynamic>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? city,
    double? ticketPrice,
    int? maxAttendees,
    String? imageUrl,
    String? category,
    bool? isPublished,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (startDate != null) data['start_date'] = startDate.toIso8601String();
      if (endDate != null) data['end_date'] = endDate.toIso8601String();
      if (location != null) data['location'] = location;
      if (city != null) data['city'] = city;
      if (ticketPrice != null) data['ticket_price'] = ticketPrice;
      if (maxAttendees != null) data['max_attendees'] = maxAttendees;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (category != null) data['category'] = category;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _apiService.put(
        '/admin/events/$eventId',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Event updated successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update event',
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

  // Publish event
  static Future<Map<String, dynamic>> publishEvent(String eventId) async {
    try {
      final response = await _apiService.post('/admin/events/$eventId/publish');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Event published successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to publish event',
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