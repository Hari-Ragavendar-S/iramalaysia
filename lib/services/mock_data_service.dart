import 'dart:async';
import 'dart:math';
import '../models/pod_booking.dart';
import 'package:flutter/material.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Mock locations data
  static const List<Map<String, dynamic>> _mockLocations = [
    {
      'state': 'Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'locations': [
        'KLCC',
        'Pavilion KL',
        'Mid Valley Megamall',
        'Sunway Pyramid',
        'The Gardens Mall',
        'Suria KLCC',
        'Lot 10',
        'Berjaya Times Square'
      ]
    },
    {
      'state': 'Selangor',
      'city': 'Petaling Jaya',
      'locations': [
        '1 Utama',
        'The Curve',
        'IPC Shopping Centre',
        'Paradigm Mall',
        'Tropicana Gardens Mall'
      ]
    },
    {
      'state': 'Selangor',
      'city': 'Shah Alam',
      'locations': [
        'i-City Mall',
        'Plaza Shah Alam',
        'SACC Mall',
        'Setia City Mall'
      ]
    },
    {
      'state': 'Penang',
      'city': 'George Town',
      'locations': [
        'Gurney Plaza',
        'Queensbay Mall',
        'Penang Times Square',
        'Straits Quay'
      ]
    },
    {
      'state': 'Johor',
      'city': 'Johor Bahru',
      'locations': [
        'City Square',
        'KSL City Mall',
        'Paradigm Mall JB',
        'Toppen Shopping Centre'
      ]
    }
  ];

  // Generate mock pods
  List<AvailablePod> generateMockPods({
    String? state,
    String? city,
    String? location,
  }) {
    final random = Random();
    final pods = <AvailablePod>[];

    // Get locations to use
    List<String> locationsToUse = [];
    if (location != null) {
      locationsToUse = [location];
    } else {
      for (var loc in _mockLocations) {
        if (state != null && loc['state'] != state) continue;
        if (city != null && loc['city'] != city) continue;
        locationsToUse.addAll(List<String>.from(loc['locations']));
      }
    }

    if (locationsToUse.isEmpty) {
      locationsToUse = ['KLCC', 'Pavilion KL', 'Mid Valley Megamall'];
    }

    // Generate 10-20 pods
    final podCount = 10 + random.nextInt(11);
    
    for (int i = 0; i < podCount; i++) {
      final selectedLocation = locationsToUse[random.nextInt(locationsToUse.length)];
      final podNumber = 'P${(i + 1).toString().padLeft(3, '0')}';
      
      pods.add(AvailablePod(
        id: 'pod_${i + 1}',
        name: 'Pod $podNumber',
        mall: selectedLocation,
        city: _getCityForLocation(selectedLocation),
        basePrice: 15.0 + (random.nextInt(20) * 5), // RM15-RM115
        rating: 3.5 + (random.nextDouble() * 1.5), // 3.5-5.0
        reviewCount: 10 + random.nextInt(200),
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        description: 'Premium busking pod with excellent acoustics and high foot traffic. Perfect for solo performers and small groups.',
        features: _generateRandomAmenities(random),
        status: random.nextBool() ? PodStatus.available : PodStatus.busy,
        location: selectedLocation,
      ));
    }

    return pods;
  }

  String _getCityForLocation(String location) {
    for (var loc in _mockLocations) {
      if ((loc['locations'] as List).contains(location)) {
        return loc['city'];
      }
    }
    return 'Kuala Lumpur';
  }

  String _getStateForLocation(String location) {
    for (var loc in _mockLocations) {
      if ((loc['locations'] as List).contains(location)) {
        return loc['state'];
      }
    }
    return 'Kuala Lumpur';
  }

  List<String> _generateRandomAmenities(Random random) {
    final allAmenities = [
      'Power Outlet',
      'WiFi',
      'Storage Space',
      'Microphone Stand',
      'Lighting',
      'Weather Protection',
      'Security Camera',
      'Nearby Parking',
      'Restroom Access',
      'Food Court Nearby'
    ];
    
    final count = 3 + random.nextInt(5); // 3-7 amenities
    allAmenities.shuffle(random);
    return allAmenities.take(count).toList();
  }

  // Generate mock time slots
  List<TimeSlot> generateMockTimeSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final random = Random();
    
    // Generate slots from 9 AM to 9 PM
    for (int hour = 9; hour <= 21; hour++) {
      final isAvailable = random.nextBool();
      final price = 15.0 + (random.nextInt(10) * 5); // RM15-RM65
      
      slots.add(TimeSlot(
        id: 'slot_${hour}',
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        price: price,
        status: isAvailable ? SlotStatus.available : SlotStatus.booked,
      ));
    }
    
    return slots;
  }

  // Get mock states
  List<String> getStates() {
    return _mockLocations.map((e) => e['state'] as String).toSet().toList();
  }

  // Get mock cities for a state
  List<String> getCities(String state) {
    return _mockLocations
        .where((e) => e['state'] == state)
        .map((e) => e['city'] as String)
        .toList();
  }

  // Get mock locations for a city
  List<String> getLocations(String state, String city) {
    final location = _mockLocations.firstWhere(
      (e) => e['state'] == state && e['city'] == city,
      orElse: () => {'locations': <String>[]},
    );
    return List<String>.from(location['locations'] ?? []);
  }

  // Mock booking creation
  Future<Map<String, dynamic>> createBooking({
    required String podId,
    required DateTime date,
    required List<String> timeSlots,
    required double totalAmount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    final random = Random();
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final referenceNo = 'REF${random.nextInt(999999).toString().padLeft(6, '0')}';
    
    return {
      'success': true,
      'booking_id': bookingId,
      'reference_no': referenceNo,
      'status': 'pending_payment',
      'message': 'Booking created successfully. Please upload payment proof.',
    };
  }

  // Mock payment proof upload
  Future<Map<String, dynamic>> uploadPaymentProof({
    required String bookingId,
    required String imagePath,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'success': true,
      'message': 'Payment proof uploaded successfully. Your booking is being verified.',
      'status': 'under_review',
    };
  }

  // Mock user bookings
  List<Map<String, dynamic>> getUserBookings() {
    final random = Random();
    final bookings = <Map<String, dynamic>>[];
    
    // Generate 3-5 mock bookings
    for (int i = 0; i < 3 + random.nextInt(3); i++) {
      final date = DateTime.now().add(Duration(days: random.nextInt(30) - 15));
      final statuses = ['confirmed', 'pending_payment', 'under_review', 'cancelled'];
      final status = statuses[random.nextInt(statuses.length)];
      
      bookings.add({
        'id': 'BK${1000 + i}',
        'pod_name': 'Pod P${(i + 1).toString().padLeft(3, '0')}',
        'mall': _mockLocations[random.nextInt(_mockLocations.length)]['locations'][0],
        'date': date.toIso8601String(),
        'time_slots': ['10:00-11:00', '11:00-12:00'],
        'total_amount': 30.0 + (random.nextInt(10) * 10),
        'status': status,
        'reference_no': 'REF${random.nextInt(999999).toString().padLeft(6, '0')}',
      });
    }
    
    return bookings;
  }

  // Mock events
  List<Map<String, dynamic>> getEvents() {
    final random = Random();
    final events = <Map<String, dynamic>>[];
    
    final eventNames = [
      'KL Street Music Festival',
      'Buskers Unite Malaysia',
      'Acoustic Nights',
      'Urban Sounds',
      'Music in the Mall',
      'Talent Showcase',
    ];
    
    for (int i = 0; i < eventNames.length; i++) {
      final date = DateTime.now().add(Duration(days: random.nextInt(60)));
      
      events.add({
        'id': 'event_${i + 1}',
        'title': eventNames[i],
        'description': 'Join us for an amazing musical experience featuring talented buskers from across Malaysia.',
        'date': date.toIso8601String(),
        'location': _mockLocations[random.nextInt(_mockLocations.length)]['locations'][0],
        'price': random.nextInt(5) == 0 ? 0 : 10 + (random.nextInt(5) * 5), // Some free events
        'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        'max_participants': 50 + random.nextInt(200),
        'current_participants': random.nextInt(100),
      });
    }
    
    return events;
  }
}