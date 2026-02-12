import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/safe_network_image.dart';
import '../../models/pod_booking.dart';
import '../../models/busking_location.dart';
import '../../data/repositories/location_repository.dart';
import 'pod_details_screen.dart';

class PodSearchScreen extends StatefulWidget {
  const PodSearchScreen({super.key});

  @override
  State<PodSearchScreen> createState() => _PodSearchScreenState();
}

class _PodSearchScreenState extends State<PodSearchScreen> {
  final LocationRepository _locationRepository = LocationRepository();
  bool _isGridView = true;
  bool _isLoading = true;
  
  List<AvailablePod> _filteredPods = [];
  List<AvailablePod> _allPods = [];
  List<BuskingLocation> _locations = [];
  List<String> _states = [];
  List<String> _cities = [];
  List<String> _malls = [];
  
  String? _selectedState;
  String? _selectedCity;
  String? _selectedMall;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load locations from backend
      final response = await _locationRepository.getGroupedLocations();
      
      if (response.success && response.data != null) {
        final groupedLocations = response.data!;
        final allLocations = <BuskingLocation>[];
        
        groupedLocations.data.forEach((state, cities) {
          cities.forEach((city, locations) {
            allLocations.addAll(locations);
          });
        });
        
        _locations = allLocations;
        _states = allLocations.map((l) => l.state).where((s) => s.isNotEmpty).toSet().toList()..sort();
      } else {
        throw Exception('Failed to load locations');
      }
      
