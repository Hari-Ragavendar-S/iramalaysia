import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/admin/admin_models.dart';
import '../models/user/user_models.dart';
import '../models/busker/busker_models.dart';
import '../models/pod/pod_models.dart';
import '../models/event/event_models.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient.instance;

  // Dashboard
  Future<ApiResponse<DashboardStats>> getDashboardStats() async {
    return await _apiClient.get<DashboardStats>(
      ApiEndpoints.adminDashboardStats,
      fromJson: (json) => DashboardStats.fromJson(json),
    );
  }

  // Booking Management
  Future<ApiResponse<BookingListResponse>> getAllBookings({
    int page = 1,
    int perPage = 20,
    String? status,
    String? paymentStatus,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null) queryParams['status'] = status;
    if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;

    return await _apiClient.get<BookingListResponse>(
      ApiEndpoints.adminBookings,
      queryParameters: queryParams,
      fromJson: (json) => BookingListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyBookingPayment({
    required String bookingId,
    required String status, // 'verified' or 'rejected'
    String? notes,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminBookingVerify(bookingId),
      data: BookingVerificationRequest(status: status, notes: notes).toJson(),
    );
  }

  // User Management
  Future<ApiResponse<UserListResponse>> getAllUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? userType,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (search != null) queryParams['search'] = search;
    if (userType != null) queryParams['user_type'] = userType;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiClient.get<UserListResponse>(
      ApiEndpoints.adminUsers,
      queryParameters: queryParams,
      fromJson: (json) => UserListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<User>> getUserDetails(String userId) async {
    return await _apiClient.get<User>(
      ApiEndpoints.adminUserDetails(userId),
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> suspendUser({
    required String userId,
    String? reason,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminUserSuspend(userId),
      data: UserActionRequest(action: 'suspend', reason: reason).toJson(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> activateUser({
    required String userId,
    String? reason,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminUserActivate(userId),
      data: UserActionRequest(action: 'activate', reason: reason).toJson(),
    );
  }

  // Busker Management
  Future<ApiResponse<List<BuskerProfile>>> getAllBuskers({
    int page = 1,
    int perPage = 20,
    String? verificationStatus,
    bool? isAvailable,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (verificationStatus != null) queryParams['verification_status'] = verificationStatus;
    if (isAvailable != null) queryParams['is_available'] = isAvailable;

    return await _apiClient.get<List<BuskerProfile>>(
      ApiEndpoints.adminBuskers,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((busker) => BuskerProfile.fromJson(busker))
          .toList(),
    );
  }

  Future<ApiResponse<List<BuskerProfile>>> getPendingBuskers() async {
    return await _apiClient.get<List<BuskerProfile>>(
      ApiEndpoints.adminBuskersPending,
      fromJson: (json) => (json as List)
          .map((busker) => BuskerProfile.fromJson(busker))
          .toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyBusker({
    required String buskerId,
    required String status, // 'approved' or 'rejected'
    String? notes,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminBuskerVerify(buskerId),
      data: BuskerVerificationRequest(status: status, notes: notes).toJson(),
    );
  }

  // Pod Management
  Future<ApiResponse<PodListResponse>> getAllPods({
    int page = 1,
    int perPage = 20,
    String? city,
    String? mall,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (city != null) queryParams['city'] = city;
    if (mall != null) queryParams['mall'] = mall;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiClient.get<PodListResponse>(
      ApiEndpoints.adminPods,
      queryParameters: queryParams,
      fromJson: (json) => PodListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<Pod>> createPod(Map<String, dynamic> podData) async {
    return await _apiClient.post<Pod>(
      ApiEndpoints.adminPods,
      data: podData,
      fromJson: (json) => Pod.fromJson(json),
    );
  }

  Future<ApiResponse<Pod>> updatePod({
    required String podId,
    required Map<String, dynamic> podData,
  }) async {
    return await _apiClient.put<Pod>(
      ApiEndpoints.adminPodUpdate(podId),
      data: podData,
      fromJson: (json) => Pod.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePod(String podId) async {
    return await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.adminPodDelete(podId),
    );
  }

  // Event Management
  Future<ApiResponse<EventListResponse>> getAllEvents({
    int page = 1,
    int perPage = 20,
    String? city,
    String? category,
    bool? isPublished,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (city != null) queryParams['city'] = city;
    if (category != null) queryParams['category'] = category;
    if (isPublished != null) queryParams['is_published'] = isPublished;

    return await _apiClient.get<EventListResponse>(
      ApiEndpoints.adminEvents,
      queryParameters: queryParams,
      fromJson: (json) => EventListResponse.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> createEvent(Map<String, dynamic> eventData) async {
    return await _apiClient.post<Event>(
      ApiEndpoints.adminEvents,
      data: eventData,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> updateEvent({
    required String eventId,
    required Map<String, dynamic> eventData,
  }) async {
    return await _apiClient.put<Event>(
      ApiEndpoints.adminEventUpdate(eventId),
      data: eventData,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> publishEvent(String eventId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.adminEventPublish(eventId),
    );
  }

  // Admin User Management
  Future<ApiResponse<List<AdminUser>>> getAllAdmins({
    int page = 1,
    int perPage = 20,
    String? role,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (role != null) queryParams['role'] = role;
    if (isActive != null) queryParams['is_active'] = isActive;

    return await _apiClient.get<List<AdminUser>>(
      ApiEndpoints.adminAdmins,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((admin) => AdminUser.fromJson(admin))
          .toList(),
    );
  }

  Future<ApiResponse<AdminUser>> createAdmin(AdminCreateRequest request) async {
    return await _apiClient.post<AdminUser>(
      ApiEndpoints.adminAdmins,
      data: request.toJson(),
      fromJson: (json) => AdminUser.fromJson(json),
    );
  }

  Future<ApiResponse<AdminUser>> updateAdmin({
    required String adminId,
    required AdminUpdateRequest request,
  }) async {
    return await _apiClient.put<AdminUser>(
      ApiEndpoints.adminAdminUpdate(adminId),
      data: request.toJson(),
      fromJson: (json) => AdminUser.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAdmin(String adminId) async {
    return await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.adminAdminDelete(adminId),
    );
  }

  // Helper methods for filtering
  Future<ApiResponse<BookingListResponse>> getPendingBookings({int page = 1}) async {
    return await getAllBookings(paymentStatus: 'pending', page: page);
  }

  Future<ApiResponse<BookingListResponse>> getVerifiedBookings({int page = 1}) async {
    return await getAllBookings(paymentStatus: 'verified', page: page);
  }

  Future<ApiResponse<BookingListResponse>> getRejectedBookings({int page = 1}) async {
    return await getAllBookings(paymentStatus: 'rejected', page: page);
  }

  Future<ApiResponse<List<BuskerProfile>>> getApprovedBuskers({int page = 1}) async {
    return await getAllBuskers(verificationStatus: 'approved', page: page);
  }

  Future<ApiResponse<List<BuskerProfile>>> getRejectedBuskers({int page = 1}) async {
    return await getAllBuskers(verificationStatus: 'rejected', page: page);
  }

  Future<ApiResponse<UserListResponse>> getActiveBuskers({int page = 1}) async {
    return await getAllUsers(userType: 'busker', isActive: true, page: page);
  }

  Future<ApiResponse<UserListResponse>> getInactiveUsers({int page = 1}) async {
    return await getAllUsers(isActive: false, page: page);
  }

  Future<ApiResponse<EventListResponse>> getPublishedEvents({int page = 1}) async {
    return await getAllEvents(isPublished: true, page: page);
  }

  Future<ApiResponse<EventListResponse>> getUnpublishedEvents({int page = 1}) async {
    return await getAllEvents(isPublished: false, page: page);
  }

  Future<ApiResponse<PodListResponse>> getActivePods({int page = 1}) async {
    return await getAllPods(isActive: true, page: page);
  }

  Future<ApiResponse<PodListResponse>> getInactivePods({int page = 1}) async {
    return await getAllPods(isActive: false, page: page);
  }

  // Utility methods
  bool canVerifyBooking(PodBooking booking) {
    final paymentStatus = PaymentStatus.fromString(booking.paymentStatus ?? 'pending');
    return paymentStatus == PaymentStatus.pending && booking.paymentProofUrl != null;
  }

  bool canVerifyBusker(BuskerProfile busker) {
    return busker.verificationStatus == 'pending' && busker.idProofUrl != null;
  }

  String getBookingStatusDisplay(PodBooking booking) {
    return BookingStatus.fromString(booking.status).displayName;
  }

  String getPaymentStatusDisplay(PodBooking booking) {
    return PaymentStatus.fromString(booking.paymentStatus ?? 'pending').displayName;
  }

  String getBuskerVerificationStatusDisplay(BuskerProfile busker) {
    return BuskerVerificationStatus.fromString(busker.verificationStatus).displayName;
  }

  String getAdminRoleDisplay(AdminUser admin) {
    return AdminRole.fromString(admin.role).displayName;
  }
}