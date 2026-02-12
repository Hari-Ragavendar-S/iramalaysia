import '../../core/api/api_client.dart';
import '../../core/api/api_response.dart';
import '../../core/api/api_endpoints.dart';
import '../models/location/location_models.dart';

class LocationService {
  final ApiClient _apiClient = ApiClient.instance;

  // Get All States
  Future<ApiResponse<List<String>>> getStates() async {
    return await _apiClient.get<List<String>>(
      ApiEndpoints.locationsStates,
      fromJson: (json) => List<String>.from(json),
    );
  }

  // Get Cities by State
  Future<ApiResponse<List<String>>> getCitiesByState(String state) async {
    return await _apiClient.get<List<String>>(
      ApiEndpoints.locationsCities(state),
      fromJson: (json) => List<String>.from(json),
    );
  }

  // Get Locations by State and City
  Future<ApiResponse<List<BuskingLocation>>> getLocationsByCity({
    required String state,
    required String city,
  }) async {
    return await _apiClient.get<List<BuskingLocation>>(
      ApiEndpoints.locationsInCity(state, city),
      fromJson: (json) => (json as List)
          .map((location) => BuskingLocation.fromJson(location))
          .toList(),
    );
  }

  // Get Grouped Locations
  Future<ApiResponse<LocationsGrouped>> getGroupedLocations() async {
    return await _apiClient.get<LocationsGrouped>(
      ApiEndpoints.locationsGrouped,
      fromJson: (json) => LocationsGrouped.fromJson(json),
    );
  }

  // Get Location Details
  Future<ApiResponse<BuskingLocation>> getLocationDetails(String locationId) async {
    return await _apiClient.get<BuskingLocation>(
      ApiEndpoints.locationDetails(locationId),
      fromJson: (json) => BuskingLocation.fromJson(json),
    );
  }

  // Create Location (if backend supports it)
  Future<ApiResponse<BuskingLocation>> createLocation(
    LocationCreateRequest request,
  ) async {
    return await _apiClient.post<BuskingLocation>(
      ApiEndpoints.locationsStates, // This would need to be updated if backend supports creation
      data: request.toJson(),
      fromJson: (json) => BuskingLocation.fromJson(json),
    );
  }

  // Helper methods for filtering and searching
  Future<ApiResponse<List<BuskingLocation>>> searchLocations(String query) async {
    final groupedResponse = await getGroupedLocations();
    
    if (!groupedResponse.success || groupedResponse.data == null) {
      return ApiResponse.error(error: 'Failed to load locations');
    }

    final allLocations = <BuskingLocation>[];
    final grouped = groupedResponse.data!;
    
    // Flatten all locations
    for (final state in grouped.states) {
      for (final city in grouped.getCities(state)) {
        allLocations.addAll(grouped.getLocations(state, city));
      }
    }

    // Filter by query
    final filteredLocations = allLocations.where((location) {
      final searchQuery = query.toLowerCase();
      return location.locationName.toLowerCase().contains(searchQuery) ||
             location.city.toLowerCase().contains(searchQuery) ||
             location.state.toLowerCase().contains(searchQuery) ||
             location.locationType.toLowerCase().contains(searchQuery) ||
             location.fullAddress.toLowerCase().contains(searchQuery);
    }).toList();

    return ApiResponse.success(data: filteredLocations);
  }

  Future<ApiResponse<List<BuskingLocation>>> getLocationsByType(
    LocationType locationType,
  ) async {
    final groupedResponse = await getGroupedLocations();
    
    if (!groupedResponse.success || groupedResponse.data == null) {
      return ApiResponse.error(error: 'Failed to load locations');
    }

    final allLocations = <BuskingLocation>[];
    final grouped = groupedResponse.data!;
    
    // Flatten all locations
    for (final state in grouped.states) {
      for (final city in grouped.getCities(state)) {
        allLocations.addAll(grouped.getLocations(state, city));
      }
    }

    // Filter by type
    final filteredLocations = allLocations
        .where((location) => location.locationType == locationType.value)
        .toList();

    return ApiResponse.success(data: filteredLocations);
  }

  Future<ApiResponse<List<BuskingLocation>>> getIndoorLocations() async {
    return await _getLocationsByIndoorOutdoor(IndoorOutdoor.indoor);
  }

  Future<ApiResponse<List<BuskingLocation>>> getOutdoorLocations() async {
    return await _getLocationsByIndoorOutdoor(IndoorOutdoor.outdoor);
  }

  Future<ApiResponse<List<BuskingLocation>>> _getLocationsByIndoorOutdoor(
    IndoorOutdoor indoorOutdoor,
  ) async {
    final groupedResponse = await getGroupedLocations();
    
    if (!groupedResponse.success || groupedResponse.data == null) {
      return ApiResponse.error(error: 'Failed to load locations');
    }

    final allLocations = <BuskingLocation>[];
    final grouped = groupedResponse.data!;
    
    // Flatten all locations
    for (final state in grouped.states) {
      for (final city in grouped.getCities(state)) {
        allLocations.addAll(grouped.getLocations(state, city));
      }
    }

    // Filter by indoor/outdoor
    final filteredLocations = allLocations
        .where((location) => location.indoorOutdoor == indoorOutdoor.value)
        .toList();

    return ApiResponse.success(data: filteredLocations);
  }

  Future<ApiResponse<List<BuskingLocation>>> getSuitableLocations() async {
    final groupedResponse = await getGroupedLocations();
    
    if (!groupedResponse.success || groupedResponse.data == null) {
      return ApiResponse.error(error: 'Failed to load locations');
    }

    final allLocations = <BuskingLocation>[];
    final grouped = groupedResponse.data!;
    
    // Flatten all locations
    for (final state in grouped.states) {
      for (final city in grouped.getCities(state)) {
        allLocations.addAll(grouped.getLocations(state, city));
      }
    }

    // Filter by suitability
    final filteredLocations = allLocations
        .where((location) => location.suitableForBusking.toLowerCase() == 'yes')
        .toList();

    return ApiResponse.success(data: filteredLocations);
  }

  // Utility methods
  bool isLocationSuitable(BuskingLocation location) {
    return location.suitableForBusking.toLowerCase() == 'yes';
  }

  bool isLocationIndoor(BuskingLocation location) {
    return location.indoorOutdoor.toLowerCase() == 'indoor';
  }

  bool isLocationOutdoor(BuskingLocation location) {
    return location.indoorOutdoor.toLowerCase() == 'outdoor';
  }

  LocationType getLocationType(BuskingLocation location) {
    return LocationType.fromString(location.locationType);
  }

  IndoorOutdoor getIndoorOutdoor(BuskingLocation location) {
    return IndoorOutdoor.fromString(location.indoorOutdoor);
  }

  String getLocationDisplayName(BuskingLocation location) {
    return '${location.locationName}, ${location.city}';
  }

  String getLocationFullDisplayName(BuskingLocation location) {
    return '${location.locationName}, ${location.city}, ${location.state}';
  }

  // Get locations for dropdown/picker
  Future<ApiResponse<Map<String, List<String>>>> getStatesAndCities() async {
    final groupedResponse = await getGroupedLocations();
    
    if (!groupedResponse.success || groupedResponse.data == null) {
      return ApiResponse.error(error: 'Failed to load locations');
    }

    final statesAndCities = <String, List<String>>{};
    final grouped = groupedResponse.data!;
    
    for (final state in grouped.states) {
      statesAndCities[state] = grouped.getCities(state);
    }

    return ApiResponse.success(data: statesAndCities);
  }
}