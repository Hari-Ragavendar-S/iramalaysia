import 'package:flutter/material.dart';

class BuskerPod {
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
  final DateTime updatedAt;

  // Backend-specific fields
  final List<String>? images;
  final List<String>? amenities;
  final double? rating;
  final int? reviewCount;
  final int? capacity;

  // Legacy fields for backward compatibility
  final String address;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime submittedAt;
  final double pricePerHour;

  BuskerPod({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.mall,
    required this.basePrice,
    required this.features,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    // Backend-specific fields
    this.images,
    this.amenities,
    this.rating,
    this.reviewCount,
    this.capacity,
    // Legacy fields with defaults
    String? address,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? submittedAt,
    double? pricePerHour,
  }) : 
    address = address ?? location,
    startDate = startDate ?? DateTime.now(),
    endDate = endDate ?? DateTime.now().add(const Duration(days: 365)),
    startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0),
    endTime = endTime ?? const TimeOfDay(hour: 22, minute: 0),
    submittedAt = submittedAt ?? createdAt,
    pricePerHour = pricePerHour ?? basePrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'city': city,
      'mall': mall,
      'base_price': basePrice,
      'features': features,
      'image_url': imageUrl,
      'images': images,
      'amenities': amenities,
      'rating': rating,
      'review_count': reviewCount,
      'capacity': capacity,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Legacy fields
      'address': address,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'submittedAt': submittedAt.toIso8601String(),
      'pricePerHour': pricePerHour,
    };
  }

  factory BuskerPod.fromJson(Map<String, dynamic> json) {
    // Parse times safely
    TimeOfDay parseTime(String? timeStr, TimeOfDay defaultTime) {
      if (timeStr == null || timeStr.isEmpty) return defaultTime;
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return defaultTime;
      }
    }

    // Parse dates safely
    DateTime parseDate(String? dateStr, DateTime defaultDate) {
      if (dateStr == null || dateStr.isEmpty) return defaultDate;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return defaultDate;
      }
    }

    final now = DateTime.now();
    
    return BuskerPod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['address']?.toString() ?? json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      mall: json['mall']?.toString() ?? '',
      basePrice: (json['price_per_hour'] ?? json['base_price'] ?? json['pricePerHour'] ?? 100.0).toDouble(),
      features: List<String>.from(json['amenities'] ?? json['features'] ?? []),
      imageUrl: json['images'] is List && (json['images'] as List).isNotEmpty 
          ? json['images'][0]?.toString() 
          : json['image_url']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: parseDate(json['created_at'] ?? json['submittedAt'], now),
      updatedAt: parseDate(json['updated_at'], now),
      // Backend-specific fields
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count']?.toInt(),
      capacity: json['capacity']?.toInt(),
      // Legacy fields
      address: json['address']?.toString() ?? json['location']?.toString() ?? '',
      startDate: parseDate(json['startDate'], now),
      endDate: parseDate(json['endDate'], now.add(const Duration(days: 365))),
      startTime: parseTime(json['startTime'], const TimeOfDay(hour: 9, minute: 0)),
      endTime: parseTime(json['endTime'], const TimeOfDay(hour: 22, minute: 0)),
      submittedAt: parseDate(json['submittedAt'] ?? json['created_at'], now),
      pricePerHour: (json['price_per_hour'] ?? json['base_price'] ?? json['pricePerHour'] ?? 100.0).toDouble(),
    );
  }
}