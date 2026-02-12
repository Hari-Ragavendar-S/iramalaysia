/// # Flutter API Integration Architecture Guide
/// 
/// This file provides comprehensive documentation and examples for using
/// the Irama1Asia Flutter API integration architecture.
/// 
/// ## Architecture Overview
/// 
/// The API integration follows clean architecture principles with:
/// - **Core Layer**: API client, interceptors, error handling, storage
/// - **Data Layer**: Services, repositories, models
/// - **Presentation Layer**: Providers, state management
/// 
/// ## Base Configuration
/// 
/// Base URL: http://148.135.138.145:8000
/// API Prefix: /api/v1/
/// 
/// ## Quick Start Examples

library api_integration_guide;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/busker_repository.dart';
import '../../data/repositories/pod_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/upload_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../presentation/providers/api_provider.dart';

/// ## 1. BASIC SETUP
/// 
/// ### Initialize API Provider in main.dart
/// 
/// ```dart
/// void main() {
///   runApp(
///     MultiProvider(
///       providers: [
///         ChangeNotifierProvider(create: (_) => ApiProvider()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// }
/// ```

/// ## 2. AUTHENTICATION EXAMPLES
class AuthExamples {
  static void demonstrateAuthUsage() {
    /// ### Login Example
    /// ```dart
    /// final apiProvider = context.read<ApiProvider>();
    /// 
    /// try {
    ///   await apiProvider.login(
    ///     email: 'user@example.com',
    ///     password: 'password123',
    ///   );
    ///   // Login successful - navigate to home
    /// } catch (e) {
    ///   // Handle error - show error message
    ///   print('Login failed: ${apiProvider.errorMessage}');
    /// }
    /// ```
    
    /// ### Register Example
    /// ```dart
    /// try {
    ///   await apiProvider.register(
    ///     email: 'newuser@example.com',
    ///     password: 'password123',
    ///     fullName: 'John Doe',
    ///     phone: '+60123456789',
    ///     userType: 'user', // or 'busker'
    ///   );
    ///   // Registration successful
    /// } catch (e) {
    ///   print('Registration failed: ${apiProvider.errorMessage}');
    /// }
    /// ```
    
    /// ### Auto Login Check
    /// ```dart
    /// void checkAutoLogin() async {
    ///   final apiProvider = context.read<ApiProvider>();
    ///   final isLoggedIn = await apiProvider.autoLogin();
    ///   
    ///   if (isLoggedIn) {
    ///     // Navigate to home screen
    ///   } else {
    ///     // Navigate to login screen
    ///   }
    /// }
    /// ```
  }
}

/// ## 3. REPOSITORY USAGE EXAMPLES
class RepositoryExamples {
  /// ### User Profile Management
  static void demonstrateUserRepository() {
    /// ```dart
    /// final userRepository = UserRepository();
    /// 
    /// // Get user profile
    /// final profileResponse = await userRepository.getProfile();
    /// if (profileResponse.success) {
    ///   final profile = profileResponse.data;
    ///   print('User: ${profile?.fullName}');
    /// }
    /// 
    /// // Update profile
    /// await userRepository.updateProfile(
    ///   fullName: 'Updated Name',
    ///   phone: '+60123456789',
    /// );
    /// 
    /// // Get cached profile (offline)
    /// final cachedProfile = await userRepository.getCachedUserProfile();
    /// ```
  }
  
  /// ### Pod Booking Management
  static void demonstratePodRepository() {
    /// ```dart
    /// final podRepository = PodRepository();
    /// 
    /// // Search pods
    /// final podsResponse = await podRepository.searchPods(
    ///   location: 'Kuala Lumpur',
    ///   minPrice: 10.0,
    ///   maxPrice: 50.0,
    /// );
    /// 
    /// // Get pod details
    /// final podDetails = await podRepository.getPodDetails('pod_id');
    /// 
    /// // Create booking
    /// final bookingResponse = await podRepository.createBooking(
    ///   podId: 'pod_id',
    ///   date: '2024-12-25',
    ///   startTime: '10:00',
    ///   endTime: '12:00',
    ///   notes: 'Music performance',
    /// );
    /// 
    /// // Get my bookings
    /// final myBookings = await podRepository.getMyBookings();
    /// ```
  }
  
