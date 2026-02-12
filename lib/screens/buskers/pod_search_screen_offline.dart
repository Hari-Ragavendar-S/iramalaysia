import 'package:flutter/material.dart';
import '../../models/pod_booking.dart';
import '../../services/mock_data_service.dart';
import '../../utils/colors.dart';
import 'pod_details_screen.dart';

class PodSearchScreenOffline extends StatefulWidget {
  const PodSearchScreenOffline({super.key});

  @override
  State<PodSearchScreenOffline> createState() => _PodSearchScreenOfflineState();
}

class _PodSearchScreenOfflineState extends State<PodSearchScreenOffline> {
  final MockDataService _mockService = MockDataService();
  
  List<AvailablePod> _pods = [];
  List<AvailablePod> _filteredPods = [];
  bool _isLoading = false;
  
  String? _selectedState;
  String? _selectedCity;
  String? _selectedLocation;
  
  List<String> _states = [];
  List<String> _cities = [];
  List<String> _locations = [];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadPods();
  }

  void _loadStates() {
    setState(() {
      _states = _mockService.getStates();
    });
  }

  void _loadCities(String state) {
    setState(() {
      _cities = _mockService.getCities(state);
      _selectedCity = null;
      _selectedLocation = null;
      _locations = [];
    });
  }

  void _loadLocations(String state, String city) {
    setState(() {
      _locations = _mockService.getLocations(state, city);
      _selectedLocation = null;
    });
  }

  void _loadPods() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      final pods = _mockService.generateMockPods(
        state: _selectedState,
        city: _selectedCity,
        location: _selectedLocation,
      );
      
      setState(() {
        _pods = pods;
        _filteredPods = pods;
        _isLoading = false;
      });
    });
  }

  void _filterPods(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPods = _pods;
      } else {
        _filteredPods = _pods.where((pod) {
          return pod.name.toLowerCase().contains(query.toLowerCase()) ||
                 pod.mall.toLowerCase().contains(query.toLowerCase()) ||
                 pod.city.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedState = null;
      _selectedCity = null;
      _selectedLocation = null;
      _cities = [];
      _locations = [];
      _searchController.clear();
    });
    _loadPods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Busking Pods'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPods,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundCard,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search pods, malls, or cities...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterPods('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _filterPods,
                ),
                const SizedBox(height: 16),
                
                // Filter Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedState,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _states.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                          });
                          if (value != null) {
                            _loadCities(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                          if (value != null && _selectedState != null) {
                            _loadLocations(_selectedState!, value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loadPods,
                      child: const Text('Search'),
                    ),
                  ],
                ),
                
                if (_selectedState != null || _selectedCity != null || _selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading pods...'),
                      ],
                    ),
                  )
                : _filteredPods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pods found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search criteria',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPods.length,
                        itemBuilder: (context, index) {
                          final pod = _filteredPods[index];
                          return _buildPodCard(pod);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodCard(AvailablePod pod) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodDetailsScreen(pod: pod),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pod.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pod.mall}, ${pod.city}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pod.status == PodStatus.available ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pod.status == PodStatus.available ? 'Available' : 'Occupied',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    pod.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(' (${pod.reviewCount} reviews)'),
                  const Spacer(),
                  Text(
                    'RM${pod.basePrice.toStringAsFixed(0)}/hour',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: pod.features.take(3).map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}