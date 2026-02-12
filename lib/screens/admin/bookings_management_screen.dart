import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import 'admin_web_layout.dart';

class BookingsManagementScreen extends StatefulWidget {
  final Function(int)? onNavigationChanged;
  
  const BookingsManagementScreen({
    super.key,
    this.onNavigationChanged,
  });

  @override
  State<BookingsManagementScreen> createState() => _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminWebLayout(
      title: 'Bookings Management',
      selectedIndex: 4,
      onNavigationChanged: widget.onNavigationChanged ?? (index) {},
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppColors.spacingL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_online_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppColors.spacingM),
            Text(
              'Bookings Management',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppColors.spacingS),
            Text(
              'Coming Soon',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}