  /// ### File Upload Management
  static void demonstrateUploadRepository() {
    /// ```dart
    /// final uploadRepository = UploadRepository();
    /// 
    /// // Upload profile image
    /// final imageFile = File('path/to/image.jpg');
    /// final uploadResponse = await uploadRepository.uploadProfileImage(imageFile);
    /// 
    /// if (uploadResponse.success) {
    ///   final imageUrl = uploadResponse.data?.fileUrl;
    ///   print('Image uploaded: $imageUrl');
    /// }
    /// 
    /// // Upload with progress tracking
    /// await uploadRepository.uploadImage(
    ///   imageFile: imageFile,
    ///   category: 'payment_proof',
    ///   onProgress: (sent, total) {
    ///     final progress = (sent / total * 100).toInt();
    ///     print('Upload progress: $progress%');
    ///   },
    /// );
    /// ```
  }
}

/// ## 4. ERROR HANDLING EXAMPLES
class ErrorHandlingExamples {
  /// ### Basic Error Handling
  static void demonstrateErrorHandling() {
    /// ```dart
    /// try {
    ///   final response = await podRepository.createBooking(/*...*/);
    ///   
    ///   if (response.success) {
    ///     // Handle success
    ///     final booking = response.data;
    ///   } else {
    ///     // Handle API error
    ///     showErrorDialog(response.error ?? 'Unknown error');
    ///   }
    /// } catch (e) {
    ///   // Handle network/unexpected errors
    ///   showErrorDialog('Network error: $e');
    /// }
    /// ```
  }
  
  /// ### Using ApiProvider Error State
  static Widget buildWithErrorHandling() {
    return Consumer<ApiProvider>(
      builder: (context, apiProvider, child) {
        if (apiProvider.hasError) {
          return Column(
            children: [
              Text('Error: ${apiProvider.errorMessage}'),
              ElevatedButton(
                onPressed: apiProvider.clearError,
                child: Text('Dismiss'),
              ),
            ],
          );
        }
        
        if (apiProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return Text('Content loaded successfully');
      },
    );
  }
}

/// ## 5. OFFLINE SUPPORT EXAMPLES
class OfflineSupportExamples {
  /// ### Cached Data Usage
  static void demonstrateCachedData() {
    /// ```dart
    /// // Check cached data first
    /// final cachedProfile = await userRepository.getCachedUserProfile();
    /// if (cachedProfile != null) {
    ///   // Use cached data immediately
    ///   displayProfile(cachedProfile);
    /// }
    /// 
    /// // Then fetch fresh data
    /// try {
    ///   final freshProfile = await userRepository.getProfile();
    ///   if (freshProfile.success) {
    ///     // Update UI with fresh data
    ///     displayProfile(freshProfile.data);
    ///   }
    /// } catch (e) {
    ///   // Network error - continue using cached data
    ///   print('Using cached data due to network error');
    /// }
    /// ```
  }
  
  /// ### Network Status Check
  static void demonstrateNetworkCheck() {
    /// ```dart
    /// final apiProvider = context.read<ApiProvider>();
    /// final isOnline = await apiProvider.checkNetworkConnectivity();
    /// 
    /// if (isOnline) {
    ///   // Perform online operations
    ///   await syncData();
    /// } else {
    ///   // Show offline mode UI
    ///   showOfflineMessage();
    /// }
    /// ```
  }
}

/// ## 6. ADMIN PANEL INTEGRATION
class AdminExamples {
  /// ### Admin Dashboard
  static void demonstrateAdminUsage() {
    /// ```dart
    /// final adminRepository = AdminRepository();
    /// 
    /// // Get dashboard stats
    /// final statsResponse = await adminRepository.getDashboardStats();
    /// if (statsResponse.success) {
    ///   final stats = statsResponse.data;
    ///   print('Total Users: ${stats?.totalUsers}');
    ///   print('Pending Bookings: ${stats?.pendingBookings}');
    /// }
    /// 
    /// // Verify booking
    /// await adminRepository.verifyBooking(
    ///   bookingId: 'booking_id',
    ///   approved: true,
    ///   notes: 'Payment verified',
    /// );
    /// 
    /// // Get pending buskers
    /// final pendingBuskers = await adminRepository.getPendingBuskers();
    /// ```
  }
}

/// ## 7. COMPLETE WIDGET EXAMPLE
class ApiIntegrationWidget extends StatefulWidget {
  @override
  _ApiIntegrationWidgetState createState() => _ApiIntegrationWidgetState();
}

class _ApiIntegrationWidgetState extends State<ApiIntegrationWidget> {
  final PodRepository _podRepository = PodRepository();
  List<dynamic> _pods = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPods();
  }

