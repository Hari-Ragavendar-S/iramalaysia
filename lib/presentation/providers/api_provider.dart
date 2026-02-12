import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/user_service.dart';
import '../../data/services/busker_service.dart';
import '../../data/services/pod_service.dart';
import '../../data/services/event_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/upload_service.dart';
import '../../data/services/admin_service.dart';
import '../../core/api/api_response.dart';
import '../../core/error/error_handler.dart';

class ApiProvider extends ChangeNotifier {
  // Services
  final AuthRepository _authRepository = AuthRepository();
  final UserService _userService = UserService();
  final BuskerService _buskerService = BuskerService();
  final PodService _podService = PodService();
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();
  final UploadService _uploadService = UploadService();
  final AdminService _adminService = AdminService();

  // Loading States
  bool _isLoading = false;
  bool _isAuthLoading = false;
  bool _isUploadLoading = false;

  // Error State
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading;
  bool get isUploadLoading => _isUploadLoading;
  String? get errorMessage => _errorMessage;

  // Auth Repository Getters
  AuthRepository get authRepository => _authRepository;
  UserService get userService => _userService;
  BuskerService get buskerService => _buskerService;
  PodService get podService => _podService;
  EventService get eventService => _eventService;
  LocationService get locationService => _locationService;
  UploadService get uploadService => _uploadService;
  AdminService get adminService => _adminService;

  // Loading State Management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthLoading(bool loading) {
    _isAuthLoading = loading;
    notifyListeners();
  }

  void _setUploadLoading(bool loading) {
    _isUploadLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Generic API Call Wrapper
  Future<T> _executeApiCall<T>(
    Future<ApiResponse<T>> Function() apiCall, {
    bool showLoading = true,
    bool isAuth = false,
    bool isUpload = false,
  }) async {
    try {
      // Clear previous error
      _setError(null);

      // Set loading state
      if (showLoading) {
        if (isAuth) {
          _setAuthLoading(true);
        } else if (isUpload) {
          _setUploadLoading(true);
        } else {
          _setLoading(true);
        }
      }

      // Execute API call
      final response = await apiCall();

      // Handle response
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final error = response.error ?? 'Unknown error occurred';
        _setError(error);
        throw Exception(error);
      }
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      _setError(errorMessage);
      ErrorHandler.logError('ApiProvider', e);
      rethrow;
    } finally {
      // Clear loading state
      if (showLoading) {
        if (isAuth) {
          _setAuthLoading(false);
        } else if (isUpload) {
          _setUploadLoading(false);
        } else {
          _setLoading(false);
        }
      }
    }
  }

  // Authentication Methods
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _executeApiCall(
      () => _authRepository.login(email: email, password: password),
      isAuth: true,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String userType = 'user',
  }) async {
    await _executeApiCall(
      () => _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        userType: userType,
      ),
      isAuth: true,
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  Future<bool> autoLogin() async {
    return await _authRepository.autoLogin();
  }

  // Health Check
  Future<bool> healthCheck() async {
    try {
      return await _authRepository.healthCheck();
    } catch (e) {
      ErrorHandler.logError('ApiProvider.healthCheck', e);
      return false;
    }
  }

  // Error Handling Helpers
  void handleApiError(dynamic error) {
    final errorMessage = ErrorHandler.getErrorMessage(error);
    _setError(errorMessage);
    ErrorHandler.logError('ApiProvider', error);
  }

  // Retry Mechanism
  Future<T> retryApiCall<T>(
    Future<T> Function() apiCall, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await apiCall();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  // Batch Operations
  Future<List<T>> executeBatchApiCalls<T>(
    List<Future<ApiResponse<T>> Function()> apiCalls, {
    bool stopOnFirstError = false,
  }) async {
    final results = <T>[];
    
    for (final apiCall in apiCalls) {
      try {
        final result = await _executeApiCall(apiCall, showLoading: false);
        results.add(result);
      } catch (e) {
        if (stopOnFirstError) {
          rethrow;
        }
        // Continue with next call if not stopping on error
        ErrorHandler.logError('ApiProvider.batchCall', e);
      }
    }
    
    return results;
  }

  // Network Status Check
  Future<bool> checkNetworkConnectivity() async {
    try {
      return await healthCheck();
    } catch (e) {
      return false;
    }
  }

  // Cache Management
  void clearAllCaches() {
    // Clear any in-memory caches here
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

// Extension for easier error handling in UI
extension ApiProviderExtension on ApiProvider {
  bool get hasError => errorMessage != null;
  
  void showError(String message) {
    _setError(message);
  }
  
  void showSuccess(String message) {
    // You can implement a success message system here
    _setError(null);
  }
}