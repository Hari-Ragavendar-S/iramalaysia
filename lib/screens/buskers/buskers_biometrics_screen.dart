import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'buskers_main_navigation.dart';

class BuskersBiometricsScreen extends StatefulWidget {
  const BuskersBiometricsScreen({super.key});

  @override
  State<BuskersBiometricsScreen> createState() => _BuskersBiometricsScreenState();
}

class _BuskersBiometricsScreenState extends State<BuskersBiometricsScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isPinSet = false;
  bool _fingerprintEnabled = false;
  bool _faceRecognitionEnabled = false;
  int _currentStep = 0; // 0: Set PIN, 1: Confirm PIN, 2: Biometrics

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
        ),
        title: Text(
          'Security Setup',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress Indicator
            Row(
              children: [
                _buildStepIndicator(0, 'PIN'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 0 ? AppColors.primaryGold : AppColors.primaryGold.withOpacity(0.3),
                  ),
                ),
                _buildStepIndicator(1, 'Confirm'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 1 ? AppColors.primaryGold : AppColors.primaryGold.withOpacity(0.3),
                  ),
                ),
                _buildStepIndicator(2, 'Biometrics'),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_currentStep == 0) _buildSetPinStep(),
            if (_currentStep == 1) _buildConfirmPinStep(),
            if (_currentStep == 2) _buildBiometricsStep(),
            
            const Spacer(),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _getButtonAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonAction() != null ? AppColors.primaryGold : Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getButtonText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGold : AppColors.primaryGold.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive && _currentStep > step
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primaryGold : AppColors.textColor.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSetPinStep() {
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 80,
          color: AppColors.primaryGold,
        ),
        const SizedBox(height: 24),
        Text(
          'Set Your mPIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a 6-digit PIN for secure access',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildPinField(_pinController, 'Enter 6-digit PIN'),
        const SizedBox(height: 16),
        Text(
          'PIN: ${_pinController.text.replaceAll(RegExp(r'.'), '●')}',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPinStep() {
    return Column(
      children: [
        Icon(
          Icons.verified_user,
          size: 80,
          color: AppColors.primaryGold,
        ),
        const SizedBox(height: 24),
        Text(
          'Confirm Your mPIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Re-enter your PIN to confirm',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildPinField(_confirmPinController, 'Confirm 6-digit PIN'),
        const SizedBox(height: 16),
        Text(
          'PIN: ${_confirmPinController.text.replaceAll(RegExp(r'.'), '●')}',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricsStep() {
    return Column(
      children: [
        Icon(
          Icons.fingerprint,
          size: 80,
          color: AppColors.primaryGold,
        ),
        const SizedBox(height: 24),
        Text(
          'Enable Biometrics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add an extra layer of security with biometric authentication',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        // Fingerprint Option
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Fingerprint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Use your fingerprint for quick access',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _fingerprintEnabled,
                onChanged: (value) {
                  setState(() {
                    _fingerprintEnabled = value;
                  });
                },
                activeColor: AppColors.primaryGold,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Face Recognition Option
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.face,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Face Recognition',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      'Use face recognition for secure login',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _faceRecognitionEnabled,
                onChanged: (value) {
                  setState(() {
                    _faceRecognitionEnabled = value;
                  });
                },
                activeColor: AppColors.primaryGold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinField(TextEditingController controller, String hint) {
    return Container(
      width: 200,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: true,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textColor.withOpacity(0.5),
            fontSize: 16,
            letterSpacing: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {
            // Trigger rebuild to update button state
          });
        },
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return _pinController.text.length == 6 ? 'Set PIN' : 'Enter PIN';
      case 1:
        return _confirmPinController.text.length == 6 ? 'Confirm PIN' : 'Confirm PIN';
      case 2:
        return 'Complete Setup';
      default:
        return 'Continue';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (_currentStep) {
      case 0:
        return _pinController.text.length == 6 ? _setPin : null;
      case 1:
        return _confirmPinController.text.length == 6 ? _confirmPin : null;
      case 2:
        return _completeSetup;
      default:
        return null;
    }
  }

  void _setPin() {
    if (_pinController.text.length == 6) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _confirmPin() {
    if (_confirmPinController.text == _pinController.text) {
      setState(() {
        _isPinSet = true;
        _currentStep = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      _confirmPinController.clear();
    }
  }

  void _completeSetup() {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setup Complete!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your account is now secure and ready to use.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to Buskers Main Navigation
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuskersMainNavigation(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}