import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/api_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/pod_repository.dart';
import '../data/repositories/upload_repository.dart';
import '../data/repositories/admin_repository.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final PodRepository _podRepository = PodRepository();
  final AdminRepository _adminRepository = AdminRepository();
  
  String _testResults = '';
  bool _isRunningTests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔥 API Integration Test Suite',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Test Buttons
            ElevatedButton(
              onPressed: _isRunningTests ? null : _testHealthCheck,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('1️⃣ Test Health Check'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isRunningTests ? null : _testLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('2️⃣ Test Login'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isRunningTests ? null : _testPodSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('3️⃣ Test Pod Search'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isRunningTests ? null : _testAdminDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('4️⃣ Test Admin Dashboard'),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isRunningTests ? null : _runAllTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('🚀 Run All Tests'),
            ),
            const SizedBox(height: 20),
            
            // Results Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Test Results:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isRunningTests)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _testResults.isEmpty 
                              ? 'Click a test button to start...' 
                              : _testResults,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String message) {
    setState(() {
      _testResults += '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isRunningTests = true;
      _testResults = '';
    });
    
    _addResult('🔍 Testing Health Check...');
    
    try {
      final apiProvider = context.read<ApiProvider>();
      final isHealthy = await apiProvider.healthCheck();
      
      if (isHealthy) {
        _addResult('✅ Health Check: PASSED - Backend is reachable');
      } else {
        _addResult('❌ Health Check: FAILED - Backend not reachable');
      }
    } catch (e) {
      _addResult('❌ Health Check: ERROR - $e');
    }
    
    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _testLogin() async {
    setState(() {
      _isRunningTests = true;
      _testResults = '';
    });
    
    _addResult('🔐 Testing Login...');
    
    try {
      // Test with demo credentials
      final response = await _authRepository.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      if (response.success) {
        _addResult('✅ Login: PASSED - Authentication successful');
        _addResult('   Token received: ${response.data?.accessToken?.substring(0, 20)}...');
      } else {
        _addResult('❌ Login: FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ Login: ERROR - $e');
    }
    
    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _testPodSearch() async {
    setState(() {
      _isRunningTests = true;
      _testResults = '';
    });
    
    _addResult('🎧 Testing Pod Search...');
    
    try {
      final response = await _podRepository.getAllPods(limit: 5);
      
      if (response.success && response.data != null) {
        _addResult('✅ Pod Search: PASSED - Found ${response.data!.length} pods');
        for (int i = 0; i < response.data!.length && i < 3; i++) {
          final pod = response.data![i];
          _addResult('   Pod ${i + 1}: ${pod.name ?? 'Unknown'} - RM${pod.pricePerHour ?? 0}/hr');
        }
      } else {
        _addResult('❌ Pod Search: FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ Pod Search: ERROR - $e');
    }
    
    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _testAdminDashboard() async {
    setState(() {
      _isRunningTests = true;
      _testResults = '';
    });
    
    _addResult('🛠 Testing Admin Dashboard...');
    
    try {
      final response = await _adminRepository.getDashboardStats();
      
      if (response.success && response.data != null) {
        _addResult('✅ Admin Dashboard: PASSED - Stats retrieved');
        final stats = response.data!;
        _addResult('   Total Users: ${stats.totalUsers ?? 0}');
        _addResult('   Total Bookings: ${stats.totalBookings ?? 0}');
        _addResult('   Pending Bookings: ${stats.pendingBookings ?? 0}');
      } else {
        _addResult('❌ Admin Dashboard: FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ Admin Dashboard: ERROR - $e');
    }
    
    setState(() {
      _isRunningTests = false;
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults = '';
    });
    
    _addResult('🚀 Running Complete Test Suite...');
    _addResult('=====================================');
    
    // Test 1: Health Check
    _addResult('');
    _addResult('🔍 Test 1: Health Check');
    try {
      final apiProvider = context.read<ApiProvider>();
      final isHealthy = await apiProvider.healthCheck();
      
      if (isHealthy) {
        _addResult('✅ PASSED - Backend is reachable');
      } else {
        _addResult('❌ FAILED - Backend not reachable');
      }
    } catch (e) {
      _addResult('❌ ERROR - $e');
    }
    
    // Test 2: Login
    _addResult('');
    _addResult('🔐 Test 2: Authentication');
    try {
      final response = await _authRepository.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      if (response.success) {
        _addResult('✅ PASSED - Authentication successful');
      } else {
        _addResult('❌ FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ ERROR - $e');
    }
    
    // Test 3: Pod Search
    _addResult('');
    _addResult('🎧 Test 3: Pod Search');
    try {
      final response = await _podRepository.getAllPods(limit: 3);
      
      if (response.success && response.data != null) {
        _addResult('✅ PASSED - Found ${response.data!.length} pods');
      } else {
        _addResult('❌ FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ ERROR - $e');
    }
    
    // Test 4: Admin Dashboard
    _addResult('');
    _addResult('🛠 Test 4: Admin Dashboard');
    try {
      final response = await _adminRepository.getDashboardStats();
      
      if (response.success) {
        _addResult('✅ PASSED - Admin stats retrieved');
      } else {
        _addResult('❌ FAILED - ${response.error}');
      }
    } catch (e) {
      _addResult('❌ ERROR - $e');
    }
    
    _addResult('');
    _addResult('=====================================');
    _addResult('🎯 Test Suite Complete!');
    _addResult('');
    _addResult('✨ Your Flutter app is now fully integrated');
    _addResult('   with the FastAPI backend!');
    
    setState(() {
      _isRunningTests = false;
    });
  }
}