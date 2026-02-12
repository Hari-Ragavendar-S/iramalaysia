import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../services/admin_service.dart';
import '../../models/admin_models.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'admin_web_layout.dart';

class AdminManagementScreen extends StatefulWidget {
  final Function(int)? onNavigationChanged;
  
  const AdminManagementScreen({
    super.key,
    this.onNavigationChanged,
  });

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<AdminProfile> _admins = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AdminService.getAdmins();
      
      if (mounted) {
        if (result['success']) {
          setState(() {
            _admins = result['data'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load admins';
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

  @override
  Widget build(BuildContext context) {
    return AdminWebLayout(
      title: 'Admin Management',
      selectedIndex: 1,
      onNavigationChanged: widget.onNavigationChanged ?? (index) {},
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: AppColors.spacingL),
        Expanded(child: _buildAdminsList()),
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
                  'Admin Management',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppColors.spacingXS),
                Text(
                  'Manage admin accounts and permissions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddAdminDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Admin'),
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

  Widget _buildAdminsList() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading admins...'),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _loadAdmins,
        ),
      );
    }

    if (_admins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppColors.spacingM),
            Text(
              'No admins found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAdmins,
      color: AppColors.primaryGold,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppColors.spacingL),
        child: ListView.builder(
          itemCount: _admins.length,
          itemBuilder: (context, index) {
            return _buildAdminCard(_admins[index]);
          },
        ),
      ),
    );
  }

  Widget _buildAdminCard(AdminProfile admin) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppColors.spacingL),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGold.withOpacity(0.1),
          child: Text(
            admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGold,
            ),
          ),
        ),
        title: Text(
          admin.name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppColors.spacingXS),
            Text(
              admin.email,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppColors.spacingXS),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppColors.radiusS),
                  ),
                  child: Text(
                    admin.role.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(width: AppColors.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: admin.isActive 
                        ? AppColors.success.withOpacity(0.1) 
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppColors.radiusS),
                  ),
                  child: Text(
                    admin.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: admin.isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAdminAction(value, admin),
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
              value: admin.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    admin.isActive ? Icons.block : Icons.check_circle_outline,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(admin.isActive ? 'Deactivate' : 'Activate'),
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
      ),
    );
  }

  void _handleAdminAction(String action, AdminProfile admin) {
    switch (action) {
      case 'edit':
        _showEditAdminDialog(admin);
        break;
      case 'activate':
      case 'deactivate':
        _toggleAdminStatus(admin);
        break;
      case 'delete':
        _showDeleteConfirmation(admin);
        break;
    }
  }

  void _showAddAdminDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add admin dialog - Coming soon')),
    );
  }

  void _showEditAdminDialog(AdminProfile admin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit admin: ${admin.name} - Coming soon')),
    );
  }

  Future<void> _toggleAdminStatus(AdminProfile admin) async {
    try {
      final result = await AdminService.updateAdmin(
        adminId: admin.id,
        isActive: !admin.isActive,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Admin ${admin.isActive ? 'deactivated' : 'activated'} successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAdmins();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update admin status'),
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

  void _showDeleteConfirmation(AdminProfile admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete "${admin.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAdmin(admin);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAdmin(AdminProfile admin) async {
    try {
      final result = await AdminService.deleteAdmin(admin.id);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAdmins();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete admin'),
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