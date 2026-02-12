class BuskingLocation {
  final String id;
  final String locationName;
  final String locationType;
  final String state;
  final String city;
  final String fullAddress;
  final String indoorOutdoor;
  final String buskingAreaDescription;
  final String crowdType;
  final String suitableForBusking;
  final String? remarks;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuskingLocation({
    required this.id,
    required this.locationName,
    required this.locationType,
    required this.state,
    required this.city,
    required this.fullAddress,
    required this.indoorOutdoor,
    required this.buskingAreaDescription,
    required this.crowdType,
    required this.suitableForBusking,
    this.remarks,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BuskingLocation.fromJson(Map<String, dynamic> json) {
    return BuskingLocation(
      id: json['id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      locationType: json['location_type']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      indoorOutdoor: json['indoor_outdoor']?.toString() ?? '',
      buskingAreaDescription: json['busking_area_description']?.toString() ?? '',
      crowdType: json['crowd_type']?.toString() ?? '',
      suitableForBusking: json['suitable_for_busking']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'location_type': locationType,
      'state': state,
      'city': city,
      'full_address': fullAddress,
      'indoor_outdoor': indoorOutdoor,
      'busking_area_description': buskingAreaDescription,
      'crowd_type': crowdType,
      'suitable_for_busking': suitableForBusking,
      'remarks': remarks,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LocationsGrouped {
  final Map<String, Map<String, List<BuskingLocation>>> data;

  LocationsGrouped({required this.data});

  factory LocationsGrouped.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, List<BuskingLocation>>> data = {};
    
    json.forEach((state, cities) {
      data[state] = {};
      (cities as Map<String, dynamic>).forEach((city, locations) {
        data[state]![city] = (locations as List)
            .map((location) => BuskingLocation.fromJson(location))
            .toList();
      });
    });
    
    return LocationsGrouped(data: data);
  }

  List<String> get states => data.keys.toList()..sort();
  
  List<String> getCities(String state) {
    final cities = data[state]?.keys.toList();
    cities?.sort();
    return cities ?? [];
  }
  
  List<BuskingLocation> getLocations(String state, String city) {
    return data[state]?[city] ?? [];
  }
}