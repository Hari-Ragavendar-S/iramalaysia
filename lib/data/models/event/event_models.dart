class Event {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String venue;
  final String city;
  final String? address;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final double? ticketPrice;
  final int? maxCapacity;
  final int currentBookings;
  final String? category;
  final bool isPublished;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.venue,
    required this.city,
    this.address,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.ticketPrice,
    this.maxCapacity,
    required this.currentBookings,
    this.category,
    required this.isPublished,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      venue: json['venue'] ?? '',
      city: json['city'] ?? '',
      address: json['address'],
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      ticketPrice: json['ticket_price']?.toDouble(),
      maxCapacity: json['max_capacity'],
      currentBookings: json['current_bookings'] ?? 0,
      category: json['category'],
      isPublished: json['is_published'] ?? false,
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'venue': venue,
      'city': city,
      'address': address,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'ticket_price': ticketPrice,
      'max_capacity': maxCapacity,
      'current_bookings': currentBookings,
      'category': category,
      'is_published': isPublished,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasAvailableTickets {
    if (maxCapacity == null) return true;
    return currentBookings < maxCapacity!;
  }

  int get availableTickets {
    if (maxCapacity == null) return 999;
    return maxCapacity! - currentBookings;
  }
}

class EventListResponse {
  final List<Event> events;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  EventListResponse({
    required this.events,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'] ?? [];
    final events = (eventsJson as List)
        .map((event) => Event.fromJson(event))
        .toList();

    return EventListResponse(
      events: events,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

class EventBooking {
  final String id;
  final String bookingReference;
  final String userId;
  final String eventId;
  final int ticketsCount;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String? paymentReference;
  final String? paymentScreenshotUrl;
  final DateTime? paymentVerifiedAt;
  final String? paymentVerifiedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Event? event;

  EventBooking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.eventId,
    required this.ticketsCount,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    this.paymentScreenshotUrl,
    this.paymentVerifiedAt,
    this.paymentVerifiedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.event,
  });

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    return EventBooking(
      id: json['id'] ?? '',
      bookingReference: json['booking_reference'] ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      ticketsCount: json['tickets_count'] ?? 1,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paymentScreenshotUrl: json['payment_screenshot_url'],
      paymentVerifiedAt: json['payment_verified_at'] != null
          ? DateTime.tryParse(json['payment_verified_at'])
          : null,
      paymentVerifiedBy: json['payment_verified_by'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'user_id': userId,
      'event_id': eventId,
      'tickets_count': ticketsCount,
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_screenshot_url': paymentScreenshotUrl,
      'payment_verified_at': paymentVerifiedAt?.toIso8601String(),
      'payment_verified_by': paymentVerifiedBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'event': event?.toJson(),
    };
  }
}

class EventBookingRequest {
  final int ticketsCount;

  EventBookingRequest({
    this.ticketsCount = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'tickets_count': ticketsCount,
    };
  }
}

class EventBookingListResponse {
  final List<EventBooking> bookings;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  EventBookingListResponse({
    required this.bookings,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory EventBookingListResponse.fromJson(Map<String, dynamic> json) {
    final bookingsJson = json['bookings'] ?? [];
    final bookings = (bookingsJson as List)
        .map((booking) => EventBooking.fromJson(booking))
        .toList();

    return EventBookingListResponse(
      bookings: bookings,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

enum EventBookingStatus {
  pending,
  confirmed,
  cancelled;

  static EventBookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return EventBookingStatus.confirmed;
      case 'cancelled':
        return EventBookingStatus.cancelled;
      default:
        return EventBookingStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case EventBookingStatus.pending:
        return 'pending';
      case EventBookingStatus.confirmed:
        return 'confirmed';
      case EventBookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case EventBookingStatus.pending:
        return 'Pending';
      case EventBookingStatus.confirmed:
        return 'Confirmed';
      case EventBookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}