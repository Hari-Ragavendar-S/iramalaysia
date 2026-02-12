import 'package:flutter/material.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }
}

class AdminBooking {
  final String id;
  final String userName;
  final String podName;
  final String mall;
  final String city;
  final DateTime bookingDate;
  final List<String> timeSlots;
  final double amount;
  final BookingStatus status;
  final String paymentScreenshot;
  final DateTime createdAt;

  AdminBooking({
    required this.id,
    required this.userName,
    required this.podName,
    required this.mall,
    required this.city,
    required this.bookingDate,
    required this.timeSlots,
    required this.amount,
    required this.status,
    required this.paymentScreenshot,
    required this.createdAt,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      podName: json['pod_name']?.toString() ?? '',
      mall: json['mall']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      bookingDate: DateTime.tryParse(json['booking_date']?.toString() ?? '') ?? DateTime.now(),
      timeSlots: List<String>.from(json['time_slots'] ?? []),
      amount: (json['amount'] ?? 0).toDouble(),
      status: _parseBookingStatus(json['status']?.toString()),
      paymentScreenshot: json['payment_screenshot']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static BookingStatus _parseBookingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'verified':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'rejected':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class AdminEvent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String venue;
  final String city;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double ticketPrice;
  final int maxCapacity;
  final bool isPublished;
  final DateTime createdAt;

  AdminEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.venue,
    required this.city,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.ticketPrice,
    required this.maxCapacity,
    required this.isPublished,
    required this.createdAt,
  });

  factory AdminEvent.fromJson(Map<String, dynamic> json) {
    return AdminEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      venue: json['venue']?.toString() ?? json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      eventDate: DateTime.tryParse(json['event_date']?.toString() ?? json['start_date']?.toString() ?? '') ?? DateTime.now(),
      startTime: _parseTimeOfDay(json['start_time']?.toString()),
      endTime: _parseTimeOfDay(json['end_time']?.toString()),
      ticketPrice: (json['ticket_price'] ?? 0).toDouble(),
      maxCapacity: json['max_capacity'] ?? json['max_attendees'] ?? 0,
      isPublished: json['is_published'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null) return const TimeOfDay(hour: 0, minute: 0);
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }
}

class AdminBusker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String idProofUrl;
  final int totalShows;
  final List<String> citiesPerformed;
  final DateTime joinedDate;
  final bool isActive;

  AdminBusker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.idProofUrl,
    required this.totalShows,
    required this.citiesPerformed,
    required this.joinedDate,
    required this.isActive,
  });

  factory AdminBusker.fromJson(Map<String, dynamic> json) {
    return AdminBusker(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      idProofUrl: json['id_proof_url']?.toString() ?? '',
      totalShows: json['total_shows'] ?? 0,
      citiesPerformed: List<String>.from(json['cities_performed'] ?? []),
      joinedDate: DateTime.tryParse(json['joined_date']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }
}

class AdminProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  AdminProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.isActive,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'admin',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class DashboardStats {
  final int totalUsers;
  final int totalBuskers;
  final int totalBookings;
  final int totalEvents;
  final double totalRevenue;
  final int activeUsers;
  final int activeBuskers;
  final int publishedEvents;

  DashboardStats({
    required this.totalUsers,
    required this.totalBuskers,
    required this.totalBookings,
    required this.totalEvents,
    required this.totalRevenue,
    required this.activeUsers,
    required this.activeBuskers,
    required this.publishedEvents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] ?? 0,
      totalBuskers: json['total_buskers'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalEvents: json['total_events'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      activeUsers: json['active_users'] ?? 0,
      activeBuskers: json['active_buskers'] ?? 0,
      publishedEvents: json['published_events'] ?? 0,
    );
  }
}

class AdminPod {
  final String id;
  final String name;
  final String description;
  final String location;
  final String city;
  final String mall;
  final double basePrice;
  final List<String> features;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  AdminPod({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.mall,
    required this.basePrice,
    required this.features,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminPod.fromJson(Map<String, dynamic> json) {
    return AdminPod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['address']?.toString() ?? json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      mall: json['mall']?.toString() ?? '',
      basePrice: (json['price_per_hour'] ?? json['base_price'] ?? 0).toDouble(),
      features: List<String>.from(json['amenities'] ?? json['features'] ?? []),
      imageUrl: json['images'] is List && (json['images'] as List).isNotEmpty 
          ? json['images'][0]?.toString() 
          : json['image_url']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}