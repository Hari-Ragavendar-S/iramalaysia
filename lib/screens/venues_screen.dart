import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../models/busking_location.dart';
import '../services/location_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/safe_network_image.dart';
import '../widgets/shimmer_widgets.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  LocationsGrouped? _groupedLocations;
  List<BuskingLocation> _allLocations = [];
  List<BuskingLocation> _filteredLocations = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedState;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LocationService.getGroupedLocations();
      
      if (result['success']) {
        final groupedData = result['data'] as LocationsGrouped;
        final allLocations = <BuskingLocation>[];
        
        // Flatten all locations
        for (final state in groupedData.states) {
          for (final city in groupedData.getCities(state)) {
            allLocations.addAll(groupedData.getLocations(state, city));
          }
        }
        
        setState(() {
          _groupedLocations = groupedData;
          _allLocations = allLocations;
          _filteredLocations = List.from(allLocations);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load venues';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterVenues() {
    setState(() {
      _filteredLocations = _allLocations.where((location) {
        final matchesSearch = _searchQuery.isEmpty ||
            location.locationName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            location.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            location.state.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesState = _selectedState == null || location.state == _selectedState;
        
        return matchesSearch && matchesState;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: AppColors.spacingS),
            Text(
              'Busking Venues',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadVenues,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppColors.radiusM),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search venues, cities, or states...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppColors.spacingM,
                  vertical: AppColors.spacingM,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterVenues();
              },
            ),
          ),
          
          const SizedBox(height: AppColors.spacingM),
          
          // State Filter
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedState,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                    _filterVenues();
                  },
                  decoration: InputDecoration(
                    labelText: 'Filter by State',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppColors.radiusM),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppColors.spacingM,
                      vertical: AppColors.spacingS,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'All States',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    if (_groupedLocations != null)
                      ..._groupedLocations!.states.map((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(
                            state,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(width: AppColors.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.spacingM,
                  vertical: AppColors.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppColors.radiusM),
                ),
                child: Text(
                  '${_filteredLocations.length} venues',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const GridShimmer(itemCount: 6, crossAxisCount: 2);
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _loadVenues,
        ),
      );
    }

    if (_filteredLocations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
      color: AppColors.primaryPurple,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppColors.spacingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppColors.spacingM,
          mainAxisSpacing: AppColors.spacingM,
        ),
        itemCount: _filteredLocations.length,
        itemBuilder: (context, index) {
          return _buildVenueCard(_filteredLocations[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: AppColors.spacingL),
            Text(
              'No venues found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingS),
            Text(
              'Try adjusting your search criteria or check back later',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.spacingL),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedState = null;
                });
                _filterVenues();
              },
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard(BuskingLocation location) {
    // Generate venue image based on location type
    String getVenueImage(String locationType) {
      switch (locationType.toLowerCase()) {
        case 'shopping mall':
          return 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=800&q=80';
        case 'park':
          return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80';
        case 'street':
          return 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=800&q=80';
        default:
          return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80';
      }
    }

    return GestureDetector(
      onTap: () => _showVenueDetails(location),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppColors.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppColors.radiusL),
                    ),
                    child: SafeNetworkImage(
                      imageUrl: getVenueImage(location.locationType),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Indoor/Outdoor Badge
                  Positioned(
                    top: AppColors.spacingS,
                    right: AppColors.spacingS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: location.indoorOutdoor.toLowerCase() == 'indoor'
                            ? Colors.blue.withOpacity(0.9)
                            : Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                      child: Text(
                        location.indoorOutdoor,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Venue Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppColors.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.locationName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${location.city}, ${location.state}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppColors.spacingS),
                    
                    // Location Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppColors.radiusS),
                      ),
                      child: Text(
                        location.locationType,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Crowd Type
                    Text(
                      location.crowdType,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  void _showVenueDetails(BuskingLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppColors.radiusL),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: AppColors.spacingM),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppColors.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          location.locationName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppColors.spacingS),
                        
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.primaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.fullAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppColors.spacingL),
                        
                        // Details Grid
                        _buildDetailRow('Type', location.locationType),
                        _buildDetailRow('Setting', location.indoorOutdoor),
                        _buildDetailRow('Busking Area', location.buskingAreaDescription),
                        _buildDetailRow('Crowd Type', location.crowdType),
                        _buildDetailRow('Suitable for Busking', location.suitableForBusking),
                        
                        if (location.remarks != null && location.remarks!.isNotEmpty) ...[
                          const SizedBox(height: AppColors.spacingM),
                          Text(
                            'Additional Notes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppColors.spacingS),
                          Text(
                            location.remarks!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppColors.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}