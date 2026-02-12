import '../services/event_service.dart';
import '../models/event/event_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class EventRepository {
  final EventService _eventService = EventService();

  // Event Discovery
  Future<ApiResponse<List<Event>>> getAllEvents({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _eventService.getAllEvents(page: page, limit: limit);
    
    // Cache events list
    if (response.success && response.data != null) {
      await _cacheEventsList(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<List<Event>>> searchEvents({
    String? query,
    String? location,
    String? category,
    String? dateFrom,
    String? dateTo,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    return await _eventService.searchEvents(
      query: query,
      location: location,
      category: category,
      dateFrom: dateFrom,
      dateTo: dateTo,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Event>> getEventDetails(String eventId) async {
    final response = await _eventService.getEventDetails(eventId);
    
    // Cache event details
    if (response.success && response.data != null) {
      await _cacheEventDetails(eventId, response.data!);
    }
    
    return response;
  }

  // Event Booking
  Future<ApiResponse<EventBooking>> bookEvent({
    required String eventId,
    required int quantity,
    String? notes,
  }) async {
    final request = BookEventRequest(
      eventId: eventId,
      quantity: quantity,
      notes: notes,
    );

    final response = await _eventService.bookEvent(request);
    
    // Cache booking details
    if (response.success && response.data != null) {
      await _cacheEventBooking(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<List<EventBooking>>> getMyEventBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _eventService.getMyEventBookings(
      status: status,
      page: page,
      limit: limit,
    );
    
    // Cache bookings list
    if (response.success && response.data != null) {
      await _cacheEventBookingsList(response.data!);
    }
    
    return response;
  }

  // Cached Data Management
  Future<List<Event>?> getCachedEventsList() async {
    final eventsData = await SecureStorage.get('events_list');
    if (eventsData != null) {
      try {
        final List<dynamic> eventsList = eventsData;
        return eventsList.map((json) => Event.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('events_list');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheEventsList(List<Event> events) async {
    final eventsJson = events.map((event) => event.toJson()).toList();
    await SecureStorage.save('events_list', eventsJson);
  }

  Future<Event?> getCachedEventDetails(String eventId) async {
    final eventData = await SecureStorage.get('event_$eventId');
    if (eventData != null) {
      try {
        return Event.fromJson(eventData);
      } catch (e) {
        await SecureStorage.delete('event_$eventId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheEventDetails(String eventId, Event event) async {
    await SecureStorage.save('event_$eventId', event.toJson());
  }

  Future<List<EventBooking>?> getCachedEventBookingsList() async {
    final bookingsData = await SecureStorage.get('event_bookings');
    if (bookingsData != null) {
      try {
        final List<dynamic> bookingsList = bookingsData;
        return bookingsList.map((json) => EventBooking.fromJson(json)).toList();
      } catch (e) {
        await SecureStorage.delete('event_bookings');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheEventBookingsList(List<EventBooking> bookings) async {
    final bookingsJson = bookings.map((booking) => booking.toJson()).toList();
    await SecureStorage.save('event_bookings', bookingsJson);
  }

  Future<EventBooking?> getCachedEventBooking(String bookingId) async {
    final bookingData = await SecureStorage.get('event_booking_$bookingId');
    if (bookingData != null) {
      try {
        return EventBooking.fromJson(bookingData);
      } catch (e) {
        await SecureStorage.delete('event_booking_$bookingId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheEventBooking(EventBooking booking) async {
    await SecureStorage.save('event_booking_${booking.id}', booking.toJson());
  }

  Future<void> clearCachedEventData() async {
    await SecureStorage.delete('events_list');
    await SecureStorage.delete('event_bookings');
  }

  // Event Helpers
  Future<List<Event>> getUpcomingEvents() async {
    final now = DateTime.now();
    final response = await searchEvents(
      dateFrom: now.toIso8601String().split('T')[0],
    );
    return response.success ? response.data ?? [] : [];
  }

  Future<List<Event>> getFeaturedEvents() async {
    // Assuming featured events are those with high ratings or special flags
    final response = await getAllEvents(limit: 10);
    return response.success ? response.data ?? [] : [];
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    final response = await searchEvents(category: category);
    return response.success ? response.data ?? [] : [];
  }

  Future<List<Event>> getEventsByLocation(String location) async {
    final response = await searchEvents(location: location);
    return response.success ? response.data ?? [] : [];
  }

  // Event Categories
  List<String> getEventCategories() {
    return [
      'Music',
      'Dance',
      'Comedy',
      'Theater',
      'Art',
      'Cultural',
      'Festival',
      'Workshop',
      'Competition',
      'Community',
      'Other',
    ];
  }

  // Booking Helpers
  Future<List<EventBooking>> getActiveEventBookings() async {
    final response = await getMyEventBookings(status: 'confirmed');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<EventBooking>> getPendingEventBookings() async {
    final response = await getMyEventBookings(status: 'pending');
    return response.success ? response.data ?? [] : [];
  }

  Future<List<EventBooking>> getCompletedEventBookings() async {
    final response = await getMyEventBookings(status: 'completed');
    return response.success ? response.data ?? [] : [];
  }

  // Event Status Helpers
  bool isEventUpcoming(Event event) {
    if (event.startDate == null) return false;
    final eventDate = DateTime.parse(event.startDate!);
    return eventDate.isAfter(DateTime.now());
  }

  bool isEventOngoing(Event event) {
    if (event.startDate == null || event.endDate == null) return false;
    final now = DateTime.now();
    final startDate = DateTime.parse(event.startDate!);
    final endDate = DateTime.parse(event.endDate!);
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool isEventCompleted(Event event) {
    if (event.endDate == null) return false;
    final endDate = DateTime.parse(event.endDate!);
    return endDate.isBefore(DateTime.now());
  }

  bool isEventBookable(Event event) {
    return isEventUpcoming(event) && 
           event.availableTickets != null && 
           event.availableTickets! > 0;
  }

  // Booking Status Helpers
  bool isBookingActive(EventBooking booking) {
    return booking.status == 'confirmed';
  }

  bool isBookingPending(EventBooking booking) {
    return booking.status == 'pending';
  }

  bool isBookingCompleted(EventBooking booking) {
    return booking.status == 'completed';
  }

  bool isBookingCancelled(EventBooking booking) {
    return booking.status == 'cancelled';
  }

  // Search Helpers
  Future<ApiResponse<List<Event>>> searchEventsByName(String query) async {
    return await searchEvents(query: query);
  }

  Future<ApiResponse<List<Event>>> getEventsByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    return await searchEvents(minPrice: minPrice, maxPrice: maxPrice);
  }

  Future<ApiResponse<List<Event>>> getFreeEvents() async {
    return await searchEvents(minPrice: 0, maxPrice: 0);
  }

  Future<ApiResponse<List<Event>>> getEventsThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await searchEvents(
      dateFrom: startOfWeek.toIso8601String().split('T')[0],
      dateTo: endOfWeek.toIso8601String().split('T')[0],
    );
  }

  Future<ApiResponse<List<Event>>> getEventsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return await searchEvents(
      dateFrom: startOfMonth.toIso8601String().split('T')[0],
      dateTo: endOfMonth.toIso8601String().split('T')[0],
    );
  }

  // Validation Helpers
  bool isValidEventDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return parsedDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool isValidQuantity(int quantity, Event event) {
    return quantity > 0 && 
           (event.availableTickets == null || quantity <= event.availableTickets!);
  }

  // Refresh Data
  Future<ApiResponse<List<Event>>> refreshEventsList() async {
    await SecureStorage.delete('events_list');
    return await getAllEvents();
  }

  Future<ApiResponse<Event>> refreshEventDetails(String eventId) async {
    await SecureStorage.delete('event_$eventId');
    return await getEventDetails(eventId);
  }

  Future<ApiResponse<List<EventBooking>>> refreshMyEventBookings() async {
    await SecureStorage.delete('event_bookings');
    return await getMyEventBookings();
  }

  // Favorites (if implemented in backend)
  Future<List<Event>> getFavoriteEvents() async {
    // This would require a favorites endpoint in the backend
    // For now, return cached events that might be marked as favorites
    final cachedEvents = await getCachedEventsList();
    return cachedEvents?.where((event) => event.isFavorite == true).toList() ?? [];
  }
}