      // Load pods (mock data for now - in real app, this would come from API)
      _loadPods();
      
    } catch (e) {
      print('Error loading data: $e');
      // Fallback to mock data
      _loadMockLocations();
      _loadPods();
    }
    
    setState(() => _isLoading = false);
  }

  void _loadMockLocations() {
    // Fallback mock data if API fails
    _locations = [
      BuskingLocation(
        id: '1',
        locationName: 'Suria KLCC',
        locationType: 'Shopping Mall',
        state: 'Kuala Lumpur',
        city: 'Kuala Lumpur',
        fullAddress: 'Jalan Ampang, 50088 Kuala Lumpur',
        indoorOutdoor: 'Indoor',
        buskingAreaDescription: 'Concourse level near main entrance',
        crowdType: 'Tourists, families, office workers',
        suitableForBusking: 'Yes',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BuskingLocation(
        id: '2',
        locationName: 'Pavilion Kuala Lumpur',
        locationType: 'Shopping Mall',
        state: 'Kuala Lumpur',
        city: 'Bukit Bintang',
        fullAddress: '168 Jalan Bukit Bintang, 55100 Kuala Lumpur',
        indoorOutdoor: 'Indoor',
        buskingAreaDescription: 'Main atrium area',
        crowdType: 'Shoppers, tourists, youths',
        suitableForBusking: 'Yes',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    _states = _locations.map((l) => l.state).where((s) => s.isNotEmpty).toSet().toList()..sort();
  }

  void _loadPods() {
    // Mock data - in real app, this would come from API
    _allPods = [
      AvailablePod(
        id: '1',
        name: 'Premium Performance Pod',
        mall: 'Pavilion KL',
        city: 'Kuala Lumpur',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=2400&q=80',
        description: 'State-of-the-art performance space with professional sound system',
        features: ['Professional Sound System', 'LED Lighting', 'Air Conditioning', 'Security'],
        basePrice: 150.0,
        status: PodStatus.available,
        rating: 4.8,
        reviewCount: 124,
      ),
      AvailablePod(
        id: '2',
        name: 'Acoustic Corner Pod',
        mall: 'Mid Valley Megamall',
        city: 'Kuala Lumpur',
        imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=2400&q=80',
        description: 'Intimate acoustic setting perfect for solo performances',
        features: ['Acoustic Design', 'Natural Lighting', 'Comfortable Seating'],
        basePrice: 100.0,
        status: PodStatus.available,
        rating: 4.6,
        reviewCount: 89,
      ),
      AvailablePod(
        id: '3',
        name: 'Urban Stage Pod',
        mall: 'Sunway Pyramid',
        city: 'Petaling Jaya',
        imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=2400&q=80',
        description: 'Modern urban-style performance space with city vibes',
        features: ['Modern Design', 'High-Tech Equipment', 'Social Media Setup'],
        basePrice: 120.0,
        status: PodStatus.available,
        rating: 4.7,
        reviewCount: 156,
      ),
    ];
    _filteredPods = List.from(_allPods);
  }

  void _onStateChanged(String? state) {
    setState(() {
      _selectedState = state;
      _selectedCity = null;
      _selectedMall = null;
      
      if (state != null) {
        _cities = _locations
            .where((l) => l.state == state)
            .map((l) => l.city)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()..sort();
      } else {
        _cities.clear();
      }
      _malls.clear();
    });
    _filterPods();
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
      _selectedMall = null;
      
      if (city != null && _selectedState != null) {
        _malls = _locations
            .where((l) => l.state == _selectedState && l.city == city)
            .map((l) => l.locationName)
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList()..sort();
      } else {
        _malls.clear();
      }
    });
    _filterPods();
  }

  void _onMallChanged(String? mall) {
    setState(() {
      _selectedMall = mall;
    });
    _filterPods();
  }

  void _filterPods() {
    setState(() {
      _filteredPods = _allPods.where((pod) {
        bool stateMatch = _selectedState == null || 
            _locations.any((l) => l.locationName == pod.mall && l.state == _selectedState);
        bool cityMatch = _selectedCity == null || pod.city == _selectedCity;
        bool mallMatch = _selectedMall == null || pod.mall == _selectedMall;
        
        return stateMatch && cityMatch && mallMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedState = null;
      _selectedCity = null;
      _selectedMall = null;
      _cities.clear();
      _malls.clear();
      _filteredPods = List.from(_allPods);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'Book a Pod',
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                // Location Selection Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softGoldHighlight.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // State Dropdown
                      _buildDropdown(
                        label: 'State',
                        value: _selectedState,
                        items: _states,
                        onChanged: _onStateChanged,
                        hint: 'Select State',
                        icon: Icons.map,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // City Dropdown
                      _buildDropdown(
                        label: 'City',
                        value: _selectedCity,
                        items: _cities,
                        onChanged: _onCityChanged,
                        hint: 'Select City',
                        icon: Icons.location_city,
                        enabled: _selectedState != null,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Mall Dropdown
                      _buildDropdown(
                        label: 'Mall',
                        value: _selectedMall,
                        items: _malls,
                        onChanged: _onMallChanged,
                        hint: 'Select Mall',
                        icon: Icons.store,
                        enabled: _selectedCity != null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Results and Clear Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_filteredPods.length} pods available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          if (_selectedState != null || _selectedCity != null || _selectedMall != null)
                            GestureDetector(
                              onTap: _clearFilters,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      size: 16,
                                      color: AppColors.primaryGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Pods List/Grid
                Expanded(
                  child: _filteredPods.isEmpty
                      ? _buildEmptyState()
                      : _isGridView
                          ? _buildGridView()
                          : _buildListView(),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading locations...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled ? [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon, 
                color: enabled ? AppColors.primaryGold : Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No pods found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your location selection',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredPods.length,
        itemBuilder: (context, index) {
          final pod = _filteredPods[index];
          return _buildPodGridCard(pod);
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPods.length,
      itemBuilder: (context, index) {
        final pod = _filteredPods[index];
        return _buildPodListCard(pod);
      },
    );
  }

  Widget _buildPodGridCard(AvailablePod pod) {
    return GestureDetector(
      onTap: () => _navigateToPodDetails(pod),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SafeNetworkImage(
                      imageUrl: pod.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pod.status.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pod.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pod.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pod.mall}, ${pod.city}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RM ${pod.basePrice.toStringAsFixed(0)}/hr',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodListCard(AvailablePod pod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToPodDetails(pod),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SafeNetworkImage(
                  imageUrl: pod.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pod.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: pod.status.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pod.status.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pod.mall}, ${pod.city}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pod.rating} (${pod.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'RM ${pod.basePrice.toStringAsFixed(0)}/hr',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPodDetails(AvailablePod pod) {
    // Find the selected location to pass to pod details
    BuskingLocation? selectedLocation;
    if (_selectedMall != null && _locations.isNotEmpty) {
      try {
        selectedLocation = _locations.firstWhere(
          (l) => l.locationName == _selectedMall,
        );
      } catch (e) {
        selectedLocation = _locations.isNotEmpty ? _locations.first : null;
      }
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodDetailsScreen(
          pod: pod,
        ),
      ),
    );
  }
}