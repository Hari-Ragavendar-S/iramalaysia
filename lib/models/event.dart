import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String venue;
  final String city;
  final DateTime eventDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double ticketPrice;
  final int maxCapacity;
  final int currentBookings;
  final bool isPublished;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.venue,
    required this.city,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.ticketPrice,
    required this.maxCapacity,
    this.currentBookings = 0,
    this.isPublished = false,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Legacy getters for backward compatibility
  String get name => title;
  String get date => '${eventDate.day}/${eventDate.month}/${eventDate.year}';
  String get time => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  String get organizer => 'Irama1Asia';
  List<String> get galleryImages => imageUrl != null ? [imageUrl!] : [];

  bool get isAvailable => currentBookings < maxCapacity;
  int get availableTickets => maxCapacity - currentBookings;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'venue': venue,
      'city': city,
      'event_date': eventDate.toIso8601String(),
      'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'ticket_price': ticketPrice,
      'max_capacity': maxCapacity,
      'current_bookings': currentBookings,
      'is_published': isPublished,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      venue: json['venue']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      eventDate: DateTime.tryParse(json['event_date']?.toString() ?? '') ?? DateTime.now(),
      startTime: _parseTimeOfDay(json['start_time']?.toString()),
      endTime: _parseTimeOfDay(json['end_time']?.toString()),
      ticketPrice: (json['ticket_price'] ?? 0).toDouble(),
      maxCapacity: json['max_capacity'] ?? 0,
      currentBookings: json['current_bookings'] ?? 0,
      isPublished: json['is_published'] ?? false,
      category: json['category']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    
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

class EventBooking {
  final String id;
  final String eventId;
  final String userId;
  final int ticketQuantity;
  final double totalAmount;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final Event? event;

  EventBooking({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketQuantity,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.event,
  });

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    return EventBooking(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      ticketQuantity: json['ticket_quantity'] ?? 1,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'ticket_quantity': ticketQuantity,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Legacy EventData class for backward compatibility
class EventData {
  static final List<Event> events = [];
  static final List<Event> allEvents = [];
}