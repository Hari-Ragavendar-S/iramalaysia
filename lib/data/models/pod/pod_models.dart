class Pod {
  final String id;
  final String name;
  final String? description;
  final String mall;
  final String city;
  final String address;
  final List<String> images;
  final List<String> amenities;
  final double pricePerHour;
  final int? capacity;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pod({
    required this.id,
    required this.name,
    this.description,
    required this.mall,
    required this.city,
    required this.address,
    required this.images,
    required this.amenities,
    required this.pricePerHour,
    this.capacity,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      mall: json['mall'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      pricePerHour: (json['price_per_hour'] ?? 0.0).toDouble(),
      capacity: json['capacity'],
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mall': mall,
      'city': city,
      'address': address,
      'images': images,
      'amenities': amenities,
      'price_per_hour': pricePerHour,
      'capacity': capacity,
      'is_active': isActive,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PodListResponse {
  final List<Pod> pods;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  PodListResponse({
    required this.pods,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory PodListResponse.fromJson(Map<String, dynamic> json) {
    final podsJson = json['pods'] ?? [];
    final pods = (podsJson as List)
        .map((pod) => Pod.fromJson(pod))
        .toList();

    return PodListResponse(
      pods: pods,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

class TimeSlot {
  final String start;
  final String end;
  final double price;

  TimeSlot({
    required this.start,
    required this.end,
    required this.price,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'price': price,
    };
  }
}

class PodAvailability {
  final String date;
  final List<TimeSlot> availableSlots;
  final List<TimeSlot> bookedSlots;

  PodAvailability({
    required this.date,
    required this.availableSlots,
    required this.bookedSlots,
  });

  factory PodAvailability.fromJson(Map<String, dynamic> json) {
    final availableSlotsJson = json['available_slots'] ?? [];
    final bookedSlotsJson = json['booked_slots'] ?? [];

    return PodAvailability(
      date: json['date'] ?? '',
      availableSlots: (availableSlotsJson as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      bookedSlots: (bookedSlotsJson as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }
}

class PodBooking {
  final String id;
  final String bookingReference;
  final String userId;
  final String podId;
  final String? locationId;
  final String? mallId;
  final String? mallName;
  final String? state;
  final String? city;
  final String? fullAddress;
  final String? buskingAreaDescription;
  final DateTime bookingDate;
  final List<TimeSlot> timeSlots;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final String? paymentReference;
  final String? paymentScreenshotUrl;
  final String? paymentProofUrl;
  final String? paymentStatus;
  final DateTime? paymentUploadedAt;
  final DateTime? paymentVerifiedAt;
  final String? paymentVerifiedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pod? pod;

  PodBooking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.podId,
    this.locationId,
    this.mallId,
    this.mallName,
    this.state,
    this.city,
    this.fullAddress,
    this.buskingAreaDescription,
    required this.bookingDate,
    required this.timeSlots,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    this.paymentScreenshotUrl,
    this.paymentProofUrl,
    this.paymentStatus,
    this.paymentUploadedAt,
    this.paymentVerifiedAt,
    this.paymentVerifiedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.pod,
  });

  factory PodBooking.fromJson(Map<String, dynamic> json) {
    final timeSlotsJson = json['time_slots'] ?? [];
    final timeSlots = (timeSlotsJson as List)
        .map((slot) => TimeSlot.fromJson(slot))
        .toList();

    return PodBooking(
      id: json['id'] ?? '',
      bookingReference: json['booking_reference'] ?? '',
      userId: json['user_id'] ?? '',
      podId: json['pod_id'] ?? '',
      locationId: json['location_id'],
      mallId: json['mall_id'],
      mallName: json['mall_name'],
      state: json['state'],
      city: json['city'],
      fullAddress: json['full_address'],
      buskingAreaDescription: json['busking_area_description'],
      bookingDate: DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      timeSlots: timeSlots,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paymentScreenshotUrl: json['payment_screenshot_url'],
      paymentProofUrl: json['payment_proof_url'],
      paymentStatus: json['payment_status'],
      paymentUploadedAt: json['payment_uploaded_at'] != null
          ? DateTime.tryParse(json['payment_uploaded_at'])
          : null,
      paymentVerifiedAt: json['payment_verified_at'] != null
          ? DateTime.tryParse(json['payment_verified_at'])
          : null,
      paymentVerifiedBy: json['payment_verified_by'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      pod: json['pod'] != null ? Pod.fromJson(json['pod']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'user_id': userId,
      'pod_id': podId,
      'location_id': locationId,
      'mall_id': mallId,
      'mall_name': mallName,
      'state': state,
      'city': city,
      'full_address': fullAddress,
      'busking_area_description': buskingAreaDescription,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'time_slots': timeSlots.map((slot) => slot.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_screenshot_url': paymentScreenshotUrl,
      'payment_proof_url': paymentProofUrl,
      'payment_status': paymentStatus,
      'payment_uploaded_at': paymentUploadedAt?.toIso8601String(),
      'payment_verified_at': paymentVerifiedAt?.toIso8601String(),
      'payment_verified_by': paymentVerifiedBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pod': pod?.toJson(),
    };
  }

  PodBooking copyWith({String? status}) {
    return PodBooking(
      id: id,
      bookingReference: bookingReference,
      userId: userId,
      podId: podId,
      locationId: locationId,
      mallId: mallId,
      mallName: mallName,
      state: state,
      city: city,
      fullAddress: fullAddress,
      buskingAreaDescription: buskingAreaDescription,
      bookingDate: bookingDate,
      timeSlots: timeSlots,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      paymentScreenshotUrl: paymentScreenshotUrl,
      paymentProofUrl: paymentProofUrl,
      paymentStatus: paymentStatus,
      paymentUploadedAt: paymentUploadedAt,
      paymentVerifiedAt: paymentVerifiedAt,
      paymentVerifiedBy: paymentVerifiedBy,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pod: pod,
    );
  }
}

class BookingListResponse {
  final List<PodBooking> bookings;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  BookingListResponse({
    required this.bookings,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    final bookingsJson = json['bookings'] ?? [];
    final bookings = (bookingsJson as List)
        .map((booking) => PodBooking.fromJson(booking))
        .toList();

    return BookingListResponse(
      bookings: bookings,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

class SimpleBookingRequest {
  final String podId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final String? notes;

  SimpleBookingRequest({
    required this.podId,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'pod_id': podId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_amount': totalAmount,
      'notes': notes,
    };
  }
}

class BookingRequest {
  final String podId;
  final String? locationId;
  final DateTime bookingDate;
  final List<TimeSlot> timeSlots;
  final String paymentMethod;
  final String? notes;

  BookingRequest({
    required this.podId,
    this.locationId,
    required this.bookingDate,
    required this.timeSlots,
    this.paymentMethod = 'upi',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'pod_id': podId,
      'location_id': locationId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'time_slots': timeSlots.map((slot) => slot.toJson()).toList(),
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  verified,
  rejected;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return PaymentStatus.verified;
      case 'rejected':
        return PaymentStatus.rejected;
      default:
        return PaymentStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.verified:
        return 'verified';
      case PaymentStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.verified:
        return 'Verified';
      case PaymentStatus.rejected:
        return 'Rejected';
    }
  }
}

// Request Classes
class CreatePodBookingRequest {
  final String podId;
  final DateTime bookingDate;
  final List<String> timeSlots;
  final String? notes;

  CreatePodBookingRequest({
    required this.podId,
    required this.bookingDate,
    required this.timeSlots,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'pod_id': podId,
      'booking_date': bookingDate.toIso8601String(),
      'time_slots': timeSlots,
      'notes': notes,
    };
  }
}

class CreateSimplePodBookingRequest {
  final String podId;
  final DateTime bookingDate;
  final List<String> timeSlots;

  CreateSimplePodBookingRequest({
    required this.podId,
    required this.bookingDate,
    required this.timeSlots,
  });

  Map<String, dynamic> toJson() {
    return {
      'pod_id': podId,
      'booking_date': bookingDate.toIso8601String(),
      'time_slots': timeSlots,
    };
  }
}

class UploadPaymentProofRequest {
  final String bookingId;
  final String filePath;
  final String? notes;

  UploadPaymentProofRequest({
    required this.bookingId,
    required this.filePath,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'file_path': filePath,
      'notes': notes,
    };
  }
}