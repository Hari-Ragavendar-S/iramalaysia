import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../services/admin_service.dart';
import '../../models/admin_models.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_bottom_sheets.dart';
import 'admin_web_layout.dart';

class AdminPodsManagementScreen extends StatefulWidget {
  final Function(int)? onNavigationChanged;
  
  const AdminPodsManagementScreen({
    super.key,
    this.onNavigationChanged,
  });

  @override
  State<AdminPodsManagementScreen> createState() => _AdminPodsManagementScreenState();
}

class _AdminPodsManagementScreenState extends State<AdminPodsManagementScreen> {
  List<AdminPod> _pods = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCity;
  bool? _activeFilter;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AdminService.getAllPods(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        city: _selectedCity,
        isActive: _activeFilter,
      );
      
      if (mounted) {
        if (result['success']) {
          setState(() {
            _pods = result['data'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load pods';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPods();
  }

  void _onFilterChanged() {
    _loadPods();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWebLayout(
      title: 'Pods Management',
      selectedIndex: 5,
      onNavigationChanged: widget.onNavigationChanged ?? (index) {},
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AppColors.spacingL),
        _buildFilters(),
        const SizedBox(height: AppColors.spacingL),
        Expanded(child: _buildPodsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppColors.spacingL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pods Management',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppColors.spacingXS),
                Text(
                  'Manage busking pods across all locations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreatePodDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Pod'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppColors.spacingL,
                vertical: AppColors.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusS),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppColors.spacingL),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search pods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
                filled: true,
                fillColor: AppColors.backgroundCard,
              ),
            ),
          ),
          const SizedBox(width: AppColors.spacingM),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCity,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
                _onFilterChanged();
              },
              decoration: InputDecoration(
                hintText: 'Filter by city',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                filled: true,
                fillColor: AppColors.backgroundCard,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Cities')),
                DropdownMenuItem(value: 'Kuala Lumpur', child: Text('Kuala Lumpur')),
                DropdownMenuItem(value: 'Selangor', child: Text('Selangor')),
                DropdownMenuItem(value: 'Penang', child: Text('Penang')),
              ],
            ),
          ),
          const SizedBox(width: AppColors.spacingM),
          Expanded(
            child: DropdownButtonFormField<bool?>(
              value: _activeFilter,
              onChanged: (value) {
                setState(() {
                  _activeFilter = value;
                });
                _onFilterChanged();
              },
              decoration: InputDecoration(
                hintText: 'Filter by status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                filled: true,
                fillColor: AppColors.backgroundCard,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: true, child: Text('Active')),
                DropdownMenuItem(value: false, child: Text('Inactive')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodsList() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading pods...'),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _loadPods,
        ),
      );
    }

    if (_pods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppColors.spacingM),
            Text(
              'No pods found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppColors.spacingS),
            Text(
              'Add your first pod to get started',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPods,
      color: AppColors.primaryGold,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppColors.spacingL),
        child: ListView.builder(
          itemCount: _pods.length,
          itemBuilder: (context, index) {
            return _buildPodCard(_pods[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPodCard(AdminPod pod) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppColors.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppColors.spacingL),
        child: Row(
          children: [
            // Pod Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppColors.radiusM),
                image: pod.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(pod.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: pod.imageUrl == null
                  ? Icon(
                      Icons.store,
                      color: AppColors.textTertiary,
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: AppColors.spacingM),
            
            // Pod Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pod.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusBadge(pod.isActive),
                    ],
                  ),
                  const SizedBox(height: AppColors.spacingXS),
                  Text(
                    '${pod.mall}, ${pod.city}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppColors.spacingXS),
                  Text(
                    'RM ${pod.basePrice.toStringAsFixed(2)}/hour',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  if (pod.features.isNotEmpty) ...[
                    const SizedBox(height: AppColors.spacingXS),
                    Wrap(
                      spacing: AppColors.spacingXS,
                      children: pod.features.take(3).map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppColors.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppColors.radiusS),
                          ),
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) => _handlePodAction(value, pod),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: pod.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        pod.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(pod.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppColors.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppColors.radiusS),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  void _handlePodAction(String action, AdminPod pod) {
    switch (action) {
      case 'edit':
        _showEditPodDialog(pod);
        break;
      case 'activate':
      case 'deactivate':
        _togglePodStatus(pod);
        break;
      case 'delete':
        _showDeleteConfirmation(pod);
        break;
    }
  }

  void _showCreatePodDialog() {
    // TODO: Implement create pod dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create pod dialog - Coming soon')),
    );
  }

  void _showEditPodDialog(AdminPod pod) {
    // TODO: Implement edit pod dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit pod: ${pod.name} - Coming soon')),
    );
  }

  Future<void> _togglePodStatus(AdminPod pod) async {
    try {
      final result = await AdminService.updatePod(
        podId: pod.id,
        isActive: !pod.isActive,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pod ${pod.isActive ? 'deactivated' : 'activated'} successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _loadPods();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update pod status'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(AdminPod pod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pod'),
        content: Text('Are you sure you want to delete "${pod.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePod(pod);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePod(AdminPod pod) async {
    try {
      final result = await AdminService.deletePod(pod.id);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pod deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadPods();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete pod'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}