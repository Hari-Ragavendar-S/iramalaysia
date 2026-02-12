import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../models/busking_location.dart';

class BuskersLocationScreen extends StatefulWidget {
  const BuskersLocationScreen({super.key});

  @override
  State<BuskersLocationScreen> createState() => _BuskersLocationScreenState();
}

class _BuskersLocationScreenState extends State<BuskersLocationScreen> {
  String? _selectedState;
  String? _selectedCity;
  String? _selectedLocation;
  
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Predefined Malaysian states for dropdown
  final List<String> _malaysianStates = [
    'Kuala Lumpur',
    'Selangor',
    'Pulau Pinang',
    'Perak',
    'Johor',
    'Melaka',
    'Negeri Sembilan',
    'Kedah',
    'Kelantan',
    'Terengganu',
    'Pahang',
    'Sabah',
    'Sarawak',
    'Labuan',
  ];

  // Predefined cities for major states
  final Map<String, List<String>> _citiesByState = {
    'Kuala Lumpur': ['Kuala Lumpur', 'Bukit Bintang', 'Mid Valley City'],
    'Selangor': ['Petaling Jaya', 'Shah Alam', 'Bandar Sunway', 'Putrajaya'],
    'Pulau Pinang': ['George Town', 'Bayan Lepas'],
    'Perak': ['Ipoh', 'Taiping'],
    'Johor': ['Johor Bahru'],
    'Melaka': ['Bandar Hilir'],
    'Negeri Sembilan': ['Seremban'],
    'Kedah': ['Alor Setar', 'Sungai Petani'],
    'Kelantan': ['Kota Bharu'],
    'Terengganu': ['Kuala Terengganu'],
    'Pahang': ['Kuantan'],
    'Sabah': ['Kota Kinabalu'],
    'Sarawak': ['Kuching'],
    'Labuan': ['Victoria'],
  };

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    super.dispose();
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
              'Select Location',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppColors.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your busking location',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppColors.spacingS),
              Text(
                'Select the state, city, and specific location where you want to perform.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: AppColors.spacingXL),
            
            // State Selection
            _buildLocationCard(
              title: 'State',
              subtitle: 'Select your state',
              icon: Icons.map_outlined,
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null; // Reset city when state changes
                    _selectedLocation = null; // Reset location
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Choose state',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppColors.spacingM,
                    vertical: AppColors.spacingM,
                  ),
                ),
                items: _malaysianStates.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(
                      state,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // City Selection
            _buildLocationCard(
              title: 'City',
              subtitle: 'Select your city',
              icon: Icons.location_city_outlined,
              child: _selectedState == null
                  ? Container(
                      padding: const EdgeInsets.all(AppColors.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppColors.radiusM),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        'Please select a state first',
                        style: GoogleFonts.poppins(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedCity,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          _selectedLocation = null; // Reset location
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Choose city',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppColors.radiusM),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppColors.spacingM,
                          vertical: AppColors.spacingM,
                        ),
                      ),
                      items: (_citiesByState[_selectedState] ?? []).map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // Location/Venue Input
            _buildLocationCard(
              title: 'Venue/Location',
              subtitle: 'Enter specific venue name',
              icon: Icons.place_outlined,
              child: TextFormField(
                controller: _locationController,
                enabled: _selectedCity != null,
                decoration: InputDecoration(
                  hintText: _selectedCity == null 
                      ? 'Please select city first'
                      : 'e.g., Suria KLCC, Pavilion KL, etc.',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppColors.spacingM,
                    vertical: AppColors.spacingM,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value.isNotEmpty ? value : null;
                  });
                },
              ),
            ),
            
            const Spacer(),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue() ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppColors.spacingL),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Continue to Pod Search',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingL),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppColors.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppColors.spacingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppColors.spacingM),
          child,
        ],
      ),
    );
  }

  bool _canContinue() {
    return _selectedState != null && 
           _selectedCity != null && 
           _selectedLocation != null &&
           _selectedLocation!.isNotEmpty;
  }

  void _onContinue() {
    if (_canContinue()) {
      // Create a manual location object
      final manualLocation = BuskingLocation(
        id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
        locationName: _selectedLocation!,
        locationType: 'Manual Entry',
        state: _selectedState!,
        city: _selectedCity!,
        fullAddress: '$_selectedLocation, $_selectedCity, $_selectedState',
        indoorOutdoor: 'Unknown',
        buskingAreaDescription: 'User specified location',
        crowdType: 'Mixed crowd',
        suitableForBusking: 'Yes',
        remarks: 'Manually entered by user',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Navigate to pod search with the manual location
      Navigator.pushNamed(
        context,
        '/pod-search',
        arguments: {
          'selectedLocation': manualLocation,
          'isManualEntry': true,
        },
      );
    }
  }
}