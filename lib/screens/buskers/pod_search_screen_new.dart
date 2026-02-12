import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/busking_location.dart';
import '../../models/pod_booking.dart';
import '../../data/repositories/location_repository.dart';
import 'pod_details_screen.dart';

class PodSearchScreen extends StatefulWidget {
  const PodSearchScreen({Key? key}) : super(key: key);

  @override
  State<PodSearchScreen> createState() => _PodSearchScreenState();
}

class _PodSearchScreenState extends State<PodSearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<BuskingLocation> _allLocations = [];
  List<String> _cities = [];
  List<String> _malls = [];
  List<BuskingLocation> _filteredLocations = [];
  
  String? _selectedCity;
  String? _selectedMall;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _loadLocations();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final locationRepository = LocationRepository();
      final response = await locationRepository.getGroupedLocations();
      
      if (response.success && response.data != null) {
        final groupedLocations = response.data!;
        final allLocations = <BuskingLocation>[];
        
        groupedLocations.data.forEach((state, cities) {
          cities.forEach((city, locations) {
            allLocations.addAll(locations);
          });
        });
        
        setState(() {
          _allLocations = allLocations;
          _cities = allLocations.map((l) => l.city).where((c) => c.isNotEmpty).toSet().toList()..sort();
          _filteredLocations = allLocations;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load locations');
    }
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
      _selectedMall = null;
      
      if (city != null) {
        _malls = _allLocations
            .where((l) => l.city == city)
            .map((l) => l.locationName)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()..sort();
      } else {
        _malls = [];
      }
      
      _filterLocations();
    });
  }

  void _onMallChanged(String? mall) {
    setState(() {
      _selectedMall = mall;
      _filterLocations();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterLocations();
    });
  }

  void _filterLocations() {
    setState(() {
      _filteredLocations = _allLocations.where((location) {
        bool matchesCity = _selectedCity == null || location.city == _selectedCity;
        bool matchesMall = _selectedMall == null || (location.locationName == _selectedMall);
        bool matchesSearch = _searchQuery.isEmpty ||
            (location.locationName.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (location.city.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (location.state.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        return matchesCity && matchesMall && matchesSearch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _selectedMall = null;
      _searchQuery = '';
      _searchController.clear();
      _malls = [];
      _filteredLocations = _allLocations;
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Busking Pods',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSearchAndFilters(),
                    Expanded(child: _buildLocationsList()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Icon(Icons.search, color: AppColors.primaryGold),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'City',
                  value: _selectedCity,
                  items: _cities,
                  onChanged: _onCityChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Mall',
                  value: _selectedMall,
                  items: _malls,
                  onChanged: _onMallChanged,
                  enabled: _selectedCity != null,
                ),
              ),
            ],
          ),
          
          // Clear Filters Button
          if (_selectedCity != null || _selectedMall != null || _searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.clear_all, size: 16, color: AppColors.primaryGold),
                label: Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select $label',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? AppColors.primaryGold : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    if (_filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No locations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        final location = _filteredLocations[index];
        return _buildLocationCard(location);
      },
    );
  }

  Widget _buildLocationCard(BuskingLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PodDetailsScreen(
                  pod: AvailablePod(
                    id: location.id,
                    name: location.locationName,
                    mall: location.locationName,
                    city: location.city,
                    imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=2400&q=80',
                    description: location.buskingAreaDescription,
                    features: ['Sound System', 'Lighting'],
                    basePrice: 100.0,
                    status: PodStatus.available,
                    rating: 4.5,
                    reviewCount: 50,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.locationName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${location.city}, ${location.state}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: location.indoorOutdoor == 'Indoor'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          location.indoorOutdoor,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: location.indoorOutdoor == 'Indoor'
                                ? Colors.blue[700]
                                : Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  location.buskingAreaDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location.crowdType,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primaryGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}