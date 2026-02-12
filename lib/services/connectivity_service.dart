import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isConnected = false;
  bool _isServerReachable = false;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  
  bool get isConnected => _isConnected;
  bool get isServerReachable => _isServerReachable;
  bool get isOnline => _isConnected && _isServerReachable;
  ConnectivityResult get connectionType => _connectionType;

  static Future<void> initialize() async {
    await ConnectivityService()._init();
  }

  Future<void> _init() async {
    try {
      // Check initial connectivity
      await _checkConnectivity();
      
      // Listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        _connectionType = result;
        _checkConnectivity();
      });
    } catch (e) {
      debugPrint('Connectivity service initialization failed: $e');
      _isConnected = false;
      _isServerReachable = false;
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _connectionType = connectivityResult;
      _isConnected = connectivityResult != ConnectivityResult.none;
      
      if (_isConnected) {
        _isServerReachable = await _checkServerReachability();
      } else {
        _isServerReachable = false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _isConnected = false;
      _isServerReachable = false;
      notifyListeners();
    }
  }

  Future<bool> _checkServerReachability() async {
    try {
      // Extract host from base URL
      final uri = Uri.parse(ApiConfig.baseUrl);
      final host = uri.host;
      final port = uri.port;
      
      // Try to connect to the server
      final socket = await Socket.connect(
        host, 
        port,
        timeout: const Duration(seconds: 5),
      );
      
      socket.destroy();
      return true;
    } catch (e) {
      debugPrint('Server not reachable: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await _checkConnectivity();
  }

  String get statusMessage {
    if (!_isConnected) {
      return 'No internet connection';
    } else if (!_isServerReachable) {
      return 'Server not reachable - Using offline mode';
    } else {
      return 'Connected to server';
    }
  }

  String get connectionTypeString {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }
}