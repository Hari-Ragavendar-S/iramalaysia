import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/event/event_models.dart';

class EventService {
  final ApiClient _apiClient = ApiClient.instance;

  // Get Events List
  Future<ApiResponse<EventListResponse>> getEvents({
    int page = 1,
    int perPage = 20,
    String? city,
    String? category,
    DateTime? fromDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (city != null) queryParams['city'] = city;
    if (category != null) queryParams['category'] = category;
    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
    }

    return await _apiClient.get<EventListResponse>(
      ApiEndpoints.events,
      queryParameters: queryParams,
      fromJson: (json) => EventListResponse.fromJson(json),
    );
  }

  // Search Events
  Future<ApiResponse<EventListResponse>> searchEvents({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    return await _apiClient.get<EventListResponse>(
      ApiEndpoints.eventsSearch,
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) => EventListResponse.fromJson(json),
    );
  }

  // Get Event Details
  Future<ApiResponse<Event>> getEventDetails(String eventId) async {
    return await _apiClient.get<Event>(
      ApiEndpoints.eventDetails(eventId),
      fromJson: (json) => Event.fromJson(json),
    );
  }

  // Book Event
  Future<ApiResponse<Map<String, dynamic>>> bookEvent({
    required String eventId,
    int ticketsCount = 1,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.eventBook(eventId),
      data: EventBookingRequest(ticketsCount: ticketsCount).toJson(),
    );
  }

  // Get My Event Bookings
  Future<ApiResponse<EventBookingListResponse>> getMyBookings({
    int page = 1,
    int perPage = 20,
  }) async {
    return await _apiClient.get<EventBookingListResponse>(
      ApiEndpoints.eventsMyBookings,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) => EventBookingListResponse.fromJson(json),
    );
  }

  // Helper methods for filtering
  Future<ApiResponse<EventListResponse>> getEventsByCity(String city, {int page = 1}) async {
    return await getEvents(city: city, page: page);
  }

  Future<ApiResponse<EventListResponse>> getEventsByCategory(String category, {int page = 1}) async {
    return await getEvents(category: category, page: page);
  }

  Future<ApiResponse<EventListResponse>> getUpcomingEvents({int page = 1}) async {
    return await getEvents(fromDate: DateTime.now(), page: page);
  }

  Future<ApiResponse<EventListResponse>> getTodayEvents({int page = 1}) async {
    final today = DateTime.now();
    return await getEvents(fromDate: today, page: page);
  }

  Future<ApiResponse<EventListResponse>> getThisWeekEvents({int page = 1}) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return await getEvents(fromDate: startOfWeek, page: page);
  }

  Future<ApiResponse<EventListResponse>> getThisMonthEvents({int page = 1}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return await getEvents(fromDate: startOfMonth, page: page);
  }

  // Helper methods for booking status
  Future<ApiResponse<EventBookingListResponse>> getPendingBookings({int page = 1}) async {
    final response = await getMyBookings(page: page);
    if (response.success && response.data != null) {
      final filteredBookings = response.data!.bookings
          .where((booking) => booking.status == 'pending')
          .toList();
      
      return ApiResponse.success(
        data: EventBookingListResponse(
          bookings: filteredBookings,
          total: filteredBookings.length,
          page: page,
          perPage: response.data!.perPage,
          pages: (filteredBookings.length / response.data!.perPage).ceil(),
        ),
      );
    }
    return response;
  }

  Future<ApiResponse<EventBookingListResponse>> getConfirmedBookings({int page = 1}) async {
    final response = await getMyBookings(page: page);
    if (response.success && response.data != null) {
      final filteredBookings = response.data!.bookings
          .where((booking) => booking.status == 'confirmed')
          .toList();
      
      return ApiResponse.success(
        data: EventBookingListResponse(
          bookings: filteredBookings,
          total: filteredBookings.length,
          page: page,
          perPage: response.data!.perPage,
          pages: (filteredBookings.length / response.data!.perPage).ceil(),
        ),
      );
    }
    return response;
  }

  // Utility methods
  bool canBookEvent(Event event) {
    return event.isPublished && 
           event.hasAvailableTickets && 
           event.eventDate.isAfter(DateTime.now());
  }

  bool isEventToday(Event event) {
    final today = DateTime.now();
    return event.eventDate.year == today.year &&
           event.eventDate.month == today.month &&
           event.eventDate.day == today.day;
  }

  bool isEventUpcoming(Event event) {
    return event.eventDate.isAfter(DateTime.now());
  }

  bool isEventPast(Event event) {
    return event.eventDate.isBefore(DateTime.now());
  }

  String getEventStatusDisplay(Event event) {
    if (isEventPast(event)) return 'Past';
    if (isEventToday(event)) return 'Today';
    if (isEventUpcoming(event)) return 'Upcoming';
    return 'Unknown';
  }

  String getBookingStatusDisplay(EventBooking booking) {
    return EventBookingStatus.fromString(booking.status).displayName;
  }

  Duration getTimeUntilEvent(Event event) {
    return event.eventDate.difference(DateTime.now());
  }

  String getTimeUntilEventDisplay(Event event) {
    final duration = getTimeUntilEvent(event);
    if (duration.isNegative) return 'Event has passed';
    
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    } else {
      return 'Starting soon';
    }
  }
}