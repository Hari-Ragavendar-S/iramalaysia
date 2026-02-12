import 'dart:convert';
import '../services/admin_service.dart';
import '../models/admin/admin_models.dart';
import '../models/user/user_models.dart';
import '../models/busker/busker_models.dart';
import '../models/event/event_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class AdminRepository {
  final AdminService _adminService = AdminService();

  // Dashboard
  Future<ApiResponse<AdminDashboardStats>> getDashboardStats() async {
    final response = await _adminService.getDashboardStats();
    
    if (response.success && response.data != null) {
      // Convert DashboardStats to AdminDashboardStats
      final stats = response.data!;
      final adminStats = AdminDashboardStats(
        totalUsers: stats.totalUsers,
        totalBuskers: stats.totalBuskers,
        totalBookings: stats.totalBookings,
        pendingBookings: 0, // Default value - would need backend support
        verifiedBookings: 0, // Default value - would need backend support  
        totalRevenue: stats.totalRevenue,
        activePods: 0, // Default value - would need backend support
      );
      
      // Cache dashboard stats
      await _cacheDashboardStats(adminStats);
      
      return ApiResponse<AdminDashboardStats>.success(
        data: adminStats,
        message: response.message,
      );
    }
    
    return ApiResponse<AdminDashboardStats>.error(error: response.error ?? 'Failed to get dashboard stats');
  }

  // Bookings Management
  Future<ApiResponse<List<AdminBooking>>> getAllBookings({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _adminService.getAllBookings(
      status: status,
      page: page,
      perPage: limit,
    );
    
    if (response.success && response.data != null) {
      // Convert PodBooking list to AdminBooking list
      final bookings = response.data!.bookings.map((booking) => AdminBooking(
        id: booking.id,
        bookingReference: booking.bookingReference,
        podId: booking.podId,
        podName: booking.pod?.name ?? 'Unknown Pod',
        userId: booking.userId,
        userName: 'Unknown User', // Default value
        userEmail: 'unknown@email.com', // Default value
        bookingDate: booking.bookingDate,
        timeSlots: booking.timeSlots.map((slot) => '${slot.start}-${slot.end}').toList(),
        totalAmount: booking.totalAmount,
        status: booking.status,
        paymentProofUrl: booking.paymentProofUrl,
        paymentUploadedAt: booking.paymentUploadedAt,
        paymentVerifiedAt: booking.paymentVerifiedAt,
        createdAt: booking.createdAt,
      )).toList();
      
      // Cache bookings list
      await _cacheBookingsList(bookings);
      
      return ApiResponse<List<AdminBooking>>.success(
        data: bookings,
        message: response.message,
      );
    }
    
    return ApiResponse<List<AdminBooking>>.error(error: response.error ?? 'Failed to get bookings');
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyBooking({
    required String bookingId,
    required bool approved,
    String? notes,
  }) async {
    final status = approved ? 'verified' : 'rejected';

    final response = await _adminService.verifyBookingPayment(
      bookingId: bookingId,
      status: status,
      notes: notes,
    );
    
    // Update cached booking status
    if (response.success) {
      await _updateCachedBookingStatus(
        bookingId,
        approved ? 'verified' : 'rejected',
      );
    }
    
    return response;
  }

  // Users Management
  Future<ApiResponse<List<AdminUser>>> getAllUsers({
    String? userType,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _adminService.getAllUsers(
      page: page,
      perPage: limit,
      userType: userType,
    );
    
    if (response.success && response.data != null) {
      // Convert User list to AdminUser list
      final users = response.data!.users.map((user) => AdminUser(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: 'user', // Default role
        permissions: [], // Default permissions
        isActive: user.isActive,
        createdBy: null,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLogin: null,
      )).toList();
      
      // Cache users list
      await _cacheUsersList(users);
      
      return ApiResponse<List<AdminUser>>.success(
        data: users,
        message: response.message,
      );
    }
    
    return ApiResponse<List<AdminUser>>.error(error: response.error ?? 'Failed to get users');
  }

  Future<ApiResponse<AdminUser>> getUserDetails(String userId) async {
    final response = await _adminService.getUserDetails(userId);
    
    if (response.success && response.data != null) {
      // Convert User to AdminUser
      final user = response.data!;
      final adminUser = AdminUser(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: 'user', // Default role
        permissions: [], // Default permissions
        isActive: user.isActive,
        createdBy: null,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLogin: null,
      );
      
      // Cache user details
      await _cacheUserDetails(userId, adminUser);
      
      return ApiResponse<AdminUser>.success(
        data: adminUser,
        message: response.message,
      );
    }
    
    return ApiResponse<AdminUser>.error(error: response.error ?? 'Failed to get user details');
  }

  Future<ApiResponse<Map<String, dynamic>>> suspendUser({
    required String userId,
    String? reason,
  }) async {
    final response = await _adminService.suspendUser(
      userId: userId,
      reason: reason,
    );
    
    // Update cached user status
    if (response.success) {
      await _updateCachedUserStatus(userId, 'suspended');
    }
    
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> activateUser({
    required String userId,
    String? reason,
  }) async {
    final response = await _adminService.activateUser(
      userId: userId,
      reason: reason,
    );
    
    // Update cached user status
    if (response.success) {
      await _updateCachedUserStatus(userId, 'active');
    }
    
    return response;
  }

  // Buskers Management
  Future<ApiResponse<List<AdminBusker>>> getAllBuskers({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _adminService.getAllBuskers(
      verificationStatus: status,
      page: page,
      perPage: limit,
    );
    
    if (response.success && response.data != null) {
      // Convert BuskerProfile list to AdminBusker list
      final buskers = response.data!.map((busker) => AdminBusker(
        id: busker.id,
        email: busker.email,
        fullName: busker.fullName,
        phoneNumber: busker.phoneNumber,
        verificationStatus: busker.verificationStatus,
        idProofUrl: busker.idProofUrl,
        verifiedAt: busker.verifiedAt,
        verifiedBy: busker.verifiedBy,
        createdAt: busker.createdAt,
      )).toList();
      
      // Cache buskers list
      await _cacheBuskersList(buskers);
      
      return ApiResponse<List<AdminBusker>>.success(
        data: buskers,
        message: response.message,
      );
    }
    
    return ApiResponse<List<AdminBusker>>.error(error: response.error ?? 'Failed to get buskers');
  }

  Future<ApiResponse<List<AdminBusker>>> getPendingBuskers() async {
    final response = await _adminService.getPendingBuskers();
    
    if (response.success && response.data != null) {
      // Convert BuskerProfile list to AdminBusker list
      final buskers = response.data!.map((busker) => AdminBusker(
        id: busker.id,
        email: busker.email,
        fullName: busker.fullName,
        phoneNumber: busker.phoneNumber,
        verificationStatus: busker.verificationStatus,
        idProofUrl: busker.idProofUrl,
        verifiedAt: busker.verifiedAt,
        verifiedBy: busker.verifiedBy,
        createdAt: busker.createdAt,
      )).toList();
      
      // Cache pending buskers
      await _cachePendingBuskers(buskers);
      
      return ApiResponse<List<AdminBusker>>.success(
        data: buskers,
        message: response.message,
      );
    }
    
    return ApiResponse<List<AdminBusker>>.error(error: response.error ?? 'Failed to get pending buskers');
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyBusker({
    required String buskerId,
    required bool approved,
    String? notes,
  }) async {
    final status = approved ? 'approved' : 'rejected';

    final response = await _adminService.verifyBusker(
      buskerId: buskerId,
      status: status,
      notes: notes,
    );
    
    // Update cached busker status
    if (response.success) {
      await _updateCachedBuskerStatus(
        buskerId,
        approved ? 'verified' : 'rejected',
      );
    }
    
    return response;
  }

  // Admins Management
  Future<ApiResponse<AdminUser>> createAdmin({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'admin',
  }) async {
    final request = AdminCreateRequest(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      permissions: [],
    );

    return await _adminService.createAdmin(request);
  }

  Future<ApiResponse<AdminUser>> updateAdmin({
    required String adminId,
    String? fullName,
    String? phone,
    String? role,
    bool? isActive,
  }) async {
    final request = AdminUpdateRequest(
      fullName: fullName,
      role: role,
      permissions: null,
      isActive: isActive,
    );

    final response = await _adminService.updateAdmin(
      adminId: adminId,
      request: request,
    );
    
    // Update cached admin details
    if (response.success && response.data != null) {
      await _cacheUserDetails(adminId, response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAdmin(String adminId) async {
    final response = await _adminService.deleteAdmin(adminId);
    
    // Remove from cache
    if (response.success) {
      await _removeCachedUser(adminId);
    }
    
    return response;
  }

  // Pods Management
  Future<ApiResponse<AdminPod>> createPod({
    required String name,
    required String description,
    required String location,
    required String address,
    required String city,
    required String state,
    required double pricePerHour,
    required List<String> amenities,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final podData = {
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'price_per_hour': pricePerHour,
      'amenities': amenities,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await _adminService.createPod(podData);
    
    if (response.success && response.data != null) {
      // Convert Pod to AdminPod
      final pod = response.data!;
      return ApiResponse<AdminPod>.success(
        data: AdminPod(
          id: pod.id,
          name: pod.name,
          description: pod.description ?? '',
          location: pod.address,
          basePrice: pod.pricePerHour,
          features: pod.amenities,
          isActive: pod.isActive,
          createdAt: pod.createdAt,
        ),
        message: response.message,
      );
    }
    
    return ApiResponse<AdminPod>.error(error: response.error ?? 'Failed to create pod');
  }

  Future<ApiResponse<AdminPod>> updatePod({
    required String podId,
    String? name,
    String? description,
    String? location,
    String? address,
    String? city,
    String? state,
    double? pricePerHour,
    List<String>? amenities,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    final podData = <String, dynamic>{};
    if (name != null) podData['name'] = name;
    if (description != null) podData['description'] = description;
    if (location != null) podData['location'] = location;
    if (address != null) podData['address'] = address;
    if (city != null) podData['city'] = city;
    if (state != null) podData['state'] = state;
    if (pricePerHour != null) podData['price_per_hour'] = pricePerHour;
    if (amenities != null) podData['amenities'] = amenities;
    if (imageUrl != null) podData['image_url'] = imageUrl;
    if (latitude != null) podData['latitude'] = latitude;
    if (longitude != null) podData['longitude'] = longitude;
    if (isActive != null) podData['is_active'] = isActive;

    final response = await _adminService.updatePod(
      podId: podId,
      podData: podData,
    );
    
    if (response.success && response.data != null) {
      // Convert Pod to AdminPod
      final pod = response.data!;
      return ApiResponse<AdminPod>.success(
        data: AdminPod(
          id: pod.id,
          name: pod.name,
          description: pod.description ?? '',
          location: pod.address,
          basePrice: pod.pricePerHour,
          features: pod.amenities,
          isActive: pod.isActive,
          createdAt: pod.createdAt,
        ),
        message: response.message,
      );
    }
    
    return ApiResponse<AdminPod>.error(error: response.error ?? 'Failed to update pod');
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePod(String podId) async {
    return await _adminService.deletePod(podId);
  }

  // Events Management
  Future<ApiResponse<AdminEvent>> createEvent({
    required String title,
    required String description,
    required String location,
    required String startDate,
    required String endDate,
    required double ticketPrice,
    required int totalTickets,
    String? imageUrl,
    String? category,
  }) async {
    final eventData = {
      'title': title,
      'description': description,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'ticket_price': ticketPrice,
      'total_tickets': totalTickets,
      'image_url': imageUrl,
      'category': category,
    };

    final response = await _adminService.createEvent(eventData);
    
    if (response.success && response.data != null) {
      // Convert Event to AdminEvent
      final event = response.data!;
      return ApiResponse<AdminEvent>.success(
        data: AdminEvent(
          id: event.id,
          title: event.title,
          description: event.description ?? '',
          eventDate: event.eventDate,
          location: event.venue, // Use venue instead of location
          ticketPrice: event.ticketPrice ?? 0.0,
          maxCapacity: event.maxCapacity ?? 0,
          isPublished: event.isPublished,
          createdAt: event.createdAt,
        ),
        message: response.message,
      );
    }
    
    return ApiResponse<AdminEvent>.error(error: response.error ?? 'Failed to create event');
  }

  Future<ApiResponse<AdminEvent>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    String? startDate,
    String? endDate,
    double? ticketPrice,
    int? totalTickets,
    String? imageUrl,
    String? category,
    String? status,
  }) async {
    final eventData = <String, dynamic>{};
    if (title != null) eventData['title'] = title;
    if (description != null) eventData['description'] = description;
    if (location != null) eventData['location'] = location;
    if (startDate != null) eventData['start_date'] = startDate;
    if (endDate != null) eventData['end_date'] = endDate;
    if (ticketPrice != null) eventData['ticket_price'] = ticketPrice;
    if (totalTickets != null) eventData['total_tickets'] = totalTickets;
    if (imageUrl != null) eventData['image_url'] = imageUrl;
    if (category != null) eventData['category'] = category;
    if (status != null) eventData['status'] = status;

    final response = await _adminService.updateEvent(
      eventId: eventId,
      eventData: eventData,
    );
    
    if (response.success && response.data != null) {
      // Convert Event to AdminEvent
      final event = response.data!;
      return ApiResponse<AdminEvent>.success(
        data: AdminEvent(
          id: event.id,
          title: event.title,
          description: event.description ?? '',
          eventDate: event.eventDate,
          location: event.venue, // Use venue instead of location
          ticketPrice: event.ticketPrice ?? 0.0,
          maxCapacity: event.maxCapacity ?? 0,
          isPublished: event.isPublished,
          createdAt: event.createdAt,
        ),
        message: response.message,
      );
    }
    
    return ApiResponse<AdminEvent>.error(error: response.error ?? 'Failed to update event');
  }

  Future<ApiResponse<Map<String, dynamic>>> publishEvent(String eventId) async {
    return await _adminService.publishEvent(eventId);
  }

  // Cached Data Management
  Future<AdminDashboardStats?> getCachedDashboardStats() async {
    final statsData = await SecureStorage.read('admin_dashboard_stats');
    if (statsData != null) {
      try {
        final Map<String, dynamic> statsJson = jsonDecode(statsData);
        return AdminDashboardStats.fromJson(statsJson);
      } catch (e) {
        await SecureStorage.delete('admin_dashboard_stats');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheDashboardStats(AdminDashboardStats stats) async {
    await SecureStorage.write('admin_dashboard_stats', jsonEncode(stats.toJson()));
  }

  Future<List<AdminBooking>?> getCachedBookingsList() async {
    final bookingsData = await SecureStorage.read('admin_bookings');
    if (bookingsData != null) {
      try {
        final List<dynamic> bookingsList = jsonDecode(bookingsData);
        return bookingsList.map((json) => AdminBooking.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('admin_bookings');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheBookingsList(List<AdminBooking> bookings) async {
    final bookingsJson = bookings.map((booking) => booking.toJson()).toList();
    await SecureStorage.write('admin_bookings', jsonEncode(bookingsJson));
  }

  Future<void> _updateCachedBookingStatus(String bookingId, String status) async {
    final cachedBookings = await getCachedBookingsList();
    if (cachedBookings != null) {
      final updatedBookings = cachedBookings.map((booking) {
        if (booking.id == bookingId) {
          return booking.copyWith(status: status);
        }
        return booking;
      }).toList();
      await _cacheBookingsList(updatedBookings);
    }
  }

  Future<List<AdminUser>?> getCachedUsersList() async {
    final usersData = await SecureStorage.read('admin_users');
    if (usersData != null) {
      try {
        final List<dynamic> usersList = jsonDecode(usersData);
        return usersList.map((json) => AdminUser.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('admin_users');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheUsersList(List<AdminUser> users) async {
    final usersJson = users.map((user) => user.toJson()).toList();
    await SecureStorage.write('admin_users', jsonEncode(usersJson));
  }

  Future<AdminUser?> getCachedUserDetails(String userId) async {
    final userData = await SecureStorage.read('admin_user_$userId');
    if (userData != null) {
      try {
        final Map<String, dynamic> userJson = jsonDecode(userData);
        return AdminUser.fromJson(userJson);
      } catch (e) {
        await SecureStorage.delete('admin_user_$userId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheUserDetails(String userId, AdminUser user) async {
    await SecureStorage.write('admin_user_$userId', jsonEncode(user.toJson()));
  }

  Future<void> _updateCachedUserStatus(String userId, String status) async {
    final cachedUser = await getCachedUserDetails(userId);
    if (cachedUser != null) {
      final updatedUser = cachedUser.copyWith(status: status);
      await _cacheUserDetails(userId, updatedUser);
    }
  }

  Future<void> _removeCachedUser(String userId) async {
    await SecureStorage.delete('admin_user_$userId');
  }

  Future<List<AdminBusker>?> getCachedBuskersList() async {
    final buskersData = await SecureStorage.read('admin_buskers');
    if (buskersData != null) {
      try {
        final List<dynamic> buskersList = jsonDecode(buskersData);
        return buskersList.map((json) => AdminBusker.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('admin_buskers');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheBuskersList(List<AdminBusker> buskers) async {
    final buskersJson = buskers.map((busker) => busker.toJson()).toList();
    await SecureStorage.write('admin_buskers', jsonEncode(buskersJson));
  }

  Future<List<AdminBusker>?> getCachedPendingBuskers() async {
    final buskersData = await SecureStorage.read('admin_pending_buskers');
    if (buskersData != null) {
      try {
        final List<dynamic> buskersList = jsonDecode(buskersData);
        return buskersList.map((json) => AdminBusker.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('admin_pending_buskers');
        return null;
      }
    }
    return null;
  }

  Future<void> _cachePendingBuskers(List<AdminBusker> buskers) async {
    final buskersJson = buskers.map((busker) => busker.toJson()).toList();
    await SecureStorage.write('admin_pending_buskers', jsonEncode(buskersJson));
  }

  Future<void> _updateCachedBuskerStatus(String buskerId, String status) async {
    final cachedBuskers = await getCachedBuskersList();
    if (cachedBuskers != null) {
      final updatedBuskers = cachedBuskers.map((busker) {
        if (busker.id == buskerId) {
          return busker.copyWith(verificationStatus: status);
        }
        return busker;
      }).toList();
      await _cacheBuskersList(updatedBuskers);
    }
  }

  Future<void> clearCachedAdminData() async {
    await SecureStorage.delete('admin_dashboard_stats');
    await SecureStorage.delete('admin_bookings');
    await SecureStorage.delete('admin_users');
    await SecureStorage.delete('admin_buskers');
    await SecureStorage.delete('admin_pending_buskers');
  }

  // Admin Helpers
  Future<List<AdminBooking>> getPendingBookings() async {
    final response = await getAllBookings(status: 'pending');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<AdminBooking>> getVerifiedBookings() async {
    final response = await getAllBookings(status: 'verified');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<AdminUser>> getActiveUsers() async {
    final response = await getAllUsers(status: 'active');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<AdminUser>> getSuspendedUsers() async {
    final response = await getAllUsers(status: 'suspended');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<AdminBusker>> getVerifiedBuskers() async {
    final response = await getAllBuskers(status: 'verified');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<AdminBusker>> getRejectedBuskers() async {
    final response = await getAllBuskers(status: 'rejected');
    return response.success ? response.data ?? [] : [];
  }

  // Statistics Helpers
  Future<int> getTotalUsers() async {
    final stats = await getCachedDashboardStats();
    return stats?.totalUsers ?? 0;
  }

  Future<int> getTotalBuskers() async {
    final stats = await getCachedDashboardStats();
    return stats?.totalBuskers ?? 0;
  }

  Future<int> getTotalBookings() async {
    final stats = await getCachedDashboardStats();
    return stats?.totalBookings ?? 0;
  }

  Future<int> getPendingBookingsCount() async {
    final stats = await getCachedDashboardStats();
    return stats?.pendingBookings ?? 0;
  }

  // Refresh Data
  Future<ApiResponse<AdminDashboardStats>> refreshDashboardStats() async {
    await SecureStorage.delete('admin_dashboard_stats');
    return await getDashboardStats();
  }

  Future<ApiResponse<List<AdminBooking>>> refreshBookingsList() async {
    await SecureStorage.delete('admin_bookings');
    return await getAllBookings();
  }

  Future<ApiResponse<List<AdminUser>>> refreshUsersList() async {
    await SecureStorage.delete('admin_users');
    return await getAllUsers();
  }

  Future<ApiResponse<List<AdminBusker>>> refreshBuskersList() async {
    await SecureStorage.delete('admin_buskers');
    return await getAllBuskers();
  }

  Future<ApiResponse<List<AdminBusker>>> refreshPendingBuskers() async {
    await SecureStorage.delete('admin_pending_buskers');
    return await getPendingBuskers();
  }
}