  Future<void> _loadPods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _podRepository.getAllPods();
      
      if (response.success && response.data != null) {
        setState(() {
          _pods = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load pods';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadPods,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _pods.length,
      itemBuilder: (context, index) {
        final pod = _pods[index];
        return ListTile(
          title: Text(pod.name ?? 'Unknown Pod'),
          subtitle: Text(pod.location ?? 'Unknown Location'),
          trailing: Text('RM ${pod.pricePerHour ?? 0}/hr'),
          onTap: () => _showPodDetails(pod),
        );
      },
    );
  }

  void _showPodDetails(dynamic pod) {
    // Navigate to pod details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodDetailsScreen(podId: pod.id),
      ),
    );
  }
}

class PodDetailsScreen extends StatelessWidget {
  final String podId;

  const PodDetailsScreen({Key? key, required this.podId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pod Details')),
      body: FutureBuilder(
        future: PodRepository().getPodDetails(podId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final response = snapshot.data;
          if (response?.success != true || response?.data == null) {
            return Center(child: Text('Pod not found'));
          }

          final pod = response!.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pod.name ?? 'Unknown Pod',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(pod.description ?? 'No description'),
                SizedBox(height: 16),
                Text('Location: ${pod.location ?? 'Unknown'}'),
                Text('Price: RM ${pod.pricePerHour ?? 0}/hour'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _bookPod(context, pod),
                  child: Text('Book This Pod'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _bookPod(BuildContext context, dynamic pod) {
    // Navigate to booking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(pod: pod),
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  final dynamic pod;

  const BookingScreen({Key? key, required this.pod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Pod')),
      body: Center(
        child: Text('Booking form for ${pod.name}'),
      ),
    );
  }
}

/// ## 8. BEST PRACTICES
/// 
/// ### Repository Pattern
/// - Always use repositories instead of services directly in UI
/// - Repositories handle caching and business logic
/// - Services handle pure API communication
/// 
/// ### Error Handling
/// - Always check response.success before using response.data
/// - Handle both API errors and network exceptions
/// - Provide meaningful error messages to users
/// 
/// ### Caching Strategy
/// - Use cached data for immediate UI updates
/// - Fetch fresh data in background
/// - Clear cache when data becomes stale
/// 
/// ### Loading States
/// - Show loading indicators during API calls
/// - Disable buttons to prevent multiple submissions
/// - Provide retry mechanisms for failed requests
/// 
/// ### Security
/// - Never store sensitive data in plain text
/// - Use SecureStorage for tokens and credentials
/// - Implement proper token refresh logic
/// 
/// ## 9. TESTING EXAMPLES
/// 
/// ### Unit Testing Repositories
/// ```dart
/// void main() {
///   group('AuthRepository Tests', () {
///     late AuthRepository authRepository;
///     
///     setUp(() {
///       authRepository = AuthRepository();
///     });
///     
///     test('should login successfully with valid credentials', () async {
///       final response = await authRepository.login(
///         email: 'test@example.com',
///         password: 'password123',
///       );
///       
///       expect(response.success, true);
///       expect(response.data, isNotNull);
///     });
///   });
/// }
/// ```
/// 
/// ### Widget Testing with Providers
/// ```dart
/// void main() {
///   testWidgets('should display pods list', (WidgetTester tester) async {
///     await tester.pumpWidget(
///       MultiProvider(
///         providers: [
///           ChangeNotifierProvider(create: (_) => ApiProvider()),
///         ],
///         child: MaterialApp(
///           home: ApiIntegrationWidget(),
///         ),
///       ),
///     );
///     
///     expect(find.byType(CircularProgressIndicator), findsOneWidget);
///     
///     await tester.pumpAndSettle();
///     
///     expect(find.byType(ListTile), findsWidgets);
///   });
/// }
/// ```