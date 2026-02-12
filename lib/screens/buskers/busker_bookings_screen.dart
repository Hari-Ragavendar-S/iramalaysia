import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/pod_booking.dart';
import '../../services/pod_service.dart';
import '../../services/payment_proof_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/safe_network_image.dart';
import 'pod_receipt_upload_screen.dart';

class BuskerBookingsScreen extends StatefulWidget {
  const BuskerBookingsScreen({Key? key}) : super(key: key);

  @override
  State<BuskerBookingsScreen> createState() => _BuskerBookingsScreenState();
}

class _BuskerBookingsScreenState extends State<BuskerBookingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _refreshTimer;
  
  List<PodBooking> _allBookings = [];
  List<PodBooking> _upcomingBookings = [];
  List<PodBooking> _pastBookings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _loadBookings();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _refreshBookings();
      }
    });
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PodService.getUserBookings(
        page: 1,
        perPage: 50,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          final bookings = result['data'] as List<PodBooking>;
          _processBookings(bookings);
          _fadeController.forward();
        } else {
          ErrorSnackBar.show(context, result['message'] ?? 'Failed to load bookings');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ErrorSnackBar.show(context, 'An unexpected error occurred');
      }
    }
  }

  Future<void> _refreshBookings() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await PodService.getUserBookings(
        page: 1,
        perPage: 50,
      );

      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });

        if (result['success']) {
          final bookings = result['data'] as List<PodBooking>;
          _processBookings(bookings);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _processBookings(List<PodBooking> bookings) {
    final now = DateTime.now();
    
    setState(() {
      _allBookings = bookings;
      
      _upcomingBookings = bookings
          .where((booking) => booking.bookingDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

      _pastBookings = bookings
          .where((booking) => booking.bookingDate.isBefore(now))
          .toList()
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    });
  }

  Future<void> _cancelBooking(PodBooking booking) async {
    try {
      final result = await PodService.cancelBooking(booking.id);

      if (mounted) {
        if (result['success']) {
          SuccessSnackBar.show(context, 'Booking cancelled successfully');
          _loadBookings(); // Refresh the list
        } else {
          ErrorSnackBar.show(context, result['message'] ?? 'Failed to cancel booking');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, 'An unexpected error occurred');
      }
    }
  }

  Future<void> _uploadPaymentProof(PodBooking booking) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodReceiptUploadScreen(
          bookingId: booking.id,
          podName: booking.podName,
          mall: booking.mall,
          city: booking.city ?? 'Unknown City',
          selectedDate: booking.bookingDate,
          selectedSlots: booking.timeSlots.map((slot) => slot.displayTime).toList(),
          totalAmount: booking.totalAmount,
          referenceNo: booking.id, // Use booking ID as reference if no specific reference
        ),
      ),
    ).then((_) {
      // Refresh bookings when returning from upload screen
      _loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _isRefreshing ? AppColors.primaryGold : AppColors.textColor,
            ),
            onPressed: _isRefreshing ? null : _refreshBookings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textColor.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading your bookings...')
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshBookings,
                color: AppColors.primaryGold,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(_upcomingBookings, isUpcoming: true),
                    _buildBookingsList(_pastBookings, isUpcoming: false),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBookingsList(List<PodBooking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.event_available : Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No Upcoming Bookings' : 'No Past Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Book your first pod to start performing'
                : 'Your completed bookings will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/pod-search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Browse Pods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingCard(PodBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingHeader(booking),
          _buildBookingDetails(booking),
          _buildBookingFooter(booking),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(PodBooking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(booking.status).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.podName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.mall}, ${booking.city}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(booking.status),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(PodBooking booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Date',
            _formatDate(booking.bookingDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time_outlined,
            'Time Slots',
            booking.timeSlots.map((slot) => slot.displayTime).join(', '),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.currency_rupee_outlined,
            'Amount',
            'RM ${booking.totalAmount.toStringAsFixed(0)}',
          ),
          if (booking.paymentReceiptPath != null) ...[
            const SizedBox(height: 12),
            _buildReceiptRow(booking.paymentReceiptPath!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textColor.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String receiptUrl) {
    return Row(
      children: [
        Icon(
          Icons.receipt_outlined,
          size: 20,
          color: AppColors.textColor.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Receipt',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              GestureDetector(
                onTap: () => _showReceiptDialog(receiptUrl),
                child: const Text(
                  'View Receipt',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingFooter(PodBooking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Text(
            'Booked on ${_formatDate(booking.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          
          // Action buttons based on status
          if (booking.status == BookingStatus.pending) ...[
            TextButton(
              onPressed: () => _uploadPaymentProof(booking),
              child: const Text(
                'Upload Again',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else if (booking.status == BookingStatus.confirmed &&
              booking.bookingDate.isAfter(DateTime.now())) ...[
            TextButton(
              onPressed: () => _showCancelDialog(booking),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange; // Yellow for pending
      case BookingStatus.confirmed:
        return Colors.green; // Green for verified
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red; // Red for rejected
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Verified';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Rejected';
    }
  }

  void _showReceiptDialog(String receiptPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Payment Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SafeNetworkImage(
                  imageUrl: receiptPath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(PodBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your booking for ${booking.podName}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Booking',
              style: TextStyle(color: AppColors.textColor.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
