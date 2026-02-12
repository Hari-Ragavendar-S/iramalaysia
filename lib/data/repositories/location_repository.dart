import '../services/location_service.dart';
import '../models/location/location_models.dart';
import '../../core/api/api_response.dart';
import '../../core/storage/secure_storage.dart';

class LocationRepository {
  final LocationService _locationService = LocationService();

  // States Management
  Future<ApiResponse<List<String>>> getStates() async {
    final response = await _locationService.getStates();
    
    // Cache states list
    if (response.success && response.data != null) {
      await _cacheStates(response.data!);
    }
    
    return response;
  }

  // Cities Management
  Future<ApiResponse<List<String>>> getCities(String state) async {
    final response = await _locationService.getCities(state);
    
    // Cache cities for this state
    if (response.success && response.data != null) {
      await _cacheCities(state, response.data!);
    }
    
    return response;
  }

  // Locations Management
  Future<ApiResponse<List<BuskingLocation>>> getLocations({
    required String state,
    required String city,
  }) async {
    final response = await _locationService.getLocations(
      state: state,
      city: city,
    );
    
    // Cache locations for this state/city
    if (response.success && response.data != null) {
      await _cacheLocations('${state}_$city', response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<GroupedLocations>> getGroupedLocations() async {
    final response = await _locationService.getGroupedLocations();
    
    // Cache grouped locations
    if (response.success && response.data != null) {
      await _cacheGroupedLocations(response.data!);
    }
    
    return response;
  }

  Future<ApiResponse<BuskingLocation>> getLocationDetails(
    String locationId,
  ) async {
    final response = await _locationService.getLocationDetails(locationId);
    
    // Cache location details
    if (response.success && response.data != null) {
      await _cacheLocationDetails(locationId, response.data!);
    }
    
    return response;
  }

  // Cached Data Management
  Future<List<String>?> getCachedStates() async {
    final statesData = await SecureStorage.get('states_list');
    if (statesData != null) {
      try {
        return List<String>.from(statesData);
      } catch (e) {
        await SecureStorage.delete('states_list');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheStates(List<String> states) async {
    await SecureStorage.save('states_list', states);
  }

  Future<List<String>?> getCachedCities(String state) async {
    final citiesData = await SecureStorage.get('cities_$state');
    if (citiesData != null) {
      try {
        return List<String>.from(citiesData);
      } catch (e) {
        await SecureStorage.delete('cities_$state');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheCities(String state, List<String> cities) async {
    await SecureStorage.save('cities_$state', cities);
  }

  Future<List<BuskingLocation>?> getCachedLocations(String stateCity) async {
    final locationsData = await SecureStorage.get('locations_$stateCity');
    if (locationsData != null) {
      try {
        final List<dynamic> locationsList = locationsData;
        return locationsList
            .map((json) => BuskingLocation.fromJson(json))
            .toList();
      } catch (e) {
        await SecureStorage.delete('locations_$stateCity');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheLocations(
    String stateCity,
    List<BuskingLocation> locations,
  ) async {
    final locationsJson = locations.map((loc) => loc.toJson()).toList();
    await SecureStorage.save('locations_$stateCity', locationsJson);
  }

  Future<GroupedLocations?> getCachedGroupedLocations() async {
    final groupedData = await SecureStorage.get('grouped_locations');
    if (groupedData != null) {
      try {
        return GroupedLocations.fromJson(groupedData);
      } catch (e) {
        await SecureStorage.delete('grouped_locations');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheGroupedLocations(GroupedLocations groupedLocations) async {
    await SecureStorage.save('grouped_locations', groupedLocations.toJson());
  }

  Future<BuskingLocation?> getCachedLocationDetails(String locationId) async {
    final locationData = await SecureStorage.get('location_$locationId');
    if (locationData != null) {
      try {
        return BuskingLocation.fromJson(locationData);
      } catch (e) {
        await SecureStorage.delete('location_$locationId');
        return null;
      }
    }
    return null;
  }

  Future<void> _cacheLocationDetails(
    String locationId,
    BuskingLocation location,
  ) async {
    await SecureStorage.save('location_$locationId', location.toJson());
  }

  Future<void> clearCachedLocationData() async {
    await SecureStorage.delete('states_list');
    await SecureStorage.delete('grouped_locations');
    // Note: Individual city and location caches would need to be cleared separately
  }

  // Location Helpers
  Future<List<BuskingLocation>> getAllCachedLocations() async {
    final groupedLocations = await getCachedGroupedLocations();
    if (groupedLocations == null) return [];

    final allLocations = <BuskingLocation>[];
    groupedLocations.locations.forEach((state, cities) {
      cities.forEach((city, locations) {
        allLocations.addAll(locations);
      });
    });
    return allLocations;
  }

  Future<List<BuskingLocation>> getLocationsByState(String state) async {
    final groupedLocations = await getCachedGroupedLocations();
    if (groupedLocations == null || !groupedLocations.locations.containsKey(state)) {
      // Fetch from API if not cached
      final cities = await getCities(state);
      if (!cities.success || cities.data == null) return [];

      final allLocations = <BuskingLocation>[];
      for (final city in cities.data!) {
        final locationsResponse = await getLocations(state: state, city: city);
        if (locationsResponse.success && locationsResponse.data != null) {
          allLocations.addAll(locationsResponse.data!);
        }
      }
      return allLocations;
    }

    final allLocations = <BuskingLocation>[];
    groupedLocations.locations[state]?.forEach((city, locations) {
      allLocations.addAll(locations);
    });
    return allLocations;
  }

  Future<List<BuskingLocation>> getLocationsByCity(
    String state,
    String city,
  ) async {
    // Try to get from cache first
    final cachedLocations = await getCachedLocations('${state}_$city');
    if (cachedLocations != null) {
      return cachedLocations;
    }

    // Fetch from API
    final response = await getLocations(state: state, city: city);
    return response.success ? response.data ?? [] : [];
  }

  // Search Helpers
  Future<List<BuskingLocation>> searchLocations(String query) async {
    final allLocations = await getAllCachedLocations();
    final lowercaseQuery = query.toLowerCase();

    return allLocations.where((location) {
      return location.name?.toLowerCase().contains(lowercaseQuery) == true ||
             location.address?.toLowerCase().contains(lowercaseQuery) == true ||
             location.city?.toLowerCase().contains(lowercaseQuery) == true ||
             location.state?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  Future<List<BuskingLocation>> getPopularLocations() async {
    final allLocations = await getAllCachedLocations();
    // Sort by popularity (assuming there's a popularity field or rating)
    allLocations.sort((a, b) {
      // If there's a rating or popularity field, use it
      // For now, sort by name
      return (a.name ?? '').compareTo(b.name ?? '');
    });
    return allLocations.take(10).toList();
  }

  Future<List<BuskingLocation>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    final allLocations = await getAllCachedLocations();
    
    return allLocations.where((location) {
      if (location.latitude == null || location.longitude == null) {
        return false;
      }
      
      final distance = _calculateDistance(
        latitude,
        longitude,
        location.latitude!,
        location.longitude!,
      );
      
      return distance <= radiusKm;
    }).toList();
  }

  // Malaysian States Helper
  List<String> getMalaysianStates() {
    return [
      'Johor',
      'Kedah',
      'Kelantan',
      'Kuala Lumpur',
      'Labuan',
      'Malacca',
      'Negeri Sembilan',
      'Pahang',
      'Penang',
      'Perak',
      'Perlis',
      'Putrajaya',
      'Sabah',
      'Sarawak',
      'Selangor',
      'Terengganu',
    ];
  }

  // Location Validation
  bool isValidState(String state) {
    return getMalaysianStates().contains(state);
  }

  bool isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    
    // Malaysia coordinates range
    return latitude >= 0.8 && latitude <= 7.4 &&
           longitude >= 99.6 && longitude <= 119.3;
  }

  // Distance Calculation (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Location Categories
  List<String> getLocationCategories() {
    return [
      'Shopping Mall',
      'Park',
      'Street',
      'Plaza',
      'Market',
      'Tourist Attraction',
      'Transportation Hub',
      'Entertainment District',
      'Cultural Center',
      'Other',
    ];
  }

  // Refresh Data
  Future<ApiResponse<List<String>>> refreshStates() async {
    await SecureStorage.delete('states_list');
    return await getStates();
  }

  Future<ApiResponse<List<String>>> refreshCities(String state) async {
    await SecureStorage.delete('cities_$state');
    return await getCities(state);
  }

  Future<ApiResponse<List<BuskingLocation>>> refreshLocations({
    required String state,
    required String city,
  }) async {
    await SecureStorage.delete('locations_${state}_$city');
    return await getLocations(state: state, city: city);
  }

  Future<ApiResponse<GroupedLocations>> refreshGroupedLocations() async {
    await SecureStorage.delete('grouped_locations');
    return await getGroupedLocations();
  }

  Future<ApiResponse<BuskingLocation>> refreshLocationDetails(
    String locationId,
  ) async {
    await SecureStorage.delete('location_$locationId');
    return await getLocationDetails(locationId);
  }

  // Favorites Management (if implemented)
  Future<List<BuskingLocation>> getFavoriteLocations() async {
    final favoriteIds = await SecureStorage.get('favorite_locations');
    if (favoriteIds == null) return [];

    final List<String> ids = List<String>.from(favoriteIds);
    final favoriteLocations = <BuskingLocation>[];

    for (final id in ids) {
      final location = await getCachedLocationDetails(id);
      if (location != null) {
        favoriteLocations.add(location);
      }
    }

    return favoriteLocations;
  }

  Future<void> addToFavorites(String locationId) async {
    final favoriteIds = await SecureStorage.get('favorite_locations') ?? [];
    final List<String> ids = List<String>.from(favoriteIds);
    
    if (!ids.contains(locationId)) {
      ids.add(locationId);
      await SecureStorage.save('favorite_locations', ids);
    }
  }

  Future<void> removeFromFavorites(String locationId) async {
    final favoriteIds = await SecureStorage.get('favorite_locations') ?? [];
    final List<String> ids = List<String>.from(favoriteIds);
    
    ids.remove(locationId);
    await SecureStorage.save('favorite_locations', ids);
  }

  Future<bool> isFavorite(String locationId) async {
    final favoriteIds = await SecureStorage.get('favorite_locations') ?? [];
    final List<String> ids = List<String>.from(favoriteIds);
    return ids.contains(locationId);
  }
}