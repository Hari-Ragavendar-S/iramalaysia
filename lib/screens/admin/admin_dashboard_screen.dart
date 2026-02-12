import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../services/admin_service.dart';
import '../../models/admin_models.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'admin_web_layout.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigationChanged;
  
  const AdminDashboardScreen({
    super.key,
    this.onNavigationChanged,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AdminService.getDashboardStats();
      
      if (mounted) {
        if (result['success']) {
          setState(() {
            _stats = result['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load dashboard stats';
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
      title: 'Dashboard',
      selectedIndex: 0,
      onNavigationChanged: widget.onNavigationChanged ?? (index) {},
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(message: 'Loading dashboard...'),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _loadDashboardStats,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      color: AppColors.primaryGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppColors.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: AppColors.spacingXL),
            _buildStatsGrid(),
            const SizedBox(height: AppColors.spacingXL),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Admin Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppColors.spacingS),
                Text(
                  'Manage your Irama1Asia platform efficiently',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppColors.spacingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppColors.radiusM),
            ),
            child: const Icon(
              Icons.dashboard,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();

    final statsItems = [
      _StatItem(
        title: 'Total Users',
        value: _stats!.totalUsers.toString(),
        subtitle: '${_stats!.activeUsers} active',
        icon: Icons.people,
        color: AppColors.info,
      ),
      _StatItem(
        title: 'Total Buskers',
        value: _stats!.totalBuskers.toString(),
        subtitle: '${_stats!.activeBuskers} active',
        icon: Icons.music_note,
        color: AppColors.success,
      ),
      _StatItem(
        title: 'Total Bookings',
        value: _stats!.totalBookings.toString(),
        subtitle: 'All time',
        icon: Icons.book_online,
        color: AppColors.warning,
      ),
      _StatItem(
        title: 'Total Events',
        value: _stats!.totalEvents.toString(),
        subtitle: '${_stats!.publishedEvents} published',
        icon: Icons.event,
        color: AppColors.primaryGold,
      ),
      _StatItem(
        title: 'Total Revenue',
        value: 'RM ${_stats!.totalRevenue.toStringAsFixed(2)}',
        subtitle: 'All time',
        icon: Icons.attach_money,
        color: AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 5 : 
                               constraints.maxWidth > 800 ? 3 : 2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppColors.spacingM,
            mainAxisSpacing: AppColors.spacingM,
            childAspectRatio: 1.2,
          ),
          itemCount: statsItems.length,
          itemBuilder: (context, index) {
            return _buildStatCard(statsItems[index]);
          },
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(AppColors.spacingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppColors.spacingS),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppColors.radiusS),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: AppColors.success,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppColors.spacingM),
          Text(
            item.value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppColors.spacingXS),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppColors.spacingXS),
          Text(
            item.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        title: 'Manage Users',
        subtitle: 'View and manage user accounts',
        icon: Icons.people_outline,
        color: AppColors.info,
        onTap: () {
          widget.onNavigationChanged?.call(2);
        },
      ),
      _QuickAction(
        title: 'Verify Bookings',
        subtitle: 'Review pending booking payments',
        icon: Icons.verified_outlined,
        color: AppColors.warning,
        onTap: () {
          widget.onNavigationChanged?.call(4);
        },
      ),
      _QuickAction(
        title: 'Create Event',
        subtitle: 'Add new events to the platform',
        icon: Icons.add_circle_outline,
        color: AppColors.success,
        onTap: () {
          widget.onNavigationChanged?.call(6);
        },
      ),
      _QuickAction(
        title: 'Manage Pods',
        subtitle: 'Add or edit busking pods',
        icon: Icons.store_outlined,
        color: AppColors.primaryGold,
        onTap: () {
          widget.onNavigationChanged?.call(5);
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppColors.spacingM),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppColors.spacingM,
                mainAxisSpacing: AppColors.spacingM,
                childAspectRatio: 3,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                return _buildQuickActionCard(actions[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppColors.spacingL),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppColors.spacingM),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppColors.radiusM),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 28,
              ),
            ),
            const SizedBox(width: AppColors.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    action.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppColors.spacingXS),
                  Text(
                    action.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}