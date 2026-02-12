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
      id: json['id'] ?? '',
      locationName: json['location_name'] ?? '',
      locationType: json['location_type'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      fullAddress: json['full_address'] ?? '',
      indoorOutdoor: json['indoor_outdoor'] ?? '',
      buskingAreaDescription: json['busking_area_description'] ?? '',
      crowdType: json['crowd_type'] ?? '',
      suitableForBusking: json['suitable_for_busking'] ?? '',
      remarks: json['remarks'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
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
      if (cities is Map<String, dynamic>) {
        cities.forEach((city, locations) {
          if (locations is List) {
            data[state]![city] = locations
                .map((location) => BuskingLocation.fromJson(location))
                .toList();
          }
        });
      }
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    data.forEach((state, cities) {
      json[state] = {};
      cities.forEach((city, locations) {
        json[state][city] = locations.map((location) => location.toJson()).toList();
      });
    });
    return json;
  }
}

class LocationCreateRequest {
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

  LocationCreateRequest({
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
  });

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}

enum LocationType {
  shoppingMall,
  outdoorSpace,
  communityCenter;

  static LocationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'shopping mall':
        return LocationType.shoppingMall;
      case 'outdoor space':
        return LocationType.outdoorSpace;
      case 'community center':
        return LocationType.communityCenter;
      default:
        return LocationType.shoppingMall;
    }
  }

  String get value {
    switch (this) {
      case LocationType.shoppingMall:
        return 'Shopping Mall';
      case LocationType.outdoorSpace:
        return 'Outdoor Space';
      case LocationType.communityCenter:
        return 'Community Center';
    }
  }

  String get displayName {
    switch (this) {
      case LocationType.shoppingMall:
        return 'Shopping Mall';
      case LocationType.outdoorSpace:
        return 'Outdoor Space';
      case LocationType.communityCenter:
        return 'Community Center';
    }
  }
}

enum IndoorOutdoor {
  indoor,
  outdoor;

  static IndoorOutdoor fromString(String type) {
    switch (type.toLowerCase()) {
      case 'outdoor':
        return IndoorOutdoor.outdoor;
      default:
        return IndoorOutdoor.indoor;
    }
  }

  String get value {
    switch (this) {
      case IndoorOutdoor.indoor:
        return 'Indoor';
      case IndoorOutdoor.outdoor:
        return 'Outdoor';
    }
  }

  String get displayName {
    switch (this) {
      case IndoorOutdoor.indoor:
        return 'Indoor';
      case IndoorOutdoor.outdoor:
        return 'Outdoor';
    }
  }
}