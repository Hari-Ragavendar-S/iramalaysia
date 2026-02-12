import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';
import 'users_management_screen.dart';
import 'buskers_history_screen.dart';
import 'bookings_management_screen.dart';
import 'admin_pods_management_screen.dart';
import 'events_management_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardScreen(onNavigationChanged: _onNavigationChanged);
      case 1:
        return AdminManagementScreen(onNavigationChanged: _onNavigationChanged);
      case 2:
        return UsersManagementScreen(onNavigationChanged: _onNavigationChanged);
      case 3:
        return BuskersHistoryScreen(onNavigationChanged: _onNavigationChanged);
      case 4:
        return BookingsManagementScreen(onNavigationChanged: _onNavigationChanged);
      case 5:
        return AdminPodsManagementScreen(onNavigationChanged: _onNavigationChanged);
      case 6:
        return EventsManagementScreen(onNavigationChanged: _onNavigationChanged);
      default:
        return AdminDashboardScreen(onNavigationChanged: _onNavigationChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _getCurrentScreen();
  }
}