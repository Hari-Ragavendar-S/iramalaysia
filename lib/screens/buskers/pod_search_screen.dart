import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../utils/colors.dart';
import '../../widgets/safe_network_image.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../services/pod_service.dart';
import '../../models/pod_booking.dart';
import 'pod_details_screen.dart';

class PodSearchScreen extends StatefulWidget {
  const PodSearchScreen({super.key});

  @override
  State<PodSearchScreen> createState() => _PodSearchScreenState();
}

class _PodSearchScreenState extends State<PodSearchScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _mallController = TextEditingController();
  
  bool _isGridView = true;
  bool _isLoading = false;
  List<AvailablePod> _filteredPods = [];
  List<AvailablePod> _allPods = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPods();
  }

  Future<void> _loadPods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await PodService.getPods(
        page: 1,
        perPage: 20,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        mall: _mallController.text.trim().isNotEmpty ? _mallController.text.trim() : null,
      );
      
      if (result['success']) {
        final buskerPods = result['data'] as List<dynamic>;
        final pods = buskerPods.map((buskerPod) => AvailablePod(
          id: buskerPod.id,
          name: buskerPod.name,
          mall: buskerPod.mall,
          city: buskerPod.city,
          imageUrl: buskerPod.images?.isNotEmpty == true 
              ? buskerPod.images!.first 
              : buskerPod.imageUrl ?? 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80',
          images: buskerPod.images ?? (buskerPod.imageUrl != null ? [buskerPod.imageUrl!] : []),
          description: buskerPod.description.isNotEmpty 
              ? buskerPod.description 
              : 'Professional performance space with excellent facilities',
          features: buskerPod.amenities ?? buskerPod.features,
          basePrice: buskerPod.pricePerHour,
          status: buskerPod.isActive ? PodStatus.available : PodStatus.maintenance,
          rating: buskerPod.rating ?? 4.5,
          reviewCount: buskerPod.reviewCount ?? 0,
        )).toList();
        
        setState(() {
          _allPods = pods;
          _filteredPods = List.from(pods);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load pods';
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

  Future<void> _onRefresh() async {
    await _loadPods();
    _refreshController.refreshCompleted();
  }

  void _filterPods() {
    setState(() {
      _filteredPods = _allPods.where((pod) {
        final cityMatch = _cityController.text.isEmpty ||
            pod.city.toLowerCase().contains(_cityController.text.toLowerCase());
        final mallMatch = _mallController.text.isEmpty ||
            pod.mall.toLowerCase().contains(_mallController.text.toLowerCase());
        return cityMatch && mallMatch;
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: AppColors.spacingS),
            Text(
              'Book a Pod',
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
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: AppColors.primaryPurple,
            ),
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(
              Icons.tune,
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: WaterDropMaterialHeader(
          backgroundColor: AppColors.primaryPurple,
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Search Section
            Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildSearchField(
                          controller: _cityController,
                          hintText: 'Search by city',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: AppColors.spacingM),
                      Expanded(
                        child: _buildSearchField(
                          controller: _mallController,
                          hintText: 'Search by mall',
                          icon: Icons.store_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppColors.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredPods.length} pods available',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_filteredPods.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.spacingM,
                            vertical: AppColors.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppColors.radiusRound),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort,
                                size: 16,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sort',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryPurple,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppColors.spacingM,
            vertical: AppColors.spacingM,
          ),
        ),
        onChanged: (_) => _filterPods(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _isGridView 
          ? const GridShimmer(itemCount: 6, crossAxisCount: 2)
          : const PodListShimmer(itemCount: 5);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppColors.spacingM),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingS),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppColors.spacingL),
            ElevatedButton(
              onPressed: _loadPods,
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredPods.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
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
                Icons.search_off_outlined,
                size: 64,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: AppColors.spacingL),
            Text(
              'No pods found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingS),
            Text(
              'Try adjusting your search criteria or check back later for new pods',
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
                _cityController.clear();
                _mallController.clear();
                _filterPods();
              },
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(AppColors.spacingM),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppColors.spacingM,
          mainAxisSpacing: AppColors.spacingM,
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
      padding: const EdgeInsets.all(AppColors.spacingM),
      itemCount: _filteredPods.length,
      itemBuilder: (context, index) {
        final pod = _filteredPods[index];
        return _buildPodListCard(pod);
      },
    );
  }

  Widget _buildPodGridCard(AvailablePod pod) {
    final images = pod.images?.isNotEmpty == true 
        ? pod.images! 
        : [pod.imageUrl];

    return GestureDetector(
      onTap: () => _navigateToPodDetails(pod),
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
            // Image Carousel
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppColors.radiusL),
                    ),
                    child: images.length > 1
                        ? CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: false,
                              autoPlay: false,
                            ),
                            items: images.map((imageUrl) {
                              return SafeNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          )
                        : SafeNetworkImage(
                            imageUrl: images.first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  
                  // Status Badge
                  Positioned(
                    top: AppColors.spacingS,
                    right: AppColors.spacingS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppColors.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pod.status.color,
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                      child: Text(
                        pod.status.displayName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Image Count Indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: AppColors.spacingS,
                      right: AppColors.spacingS,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppColors.spacingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppColors.radiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${images.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppColors.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pod.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pod.mall}, ${pod.city}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppColors.spacingS),
                    
                    // Rating
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: pod.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppColors.ratingActive,
                          ),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${pod.reviewCount})',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Price and Book Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RM ${pod.basePrice.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                            Text(
                              'per hour',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppColors.radiusS),
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
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
    final images = pod.images?.isNotEmpty == true 
        ? pod.images! 
        : [pod.imageUrl];

    return Container(
      margin: const EdgeInsets.only(bottom: AppColors.spacingM),
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
      child: InkWell(
        onTap: () => _navigateToPodDetails(pod),
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppColors.spacingM),
          child: Row(
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    child: SafeNetworkImage(
                      imageUrl: images.first,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(AppColors.radiusS),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${images.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: AppColors.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pod.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pod.status.color,
                            borderRadius: BorderRadius.circular(AppColors.radiusM),
                          ),
                          child: Text(
                            pod.status.displayName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${pod.mall}, ${pod.city}',
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
                    
                    // Rating and Features
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: pod.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppColors.ratingActive,
                          ),
                          itemCount: 5,
                          itemSize: 14.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pod.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${pod.reviewCount})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppColors.spacingS),
                    
                    // Features
                    if (pod.features.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: pod.features.take(2).map((feature) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppColors.radiusS),
                            ),
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: AppColors.spacingS),
                    
                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RM ${pod.basePrice.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                            Text(
                              'per hour',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => _navigateToPodDetails(pod),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppColors.spacingM,
                              vertical: AppColors.spacingS,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppColors.radiusS),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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

  Future<void> _showFilterBottomSheet() async {
    await CustomBottomSheets.showCustomBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppColors.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter & Sort',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingL),
            
            // Sort Options
            Text(
              'Sort by',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingM),
            
            Wrap(
              spacing: AppColors.spacingS,
              runSpacing: AppColors.spacingS,
              children: [
                _buildFilterChip('Price: Low to High', false),
                _buildFilterChip('Price: High to Low', false),
                _buildFilterChip('Rating', false),
                _buildFilterChip('Popularity', false),
              ],
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // Price Range
            Text(
              'Price Range',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingM),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      prefixText: 'RM ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppColors.spacingM),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      prefixText: 'RM ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.spacingXL),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Clear All'),
                  ),
                ),
                const SizedBox(width: AppColors.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primaryPurple,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusRound),
      ),
    );
  }

  void _navigateToPodDetails(AvailablePod pod) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodDetailsScreen(pod: pod),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _mallController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
