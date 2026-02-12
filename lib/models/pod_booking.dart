import 'package:flutter/material.dart';

class PodBooking {
  final String id;
  final String bookingReference;
  final String podId;
  final String? locationId;
  final String? mallId;
  final String? mallName;
  final String? state;
  final String? city;
  final String? fullAddress;
  final String? buskingAreaDescription;
  final String podName;
  final String mall;
  final String podCity;
  final String podImageUrl;
  final DateTime bookingDate;
  final List<TimeSlot> timeSlots;
  final double totalAmount;
  final String? paymentReceiptPath;
  final String? paymentProofUrl;
  final String? paymentStatus;
  final DateTime? paymentUploadedAt;
  final DateTime? paymentVerifiedAt;
  final BookingStatus status;
  final DateTime createdAt;

  PodBooking({
    required this.id,
    required this.bookingReference,
    required this.podId,
    this.locationId,
    this.mallId,
    this.mallName,
    this.state,
    this.city,
    this.fullAddress,
    this.buskingAreaDescription,
    required this.podName,
    required this.mall,
    required this.podCity,
    required this.podImageUrl,
    required this.bookingDate,
    required this.timeSlots,
    required this.totalAmount,
    this.paymentReceiptPath,
    this.paymentProofUrl,
    this.paymentStatus,
    this.paymentUploadedAt,
    this.paymentVerifiedAt,
    required this.status,
    required this.createdAt,
  });

  // Get display location name (prioritize location data over pod data)
  String get displayLocationName => mallName ?? podName;
  String get displayMall => mallName ?? mall;
  String get displayCity => city ?? podCity;
  String get displayAddress => fullAddress ?? '';
  String get displayBuskingArea => buskingAreaDescription ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'pod_id': podId,
      'location_id': locationId,
      'mall_id': mallId,
      'mall_name': mallName,
      'state': state,
      'city': city,
      'full_address': fullAddress,
      'busking_area_description': buskingAreaDescription,
      'podId': podId, // Keep for backward compatibility
      'podName': podName,
      'mall': mall,
      'city': podCity, // Keep original field name for backward compatibility
      'podImageUrl': podImageUrl,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentReceiptPath': paymentReceiptPath,
      'payment_proof_url': paymentProofUrl,
      'payment_status': paymentStatus,
      'payment_uploaded_at': paymentUploadedAt?.toIso8601String(),
      'payment_verified_at': paymentVerifiedAt?.toIso8601String(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PodBooking.fromJson(Map<String, dynamic> json) {
    return PodBooking(
      id: json['id'],
      bookingReference: json['booking_reference'] ?? json['id'],
      podId: json['pod_id'] ?? json['podId'],
      locationId: json['location_id'],
      mallId: json['mall_id'],
      mallName: json['mall_name'],
      state: json['state'],
      city: json['city'],
      fullAddress: json['full_address'],
      buskingAreaDescription: json['busking_area_description'],
      podName: json['podName'] ?? json['pod']?['name'] ?? 'Unknown Pod',
      mall: json['mall'] ?? json['pod']?['mall'] ?? 'Unknown Mall',
      podCity: json['podCity'] ?? json['pod']?['city'] ?? json['city'] ?? 'Unknown City',
      podImageUrl: json['podImageUrl'] ?? json['pod']?['images']?[0] ?? 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80',
      bookingDate: DateTime.parse(json['bookingDate'] ?? json['booking_date']),
      timeSlots: (json['timeSlots'] ?? json['time_slots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      totalAmount: (json['totalAmount'] ?? json['total_amount']).toDouble(),
      paymentReceiptPath: json['paymentReceiptPath'],
      paymentProofUrl: json['payment_proof_url'],
      paymentStatus: json['payment_status'],
      paymentUploadedAt: json['payment_uploaded_at'] != null 
          ? DateTime.parse(json['payment_uploaded_at']) 
          : null,
      paymentVerifiedAt: json['payment_verified_at'] != null 
          ? DateTime.parse(json['payment_verified_at']) 
          : null,
      status: _parseBookingStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  static BookingStatus _parseBookingStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'pending':
          return BookingStatus.pending;
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
    return BookingStatus.values.firstWhere(
      (s) => s.toString() == status.toString(),
      orElse: () => BookingStatus.pending,
    );
  }
}

class TimeSlot {
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double price;
  final SlotStatus status;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
  });

  String get displayTime {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get time => displayTime;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'price': price,
      'status': status.toString(),
    };
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      startTime: _parseTimeOfDay(json['start_time'] ?? json['startTime']),
      endTime: _parseTimeOfDay(json['end_time'] ?? json['endTime']),
      price: (json['price'] ?? 0.0).toDouble(),
      status: _parseSlotStatus(json['status']),
    );
  }

  static TimeOfDay _parseTimeOfDay(dynamic timeValue) {
    if (timeValue == null) return const TimeOfDay(hour: 0, minute: 0);
    
    try {
      final timeStr = timeValue.toString();
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  static SlotStatus _parseSlotStatus(dynamic status) {
    if (status == null) return SlotStatus.available;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'available':
        return SlotStatus.available;
      case 'selected':
        return SlotStatus.selected;
      case 'booked':
      case 'occupied':
        return SlotStatus.booked;
      default:
        return SlotStatus.available;
    }
  }
}

class AvailablePod {
  final String id;
  final String name;
  final String mall;
  final String city;
  final String imageUrl;
  final String description;
  final List<String> features;
  final double basePrice;
  final PodStatus status;
  final double rating;
  final int reviewCount;
  final String? location;
  final bool isActive;
  final List<String>? images; // Add images property

  AvailablePod({
    required this.id,
    required this.name,
    required this.mall,
    required this.city,
    required this.imageUrl,
    required this.description,
    required this.features,
    required this.basePrice,
    required this.status,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.location,
    this.isActive = true,
    this.images, // Add images parameter
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mall': mall,
      'city': city,
      'image_url': imageUrl,
      'description': description,
      'features': features,
      'base_price': basePrice,
      'status': status.toString(),
      'rating': rating,
      'review_count': reviewCount,
      'location': location,
      'is_active': isActive,
    };
  }

  factory AvailablePod.fromJson(Map<String, dynamic> json) {
    return AvailablePod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mall: json['mall']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? 
                json['imageUrl']?.toString() ?? 
                'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80',
      description: json['description']?.toString() ?? '',
      features: List<String>.from(json['features'] ?? []),
      basePrice: (json['base_price'] ?? json['basePrice'] ?? 100.0).toDouble(),
      status: _parseStatus(json['status']),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      location: json['location']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  static PodStatus _parseStatus(dynamic status) {
    if (status == null) return PodStatus.available;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'available':
        return PodStatus.available;
      case 'busy':
      case 'occupied':
        return PodStatus.busy;
      case 'maintenance':
        return PodStatus.maintenance;
      default:
        return PodStatus.available;
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

enum SlotStatus {
  available,
  selected,
  booked,
}

enum PodStatus {
  available,
  busy,
  maintenance,
}

extension BookingStatusExtension on BookingStatus {
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

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}

extension PodStatusExtension on PodStatus {
  String get displayName {
    switch (this) {
      case PodStatus.available:
        return 'Available';
      case PodStatus.busy:
        return 'Busy';
      case PodStatus.maintenance:
        return 'Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case PodStatus.available:
        return Colors.green;
      case PodStatus.busy:
        return Colors.red;
      case PodStatus.maintenance:
        return Colors.orange;
    }
  }
}