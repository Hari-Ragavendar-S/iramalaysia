/// OFFLINE MODE NOTICE
/// 
/// This Flutter app is currently running in OFFLINE MODE.
/// All backend API connections have been disabled.
/// 
/// The app uses:
/// - Mock data from lib/services/mock_data_service.dart
/// - Local storage for data persistence
/// - Simulated API responses for testing
/// 
/// To re-enable backend connection:
/// 1. Update lib/config/api_config.dart with backend URL
/// 2. Update lib/core/constants/app_constants.dart with backend URL
/// 3. Uncomment API service initialization in lib/main.dart
/// 4. Restore original service implementations in lib/data/services/
/// 
/// Backend API URL (when enabled):
/// - Base URL: http://148.135.138.145:8000/api/v1
/// - Uploads: http://148.135.138.145:8000/uploads
/// 
/// Last modified: ${DateTime.now().toIso8601String()}

class OfflineModeNotice {
  static const bool isOfflineMode = true;
  static const String backendUrl = ''; // Empty = Offline
  static const String notice = 'App running in OFFLINE MODE - No backend connection';
  
  static void printNotice() {
    print('═══════════════════════════════════════════════════════');
    print('🔴 OFFLINE MODE ACTIVE');
    print('═══════════════════════════════════════════════════════');
    print('Backend API: DISABLED');
    print('Data Source: Mock Data Service');
    print('Storage: Local Only');
    print('═══════════════════════════════════════════════════════');
  }
}
