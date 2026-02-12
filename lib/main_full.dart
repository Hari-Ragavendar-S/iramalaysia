import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/buskers/pod_search_screen.dart';
import 'screens/buskers/pod_details_screen.dart';
import 'screens/buskers/pod_date_selection_screen.dart';
import 'screens/buskers/pod_time_selection_screen.dart';
import 'screens/buskers/pod_payment_screen.dart';
import 'screens/buskers/pod_receipt_upload_screen.dart';
import 'screens/buskers/busker_bookings_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_main_navigation.dart';
import 'screens/admin/admin_management_screen.dart';
import 'utils/image_cache_manager.dart';
import 'utils/colors.dart';
import 'models/pod_booking.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  ApiService().initialize();
  
  // Configure image cache
  ImageCacheManager.configureImageCache();
  
  runApp(const Irama1AsiaApp());
}

class Irama1AsiaApp extends StatelessWidget {
  const Irama1AsiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irama1Asia',
      theme: ThemeData(
        // Use Poppins font throughout the app
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Primary color scheme
        primarySwatch: MaterialColor(
          0xFFD4AF37,
          <int, Color>{
            50: AppColors.secondaryGold.withOpacity(0.1),
            100: AppColors.secondaryGold.withOpacity(0.2),
            200: AppColors.secondaryGold.withOpacity(0.3),
            300: AppColors.secondaryGold.withOpacity(0.4),
            400: AppColors.secondaryGold.withOpacity(0.6),
            500: AppColors.primaryGold,
            600: AppColors.darkContrastGold,
            700: AppColors.darkContrastGold.withOpacity(0.8),
            800: AppColors.darkContrastGold.withOpacity(0.9),
            900: AppColors.darkContrastGold,
          },
        ),
        
        primaryColor: AppColors.primaryGold,
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        
        // Color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGold,
          brightness: Brightness.light,
          primary: AppColors.primaryGold,
          secondary: AppColors.secondaryBlue,
          surface: AppColors.backgroundCard,
          background: AppColors.backgroundPrimary,
          error: AppColors.error,
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundPrimary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
        ),
        
        // Card theme
        cardTheme: CardTheme(
          color: AppColors.backgroundCard,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: AppColors.shadowMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            side: const BorderSide(
              color: AppColors.primaryGold,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGold,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
        ),
        
        // Bottom navigation bar theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundCard,
          selectedItemColor: AppColors.primaryGold,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        
        // Tab bar theme
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          indicator: BoxDecoration(
            color: AppColors.primaryGold,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Chip theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedColor: AppColors.primaryGold,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        // Divider theme
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
        
        // Progress indicator theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGold,
        ),
        
        // Snack bar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/pod-search': (context) => const PodSearchScreen(),
        '/busker-bookings': (context) => const BuskerBookingsScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminMainNavigation(),
        '/admin-management': (context) => const AdminManagementScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/pod-details':
            final pod = settings.arguments as AvailablePod;
            return MaterialPageRoute(
              builder: (context) => PodDetailsScreen(pod: pod),
            );
          case '/pod-date-selection':
            final pod = settings.arguments as AvailablePod;
            return MaterialPageRoute(
              builder: (context) => PodDateSelectionScreen(pod: pod),
            );
          case '/pod-time-selection':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PodTimeSelectionScreen(
                pod: args['pod'] as AvailablePod,
                selectedDate: args['selectedDate'] as DateTime,
              ),
            );
          case '/pod-payment':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PodPaymentScreen(
                pod: args['pod'] as AvailablePod,
                selectedDate: args['selectedDate'] as DateTime,
                selectedSlots: args['selectedSlots'] as List<TimeSlot>,
                totalAmount: args['totalAmount'] as double,
              ),
            );
          case '/pod-receipt-upload':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PodReceiptUploadScreen(
                bookingId: args['bookingId'] as String,
                podName: args['podName'] as String,
                mall: args['mall'] as String,
                city: args['city'] as String,
                selectedDate: args['selectedDate'] as DateTime,
                selectedSlots: args['selectedSlots'] as List<String>,
                totalAmount: args['totalAmount'] as double,
                referenceNo: args['referenceNo'] as String,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}