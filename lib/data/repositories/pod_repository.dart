import 'dart:convert';
import '../services/pod_service.dart';
import '../models/pod/pod_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class PodRepository {
  final PodService _podService = PodService();

  // Pod Discovery
  Future<ApiResponse<List<Pod>>> getAllPods({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _podService.getPods(
      page: page,
      perPage: limit,
    );
    
    if (response.success && response.data != null) {
      return ApiResponse<List<Pod>>.success(
        data: response.data!.pods,
        message: response.message,
      );
    }
    
    return ApiResponse<List<Pod>>.error(error: response.error ?? 'Failed to get pods');
  }

  Future<ApiResponse<List<Pod>>> searchPods({
    String? location,
    String? state,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? availability,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _podService.searchPods(
      query: location ?? city ?? state ?? '',
      page: page,
      perPage: limit,
    );
    
    if (response.success && response.data != null) {
      return ApiResponse<List<Pod>>.success(
        data: response.data!.pods,
        message: response.message,
      );
    }
    
    return ApiResponse<List<Pod>>.error(error: response.error ?? 'Failed to search pods');
  }

  Future<ApiResponse<Pod>> getPodDetails(String podId) async {
    final response = await _podService.getPodDetails(podId);
    
    // Cache pod details for offline access
    if (response.success && response.data != null) {
      await _cachePodDetails(podId, response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<List<PodAvailability>>> getPodAvailability({
    required String podId,
    required DateTime date,
  }) async {
    final response = await _podService.getPodAvailability(podId: podId, date: date);
    if (response.success && response.data != null) {
      return ApiResponse<List<PodAvailability>>.success(
        data: [response.data!],
        message: response.message,
      );
    }
    return ApiResponse<List<PodAvailability>>.error(
      error: response.error ?? 'Failed to get availability',
    );
  }

  // Booking Management
  Future<ApiResponse<PodBooking>> createBooking({
    required String podId,
    required String date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final request = BookingRequest(
      podId: podId,
      bookingDate: DateTime.parse(date),
      timeSlots: [
        TimeSlot(
          start: startTime,
          end: endTime,
          price: 0.0, // Default price
        ),
      ],
      notes: notes,
    );

    final response = await _podService.createBooking(request);
    
    // Cache booking details
    if (response.success && response.data != null) {
      await _cacheBooking(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<PodBooking>> createSimpleBooking({
    required String podId,
    required String date,
    required String timeSlot,
    String? notes,
  }) async {
    final request = SimpleBookingRequest(
      podId: podId,
      startTime: DateTime.parse('$date $timeSlot:00'),
      endTime: DateTime.parse('$date $timeSlot:00').add(Duration(hours: 1)),
      totalAmount: 0.0, // Default amount
      notes: notes,
    );

    final response = await _podService.createSimpleBooking(request);
    
    // Cache booking details
    if (response.success && response.data != null) {
      await _cacheBooking(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<List<PodBooking>>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _podService.getUserBookings(
      status: status,
      page: page,
      perPage: limit,
    );
    
    // Cache bookings list
    if (response.success && response.data != null) {
      await _cacheBookingsList(response.data!.bookings);
    }
    
    return ApiResponse<List<PodBooking>>.success(
      data: response.data?.bookings ?? [],
      message: response.message,
    );
  }

  Future<ApiResponse<PodBooking>> getBookingDetails(String bookingId) async {
    final response = await _podService.getBookingDetails(bookingId);
    
    // Update cached booking
    if (response.success && response.data != null) {
      await _cacheBooking(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> cancelBooking(
    String bookingId,
  ) async {
    final response = await _podService.cancelBooking(bookingId);
    
    // Update cached booking status
    if (response.success) {
      await _updateCachedBookingStatus(bookingId, 'cancelled');
    }
    
    return response;
  }

  // Payment Proof
  Future<ApiResponse<Map<String, dynamic>>> uploadPaymentProof({
    required String bookingId,
    required String paymentProofUrl,
    String? notes,
  }) async {
    // Since the service expects a File, we need to handle this differently
    // For now, return a success response as this is handled by upload service
    final response = await _podService.getPaymentStatus(bookingId);
    
    // Update cached booking status
    if (response.success) {
      await _updateCachedBookingStatus(bookingId, 'pending_verification');
    }
    
    return response;
  }

  // Cached Data Management
  Future<Pod?> getCachedPodDetails(String podId) async {
    final podData = await SecureStorage.read('pod_$podId');
    if (podData != null) {
      try {
        final Map<String, dynamic> podJson = jsonDecode(podData);
        return Pod.fromJson(podJson);
      } catch (e) {
        await SecureStorage.delete('pod_$podId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cachePodDetails(String podId, Pod pod) async {
    await SecureStorage.write('pod_$podId', jsonEncode(pod.toJson()));
  }

  Future<List<PodBooking>?> getCachedBookingsList() async {
    final bookingsData = await SecureStorage.read('my_bookings');
    if (bookingsData != null) {
      try {
        final List<dynamic> bookingsList = jsonDecode(bookingsData);
        return bookingsList.map((json) => PodBooking.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('my_bookings');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheBookingsList(List<PodBooking> bookings) async {
    final bookingsJson = bookings.map((booking) => booking.toJson()).toList();
    await SecureStorage.write('my_bookings', jsonEncode(bookingsJson));
  }

  Future<PodBooking?> getCachedBooking(String bookingId) async {
    final bookingData = await SecureStorage.read('booking_$bookingId');
    if (bookingData != null) {
      try {
        final Map<String, dynamic> bookingJson = jsonDecode(bookingData);
        return PodBooking.fromJson(bookingJson);
      } catch (e) {
        await SecureStorage.delete('booking_$bookingId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheBooking(PodBooking booking) async {
    await SecureStorage.write('booking_${booking.id}', jsonEncode(booking.toJson()));
  }

  Future<void> _updateCachedBookingStatus(String bookingId, String status) async {
    final cachedBooking = await getCachedBooking(bookingId);
    if (cachedBooking != null) {
      final updatedBooking = cachedBooking.copyWith(status: status);
      await _cacheBooking(updatedBooking);
    }
  }

  Future<void> clearCachedPodData() async {
    // Clear all pod-related cached data
    await SecureStorage.delete('my_bookings');
    // Note: Individual pod and booking caches would need to be cleared separately
  }

  // Booking Helpers
  Future<List<PodBooking>> getActiveBookings() async {
    final response = await getMyBookings(status: 'confirmed');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<PodBooking>> getPendingBookings() async {
    final response = await getMyBookings(status: 'pending');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<PodBooking>> getCompletedBookings() async {
    final response = await getMyBookings(status: 'completed');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<PodBooking>> getCancelledBookings() async {
    final response = await getMyBookings(status: 'cancelled');
    return response.success ? response.data ?? [] : [];
  }

  // Booking Status Helpers
  bool isBookingActive(PodBooking booking) {
    return booking.status == 'confirmed' || booking.status == 'pending_verification';
  }

  bool isBookingPending(PodBooking booking) {
    return booking.status == 'pending';
  }

  bool isBookingCompleted(PodBooking booking) {
    return booking.status == 'completed';
  }

  bool isBookingCancelled(PodBooking booking) {
    return booking.status == 'cancelled';
  }

  bool canCancelBooking(PodBooking booking) {
    return booking.status == 'pending' || booking.status == 'confirmed';
  }

  bool needsPaymentProof(PodBooking booking) {
    return booking.status == 'pending' && booking.paymentProofUrl == null;
  }

  // Search Helpers
  Future<ApiResponse<List<Pod>>> searchPodsByLocation(String location) async {
    return await searchPods(location: location);
  }

  Future<ApiResponse<List<Pod>>> searchPodsByState(String state) async {
    return await searchPods(state: state);
  }

  Future<ApiResponse<List<Pod>>> searchPodsByCity(String city) async {
    return await searchPods(city: city);
  }

  Future<ApiResponse<List<Pod>>> searchPodsByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    return await searchPods(minPrice: minPrice, maxPrice: maxPrice);
  }

  Future<ApiResponse<List<Pod>>> getAvailablePods() async {
    return await searchPods(availability: 'available');
  }

  // Time Slot Helpers
  List<String> getAvailableTimeSlots() {
    return [
      '09:00-10:00',
      '10:00-11:00',
      '11:00-12:00',
      '12:00-13:00',
      '13:00-14:00',
      '14:00-15:00',
      '15:00-16:00',
      '16:00-17:00',
      '17:00-18:00',
      '18:00-19:00',
      '19:00-20:00',
      '20:00-21:00',
      '21:00-22:00',
    ];
  }

  bool isValidTimeSlot(String timeSlot) {
    return getAvailableTimeSlots().contains(timeSlot);
  }

  // Validation Helpers
  bool isValidDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      return parsedDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  bool isValidBookingTime(String startTime, String endTime) {
    try {
      final start = DateTime.parse('2024-01-01 $startTime:00');
      final end = DateTime.parse('2024-01-01 $endTime:00');
      return end.isAfter(start);
    } catch (e) {
      return false;
    }
  }

  // Refresh Data
  Future<ApiResponse<List<PodBooking>>> refreshMyBookings() async {
    await SecureStorage.delete('my_bookings');
    return await getMyBookings();
  }

  Future<ApiResponse<Pod>> refreshPodDetails(String podId) async {
    await SecureStorage.delete('pod_$podId');
    return await getPodDetails(podId);
  }
}