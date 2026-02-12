import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/pod/pod_models.dart';

class PodService {
  final ApiClient _apiClient = ApiClient.instance;

  // Get Pods List
  Future<ApiResponse<PodListResponse>> getPods({
    int page = 1,
    int perPage = 20,
    String? city,
    String? mall,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (city != null) queryParams['city'] = city;
    if (mall != null) queryParams['mall'] = mall;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;

    return await _apiClient.get<PodListResponse>(
      ApiEndpoints.pods,
      queryParameters: queryParams,
      fromJson: (json) => PodListResponse.fromJson(json),
    );
  }

  // Search Pods
  Future<ApiResponse<PodListResponse>> searchPods({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    return await _apiClient.get<PodListResponse>(
      ApiEndpoints.podsSearch,
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) => PodListResponse.fromJson(json),
    );
  }

  // Get Pod Details
  Future<ApiResponse<Pod>> getPodDetails(String podId) async {
    return await _apiClient.get<Pod>(
      ApiEndpoints.podDetails(podId),
      fromJson: (json) => Pod.fromJson(json),
    );
  }

  // Get Pod Availability
  Future<ApiResponse<PodAvailability>> getPodAvailability({
    required String podId,
    required DateTime date,
  }) async {
    return await _apiClient.get<PodAvailability>(
      ApiEndpoints.podAvailability(podId),
      queryParameters: {
        'date': date.toIso8601String().split('T')[0],
      },
      fromJson: (json) => PodAvailability.fromJson(json),
    );
  }

  // Create Booking (Simple)
  Future<ApiResponse<PodBooking>> createSimpleBooking(
    SimpleBookingRequest request,
  ) async {
    return await _apiClient.post<PodBooking>(
      ApiEndpoints.podBookingsSimple,
      data: request.toJson(),
      fromJson: (json) => PodBooking.fromJson(json),
    );
  }

  // Create Booking (Full)
  Future<ApiResponse<PodBooking>> createBooking(
    BookingRequest request,
  ) async {
    return await _apiClient.post<PodBooking>(
      ApiEndpoints.podBookings,
      data: request.toJson(),
      fromJson: (json) => PodBooking.fromJson(json),
    );
  }

  // Get User Bookings
  Future<ApiResponse<BookingListResponse>> getUserBookings({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null) queryParams['status'] = status;

    return await _apiClient.get<BookingListResponse>(
      ApiEndpoints.podBookings,
      queryParameters: queryParams,
      fromJson: (json) => BookingListResponse.fromJson(json),
    );
  }

  // Get Booking Details
  Future<ApiResponse<PodBooking>> getBookingDetails(String bookingId) async {
    return await _apiClient.get<PodBooking>(
      ApiEndpoints.podBookingDetails(bookingId),
      fromJson: (json) => PodBooking.fromJson(json),
    );
  }

  // Cancel Booking
  Future<ApiResponse<Map<String, dynamic>>> cancelBooking(String bookingId) async {
    return await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.podBookingCancel(bookingId),
    );
  }

  // Upload Payment Proof
  Future<ApiResponse<Map<String, dynamic>>> uploadPaymentProof({
    required String bookingId,
    required File proofFile,
    String? notes,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'payment_proof': await MultipartFile.fromFile(
        proofFile.path,
        filename: proofFile.path.split('/').last,
      ),
      if (notes != null) 'notes': notes,
    });

    return await _apiClient.upload<Map<String, dynamic>>(
      ApiEndpoints.podBookingPaymentProof(bookingId),
      formData: formData,
      onSendProgress: onProgress,
    );
  }

  // Get Payment Status
  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus(String bookingId) async {
    return await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.paymentProofStatus(bookingId),
    );
  }

  // Helper methods for filtering
  Future<ApiResponse<PodListResponse>> getPodsByCity(String city, {int page = 1}) async {
    return await getPods(city: city, page: page);
  }

  Future<ApiResponse<PodListResponse>> getPodsByMall(String mall, {int page = 1}) async {
    return await getPods(mall: mall, page: page);
  }

  Future<ApiResponse<PodListResponse>> getPodsByPriceRange({
    double? minPrice,
    double? maxPrice,
    int page = 1,
  }) async {
    return await getPods(minPrice: minPrice, maxPrice: maxPrice, page: page);
  }

  // Helper methods for booking status
  Future<ApiResponse<BookingListResponse>> getPendingBookings({int page = 1}) async {
    return await getUserBookings(status: 'pending', page: page);
  }

  Future<ApiResponse<BookingListResponse>> getConfirmedBookings({int page = 1}) async {
    return await getUserBookings(status: 'confirmed', page: page);
  }

  Future<ApiResponse<BookingListResponse>> getCompletedBookings({int page = 1}) async {
    return await getUserBookings(status: 'completed', page: page);
  }

  // Utility methods
  bool canCancelBooking(PodBooking booking) {
    final status = BookingStatus.fromString(booking.status);
    if (status == BookingStatus.cancelled || status == BookingStatus.completed) {
      return false;
    }
    
    // Check if booking is within 24 hours
    final bookingDateTime = DateTime(
      booking.bookingDate.year,
      booking.bookingDate.month,
      booking.bookingDate.day,
    );
    final now = DateTime.now();
    final difference = bookingDateTime.difference(now);
    
    return difference.inHours > 24;
  }

  bool needsPaymentProof(PodBooking booking) {
    final paymentStatus = PaymentStatus.fromString(booking.paymentStatus ?? 'pending');
    return paymentStatus == PaymentStatus.pending && booking.paymentProofUrl == null;
  }

  bool isPaymentVerified(PodBooking booking) {
    final paymentStatus = PaymentStatus.fromString(booking.paymentStatus ?? 'pending');
    return paymentStatus == PaymentStatus.verified;
  }

  String getBookingStatusDisplay(PodBooking booking) {
    return BookingStatus.fromString(booking.status).displayName;
  }

  String getPaymentStatusDisplay(PodBooking booking) {
    return PaymentStatus.fromString(booking.paymentStatus ?? 'pending').displayName;
  }
}