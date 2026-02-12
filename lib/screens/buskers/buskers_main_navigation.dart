import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'buskers_home_screen.dart';
import 'busker_pod_form_screen.dart';
import 'busker_profile_screen.dart';

class BuskersMainNavigation extends StatefulWidget {
  const BuskersMainNavigation({super.key});

  @override
  State<BuskersMainNavigation> createState() => _BuskersMainNavigationState();
}

class _BuskersMainNavigationState extends State<BuskersMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BuskersHomeScreen(),
    const BuskerPodFormScreen(),
    const BuskerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.softGoldHighlight.withOpacity(0.3),
              AppColors.gradientEnd.withOpacity(0.5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryGold,
          unselectedItemColor: AppColors.primaryGold.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Pod Form',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}