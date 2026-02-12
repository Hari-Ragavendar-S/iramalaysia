import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/colors.dart';
import '../../utils/busker_storage.dart';
import '../../models/busker_pod.dart';
import '../../widgets/custom_bottom_sheets.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/safe_network_image.dart';
import '../../services/busker_service.dart';

class BuskerProfileScreen extends StatefulWidget {
  const BuskerProfileScreen({super.key});

  @override
  State<BuskerProfileScreen> createState() => _BuskerProfileScreenState();
}

class _BuskerProfileScreenState extends State<BuskerProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _profileImage;
  List<BuskerPod> _userPods = [];
  Map<String, dynamic>? _buskerProfile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUserPods();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await BuskerService.getProfile();
      setState(() {
        _buskerProfile = profile;
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadUserPods() {
    setState(() {
      _userPods = BuskerStorage.getAllPods();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundPrimary,
          elevation: 0,
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: const Center(
          child: LoadingWidget(message: 'Loading profile...'),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundPrimary,
          elevation: 0,
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Center(
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
                'Failed to load profile',
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
                onPressed: _loadProfile,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isUpdating ? null : _saveProfile,
            icon: _isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryPurple,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                    color: AppColors.primaryPurple,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppColors.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppColors.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.1),
                    AppColors.primaryPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppColors.radiusL),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surfaceLight,
                          backgroundImage: _profileImage != null 
                              ? FileImage(_profileImage!) 
                              : null,
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.primaryPurple,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.backgroundCard,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowMedium,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppColors.spacingM),
                  
                  // Name and Status
                  Text(
                    _nameController.text.isNotEmpty 
                        ? _nameController.text 
                        : 'Your Name',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppColors.spacingS),
                  
                  // Verification Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppColors.spacingM,
                      vertical: AppColors.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppColors.radiusRound),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 16,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: AppColors.spacingS),
                        Text(
                          _getStatusText(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppColors.spacingM),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Events', _userPods.length.toString()),
                      _buildStatItem('Rating', '4.8'),
                      _buildStatItem('Reviews', '24'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // Personal Information Card
            _buildSectionCard(
              'Personal Information',
              Icons.person_outline,
              [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: AppColors.spacingM),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email usually can't be changed
                ),
                const SizedBox(height: AppColors.spacingM),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppColors.spacingM),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: AppColors.spacingM),
                _buildTextField(
                  controller: _bioController,
                  label: 'Bio',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  hintText: 'Tell us about your musical journey...',
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // Performance History Card
            _buildSectionCard(
              'Performance History',
              Icons.history,
              [
                if (_userPods.isEmpty)
                  _buildEmptyState()
                else
                  ..._userPods.map((pod) => _buildEventCard(pod)).toList(),
              ],
            ),
            
            const SizedBox(height: AppColors.spacingL),
            
            // Account Actions
            _buildSectionCard(
              'Account',
              Icons.settings_outlined,
              [
                _buildActionTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    // Navigate to notifications settings
                  },
                ),
                const SizedBox(height: AppColors.spacingS),
                _buildActionTile(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                const SizedBox(height: AppColors.spacingS),
                _buildActionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with your account',
                  onTap: () {
                    // Navigate to help
                  },
                ),
                const SizedBox(height: AppColors.spacingS),
                _buildActionTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: _showLogoutConfirmation,
                  isDestructive: true,
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    final status = _buskerProfile?['verification_status'] ?? 'pending';
    switch (status) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon() {
    final status = _buskerProfile?['verification_status'] ?? 'pending';
    switch (status) {
      case 'verified':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText() {
    final status = _buskerProfile?['verification_status'] ?? 'pending';
    switch (status) {
      case 'verified':
        return 'Verified Busker';
      case 'rejected':
        return 'Verification Failed';
      default:
        return 'Pending Verification';
    }
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon, 
          color: enabled ? AppColors.primaryPurple : AppColors.textTertiary,
          size: 20,
        ),
        labelStyle: GoogleFonts.poppins(
          color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          borderSide: BorderSide(
            color: AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primaryPurple,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          borderSide: BorderSide(
            color: AppColors.borderLight,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          borderSide: BorderSide(
            color: AppColors.borderLight.withOpacity(0.5),
          ),
        ),
        filled: true,
        fillColor: enabled ? AppColors.surfaceLight : AppColors.surfaceLight.withOpacity(0.5),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(AppColors.spacingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppColors.radiusS),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppColors.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingXL),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 40,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: AppColors.spacingM),
          Text(
            'No Performance History',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppColors.spacingS),
          Text(
            'Your performance history will appear here once you start booking pods',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuskerPod pod) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppColors.spacingM),
      padding: const EdgeInsets.all(AppColors.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pod.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppColors.radiusM),
                ),
                child: Text(
                  'Pending Review',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.spacingS),
          _buildEventDetailRow(
            Icons.location_on_outlined,
            '${pod.city} • ${pod.address}',
          ),
          const SizedBox(height: 4),
          _buildEventDetailRow(
            Icons.calendar_today_outlined,
            '${pod.startDate.day}/${pod.startDate.month}/${pod.startDate.year} - ${pod.endDate.day}/${pod.endDate.month}/${pod.endDate.year}',
          ),
          const SizedBox(height: 4),
          _buildEventDetailRow(
            Icons.access_time_outlined,
            '${pod.startTime.format(context)} - ${pod.endTime.format(context)}',
          ),
          if (pod.images?.isNotEmpty == true) ...[
            const SizedBox(height: AppColors.spacingS),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pod.images?.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: AppColors.spacingS),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppColors.radiusS),
                      child: SafeNetworkImage(
                        imageUrl: pod.images![index],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppColors.spacingS),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showImagePickerOptions() async {
    await CustomBottomSheets.showSelectionBottomSheet<ImageSource>(
      context: context,
      title: 'Select Image Source',
      items: [
        SelectionItem<ImageSource>(
          value: ImageSource.camera,
          title: 'Camera',
          subtitle: 'Take a new photo',
          icon: Icons.camera_alt_outlined,
        ),
        SelectionItem<ImageSource>(
          value: ImageSource.gallery,
          title: 'Gallery',
          subtitle: 'Choose from gallery',
          icon: Icons.photo_library_outlined,
        ),
      ],
    ).then((source) {
      if (source != null) {
        _pickProfileImage(source);
      }
    });
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        await CustomBottomSheets.showInfoBottomSheet(
          context: context,
          title: 'Error',
          message: 'Failed to pick image. Please try again.',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await BuskerService.updateProfile({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'bio': _bioController.text,
      });

      if (mounted) {
        await CustomBottomSheets.showInfoBottomSheet(
          context: context,
          title: 'Success',
          message: 'Profile updated successfully!',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
        );
      }
    } catch (e) {
      if (mounted) {
        await CustomBottomSheets.showInfoBottomSheet(
          context: context,
          title: 'Error',
          message: 'Failed to update profile: $e',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await CommonBottomSheets.showLogoutConfirmation(
      context: context,
    );

    if (shouldLogout == true && mounted) {
      // Perform logout
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

}