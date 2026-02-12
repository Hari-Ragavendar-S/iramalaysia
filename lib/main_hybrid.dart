import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen_hybrid.dart';
import 'screens/buskers/pod_search_screen_offline.dart';
import 'screens/buskers/pod_details_screen.dart';
import 'screens/buskers/pod_date_selection_screen_offline.dart';
import 'screens/buskers/pod_time_selection_screen.dart';
import 'screens/buskers/pod_payment_screen.dart';
import 'screens/buskers/pod_receipt_upload_screen.dart';
import 'screens/buskers/busker_bookings_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_main_navigation.dart';
import 'screens/admin/admin_management_screen.dart';
import 'utils/colors.dart';
import 'models/pod_booking.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'presentation/providers/api_provider.dart';

void main() async {
  // Catch all errors during app initialization
  runZonedGuarded(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Set preferred orientations with error handling
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (e) {
        debugPrint('Orientation setting failed: $e');
      }
      
      // Initialize services with error handling
      try {
        await ConnectivityService.initialize();
        ApiService().initialize();
      } catch (e) {
        debugPrint('Service initialization failed: $e');
      }
      
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApiProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ],
          child: const Irama1AsiaHybridApp(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('App initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Run app anyway with minimal setup
      runApp(const SafeIrama1AsiaApp());
    }
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class SafeIrama1AsiaApp extends StatelessWidget {
  const SafeIrama1AsiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Irama1Asia',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: const Color(0xFFD4AF37),
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 64, color: Color(0xFFD4AF37)),
              SizedBox(height: 16),
              Text('Irama1Asia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Safe Mode', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Irama1AsiaHybridApp extends StatelessWidget {
  const Irama1AsiaHybridApp({super.key});

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
        elevatedButtonThemeData: ElevatedButtonThemeData(
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
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
        ),
      ),
      home: const SplashScreenHybrid(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/pod-search': (context) => const PodSearchScreenOffline(),
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
              builder: (context) => PodDateSelectionScreenOffline(pod: pod),
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