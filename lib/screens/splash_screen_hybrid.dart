import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import 'buskers/pod_search_screen_offline.dart';

class SplashScreenHybrid extends StatefulWidget {
  const SplashScreenHybrid({super.key});

  @override
  State<SplashScreenHybrid> createState() => _SplashScreenHybridState();
}

class _SplashScreenHybridState extends State<SplashScreenHybrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _statusMessage = 'Initializing...';
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
    _checkConnectivityAndProceed();
  }

  Future<void> _checkConnectivityAndProceed() async {
    try {
      setState(() {
        _statusMessage = 'Checking connectivity...';
      });

      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      await connectivityService.refresh();

      await Future.delayed(const Duration(seconds: 2));

      if (connectivityService.isOnline) {
        setState(() {
          _statusMessage = 'Connected to server';
        });
      } else if (connectivityService.isConnected) {
        setState(() {
          _statusMessage = 'Server offline - Using demo mode';
        });
      } else {
        setState(() {
          _statusMessage = 'No internet - Using offline mode';
        });
      }

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isReady = true;
      });

      // Navigate after showing status
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PodSearchScreenOffline()),
          );
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error - Using offline mode';
        _isReady = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PodSearchScreenOffline()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // App Name
                const Text(
                  'Irama1Asia',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                const Text(
                  'Your Busking Platform',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Status Message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isReady) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: const Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_isReady) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const PodSearchScreenOffline(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      '🎵 Start Browsing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}