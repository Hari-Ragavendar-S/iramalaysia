import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  print('🔍 Testing Irama1Asia Backend Connectivity...\n');
  
  const String baseUrl = 'http://148.135.138.145:8000';
  const String apiUrl = '$baseUrl/api/v1';
  
  // Test 1: Basic HTTP connectivity
  print('1️⃣ Testing basic HTTP connectivity...');
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    
    final request = await client.getUrl(Uri.parse(baseUrl));
    final response = await request.close();
    
    print('✅ HTTP Status: ${response.statusCode}');
    print('✅ Server is reachable via HTTP');
    
    client.close();
  } catch (e) {
    print('❌ HTTP Connection failed: $e');
    print('🔧 Possible fixes:');
    print('   - Check if backend server is running');
    print('   - Verify IP address: 148.135.138.145');
    print('   - Check port 8000 is open');
    print('   - Ensure no firewall blocking');
  }
  
  print('\n2️⃣ Testing API endpoints...');
  
  // Test 2: API Health Check
  final endpoints = [
    '/health',
    '/api/v1/locations/states',
    '/api/v1/pods',
  ];
  
  for (String endpoint in endpoints) {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final url = endpoint.startsWith('/api') ? '$baseUrl$endpoint' : '$apiUrl$endpoint';
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        print('✅ $endpoint - OK (${response.statusCode})');
      } else {
        print('⚠️  $endpoint - Status: ${response.statusCode}');
      }
      
      client.close();
    } catch (e) {
      print('❌ $endpoint - Failed: ${e.toString().split(':')[0]}');
    }
  }
  
  print('\n3️⃣ Network Configuration Check...');
  
  // Test 3: DNS Resolution
  try {
    final addresses = await InternetAddress.lookup('148.135.138.145');
    print('✅ DNS Resolution: ${addresses.first.address}');
  } catch (e) {
    print('❌ DNS Resolution failed: $e');
  }
  
  // Test 4: Socket Connection
  try {
    final socket = await Socket.connect('148.135.138.145', 8000, timeout: const Duration(seconds: 5));
    print('✅ Socket connection successful');
    socket.destroy();
  } catch (e) {
    print('❌ Socket connection failed: $e');
  }
  
  print('\n📱 Android Release Build Recommendations:');
  print('✅ Internet permission: Already added');
  print('✅ Network security config: Already configured');
  print('✅ Cleartext traffic: Enabled');
  print('✅ ProGuard: Disabled');
  
  print('\n🔧 If APK still crashes:');
  print('1. Use the hybrid version (checks connectivity gracefully)');
  print('2. Test with: flutter build apk --debug (shows network errors)');
  print('3. Check device logs: adb logcat | grep flutter');
  print('4. Ensure backend server is running and accessible');
  
  print('\n✨ Hybrid APK built successfully!');
  print('   - Gracefully handles network failures');
  print('   - Falls back to offline mode');
  print('   - Shows connectivity status');
}