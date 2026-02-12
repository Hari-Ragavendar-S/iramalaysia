import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_bottom_sheets.dart';

class AdminWebLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int selectedIndex;
  final Function(int) onNavigationChanged;

  const AdminWebLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedIndex,
    required this.onNavigationChanged,
  });

  @override
  State<AdminWebLayout> createState() => _AdminWebLayoutState();
}

class _AdminWebLayoutState extends State<AdminWebLayout> {
  bool _isCollapsed = false;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      title: 'Dashboard',
      route: '/admin/dashboard',
    ),
    AdminMenuItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      title: 'Admins',
      route: '/admin/admins',
    ),
    AdminMenuItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      title: 'Users',
      route: '/admin/users',
    ),
    AdminMenuItem(
      icon: Icons.music_note_outlined,
      activeIcon: Icons.music_note,
      title: 'Buskers',
      route: '/admin/buskers',
    ),
    AdminMenuItem(
      icon: Icons.book_online_outlined,
      activeIcon: Icons.book_online,
      title: 'Bookings',
      route: '/admin/bookings',
    ),
    AdminMenuItem(
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
      title: 'Pods',
      route: '/admin/pods',
    ),
    AdminMenuItem(
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      title: 'Events',
      route: '/admin/events',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Row(
        children: [
          // Sidebar
          if (isDesktop || isTablet)
            _buildSidebar()
          else
            const SizedBox.shrink(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, !isDesktop && !isTablet),
                
                // Content Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(AppColors.spacingL),
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
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Mobile Drawer
      drawer: !isDesktop && !isTablet ? _buildMobileDrawer() : null,
    );
  }

  Widget _buildSidebar() {
    final sidebarWidth = _isCollapsed ? 80.0 : 280.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          right: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.all(AppColors.spacingM),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(AppColors.radiusS),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: AppColors.spacingM),
                  Expanded(
                    child: Text(
                      'Admin Panel',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppColors.spacingM),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = index == widget.selectedIndex;
                
                return _buildMenuItem(item, isSelected, index);
              },
            ),
          ),

          // Collapse Button
          Container(
            padding: const EdgeInsets.all(AppColors.spacingM),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              },
              borderRadius: BorderRadius.circular(AppColors.radiusS),
              child: Container(
                padding: const EdgeInsets.all(AppColors.spacingS),
                child: Row(
                  children: [
                    Icon(
                      _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: AppColors.textSecondary,
                    ),
                    if (!_isCollapsed) ...[
                      const SizedBox(width: AppColors.spacingS),
                      Text(
                        'Collapse',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(AdminMenuItem item, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.spacingS,
        vertical: 2,
      ),
      child: InkWell(
        onTap: () => widget.onNavigationChanged(index),
        borderRadius: BorderRadius.circular(AppColors.radiusS),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppColors.spacingM,
            vertical: AppColors.spacingM,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryGold.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppColors.radiusS),
            border: isSelected 
                ? Border.all(
                    color: AppColors.primaryGold.withOpacity(0.3),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected 
                    ? AppColors.primaryGold 
                    : AppColors.textSecondary,
                size: 20,
              ),
              if (!_isCollapsed) ...[
                const SizedBox(width: AppColors.spacingM),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? AppColors.primaryGold 
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool showMenuButton) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppColors.spacingL),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu Button (Mobile)
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppColors.spacingM),
          ],

          // Page Title
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // User Menu
          _buildUserMenu(),
        ],
      ),
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppColors.spacingM,
          vertical: AppColors.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppColors.radiusRound),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryGold,
              child: Text(
                'A',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppColors.spacingS),
            Text(
              'Admin',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppColors.spacingS),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 16),
              const SizedBox(width: AppColors.spacingS),
              Text(
                'Profile',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 16),
              const SizedBox(width: AppColors.spacingS),
              Text(
                'Settings',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 16, color: AppColors.error),
              const SizedBox(width: AppColors.spacingS),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'logout':
            final shouldLogout = await CommonBottomSheets.showLogoutConfirmation(
              context: context,
            );
            if (shouldLogout == true && mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/admin-login',
                (route) => false,
              );
            }
            break;
        }
      },
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.backgroundCard,
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 120,
            padding: const EdgeInsets.all(AppColors.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGold,
                  AppColors.primaryGold.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppColors.radiusM),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
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
                          'Admin Panel',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Irama1Asia',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppColors.spacingM),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = index == widget.selectedIndex;
                
                return ListTile(
                  leading: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected 
                        ? AppColors.primaryGold 
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? AppColors.primaryGold 
                          : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigationChanged(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String route;

  const AdminMenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
  });
}