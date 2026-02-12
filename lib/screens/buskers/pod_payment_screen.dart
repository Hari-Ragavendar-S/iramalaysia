import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/colors.dart';
import '../../models/pod_booking.dart';
import '../../services/pod_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'pod_receipt_upload_screen.dart';

class PodPaymentScreen extends StatefulWidget {
  final AvailablePod pod;
  final DateTime selectedDate;
  final List<TimeSlot> selectedSlots;
  final double totalAmount;

  const PodPaymentScreen({
    super.key,
    required this.pod,
    required this.selectedDate,
    required this.selectedSlots,
    required this.totalAmount,
  });

  @override
  State<PodPaymentScreen> createState() => _PodPaymentScreenState();
}

class _PodPaymentScreenState extends State<PodPaymentScreen> {
  bool _showQRCode = false;
  bool _isCreatingBooking = false;
  String? _bookingId;
  String? _referenceNo;
  double? _finalAmount;

  String get _selectedTimeRange {
    if (widget.selectedSlots.isEmpty) return '';
    
    final firstSlot = widget.selectedSlots.first;
    final lastSlot = widget.selectedSlots.last;
    
    final startTime = '${firstSlot.startTime.hour.toString().padLeft(2, '0')}:${firstSlot.startTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${lastSlot.endTime.hour.toString().padLeft(2, '0')}:${lastSlot.endTime.minute.toString().padLeft(2, '0')}';
    
    return '$startTime - $endTime';
  }

  String get _qrCodeData {
    // Static QR code data - will be replaced with client-provided QR image
    return 'upi://pay?pa=irama1asia@upi&pn=Irama1Asia&am=${_finalAmount ?? widget.totalAmount}&cu=MYR&tn=Pod Booking $_referenceNo';
  }

  Future<void> _createBooking() async {
    setState(() {
      _isCreatingBooking = true;
    });

    try {
      // Calculate start and end times
      final firstSlot = widget.selectedSlots.first;
      final lastSlot = widget.selectedSlots.last;
      
      final startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        firstSlot.startTime.hour,
        firstSlot.startTime.minute,
      );
      
      final endTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        lastSlot.endTime.hour,
        lastSlot.endTime.minute,
      );

      final result = await PodService.createBooking(
        podId: widget.pod.id,
        startTime: startTime,
        endTime: endTime,
        totalAmount: widget.totalAmount,
        notes: 'Pod booking for ${widget.pod.name}',
      );

      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });

        if (result['success']) {
          final bookingData = result['data'];
          setState(() {
            _bookingId = bookingData.id;
            _referenceNo = bookingData.referenceNo ?? bookingData.id;
            _finalAmount = bookingData.totalAmount ?? widget.totalAmount;
            _showQRCode = true;
          });
          SuccessSnackBar.show(context, 'Booking created successfully!');
        } else {
          ErrorSnackBar.show(context, result['message'] ?? 'Failed to create booking');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
        });
        ErrorSnackBar.show(context, 'An unexpected error occurred');
      }
    }
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
          'Payment',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isCreatingBooking,
        loadingMessage: 'Creating your booking...',
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: AppColors.primaryGold,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Booking Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pod Details
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.pod.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.primaryGold.withOpacity(0.2),
                                  child: Icon(
                                    Icons.music_note,
                                    color: AppColors.primaryGold,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.pod.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.pod.mall}, ${widget.pod.city}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textColor.withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Booking Details
                      _buildDetailRow('Date', _formatDate(widget.selectedDate)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Time', _selectedTimeRange),
                      const SizedBox(height: 12),
                      _buildDetailRow('Duration', '${widget.selectedSlots.length} hour${widget.selectedSlots.length > 1 ? 's' : ''}'),
                      
                      if (_referenceNo != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Reference No.', _referenceNo!),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.primaryGold.withOpacity(0.2),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Total Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            'RM ${(_finalAmount ?? widget.totalAmount).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Payment Method Section
                if (!_showQRCode) ...[
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QR Code Payment',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scan QR code with any payment app',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your booking will be confirmed once payment is completed and receipt is uploaded.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // QR Code Section
                  Center(
                    child: Text(
                      'Scan QR Code to Pay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Static QR Code Image (replace with client-provided image)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryGold.withOpacity(0.2),
                            ),
                          ),
                          child: Image.asset(
                            'qr.jpeg', // Use the QR image from root directory
                            width: 200,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to generated QR code if image not found
                              return QrImageView(
                                data: _qrCodeData,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textColor,
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'RM ${(_finalAmount ?? widget.totalAmount).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Reference: $_referenceNo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.softGoldHighlight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Scan this QR code with any payment app to complete your payment',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Instructions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Payment Instructions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. Open any payment app (Touch \'n Go, GrabPay, etc.)\n'
                          '2. Scan the QR code above\n'
                          '3. Verify the amount and reference number\n'
                          '4. Complete the payment\n'
                          '5. Take a screenshot of payment confirmation\n'
                          '6. Upload the receipt on the next screen',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: LoadingButton(
            onPressed: () {
              if (!_showQRCode) {
                _createBooking();
              } else {
                _navigateToReceiptUpload();
              }
            },
            text: _showQRCode ? 'I Have Completed Payment' : 'Generate QR Code',
            isLoading: _isCreatingBooking,
            width: double.infinity,
            height: 56,
            backgroundColor: AppColors.primaryGold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textColor.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateToReceiptUpload() {
    if (_bookingId == null) {
      ErrorSnackBar.show(context, 'Booking ID not found');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodReceiptUploadScreen(
          bookingId: _bookingId!,
          podName: widget.pod.name,
          mall: widget.pod.mall,
          city: widget.pod.city,
          selectedDate: widget.selectedDate,
          selectedSlots: widget.selectedSlots.map((slot) => slot.time).toList(),
          totalAmount: _finalAmount ?? widget.totalAmount,
          referenceNo: _referenceNo!,
        ),
      ),
    );
  }
}
