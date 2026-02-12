import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/pod_booking.dart';
import 'pod_payment_screen.dart';

class PodTimeSelectionScreen extends StatefulWidget {
  final AvailablePod pod;
  final DateTime selectedDate;

  const PodTimeSelectionScreen({
    super.key,
    required this.pod,
    required this.selectedDate,
  });

  @override
  State<PodTimeSelectionScreen> createState() => _PodTimeSelectionScreenState();
}

class _PodTimeSelectionScreenState extends State<PodTimeSelectionScreen> {
  List<TimeSlot> _availableSlots = [];
  List<TimeSlot> _selectedSlots = [];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    // Generate time slots from 10 AM to 10 PM
    final slots = <TimeSlot>[];
    
    for (int hour = 10; hour < 22; hour++) {
      final startTime = TimeOfDay(hour: hour, minute: 0);
      final endTime = TimeOfDay(hour: hour + 1, minute: 0);
      
      // Randomly assign some slots as booked for demo
      final isBooked = [12, 15, 18].contains(hour);
      
      slots.add(TimeSlot(
        id: 'slot_$hour',
        startTime: startTime,
        endTime: endTime,
        price: widget.pod.basePrice,
        status: isBooked ? SlotStatus.booked : SlotStatus.available,
      ));
    }
    
    setState(() {
      _availableSlots = slots;
    });
  }

  void _toggleSlotSelection(TimeSlot slot) {
    if (slot.status == SlotStatus.booked) return;
    
    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
      
      // Sort selected slots by time
      _selectedSlots.sort((a, b) => 
        (a.startTime.hour * 60 + a.startTime.minute)
            .compareTo(b.startTime.hour * 60 + b.startTime.minute));
    });
  }

  double get _totalAmount {
    return _selectedSlots.fold(0.0, (sum, slot) => sum + slot.price);
  }

  String get _selectedTimeRange {
    if (_selectedSlots.isEmpty) return '';
    
    final firstSlot = _selectedSlots.first;
    final lastSlot = _selectedSlots.last;
    
    final startTime = '${firstSlot.startTime.hour.toString().padLeft(2, '0')}:${firstSlot.startTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${lastSlot.endTime.hour.toString().padLeft(2, '0')}:${lastSlot.endTime.minute.toString().padLeft(2, '0')}';
    
    return '$startTime - $endTime';
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
          'Select Time Slots',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Booking Summary Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.softGoldHighlight.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.pod.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: AppColors.primaryGold.withOpacity(0.2),
                            child: Icon(
                              Icons.music_note,
                              color: AppColors.primaryGold,
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
                            maxLines: 1,
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
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (_selectedSlots.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Time',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedTimeRange,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RM ${_totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Time Slots Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select one or multiple continuous time slots',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Legend
                  Row(
                    children: [
                      _buildLegendItem('Available', AppColors.primaryGold.withOpacity(0.2), AppColors.primaryGold),
                      const SizedBox(width: 20),
                      _buildLegendItem('Selected', AppColors.primaryGold, Colors.white),
                      const SizedBox(width: 20),
                      _buildLegendItem('Booked', Colors.grey.shade300, Colors.grey.shade600),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Time Slots Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _availableSlots[index];
                        return _buildTimeSlotCard(slot);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedSlots.isNotEmpty ? () => _navigateToPayment() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedSlots.isNotEmpty ? AppColors.primaryGold : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _selectedSlots.isNotEmpty
                    ? 'Proceed to Payment (RM ${_totalAmount.toStringAsFixed(0)})'
                    : 'Select Time Slots',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color backgroundColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: backgroundColor == AppColors.primaryGold.withOpacity(0.2)
                ? Border.all(color: AppColors.primaryGold.withOpacity(0.5))
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (slot.status) {
      case SlotStatus.available:
        backgroundColor = AppColors.primaryGold.withOpacity(0.1);
        textColor = AppColors.textColor;
        borderColor = AppColors.primaryGold.withOpacity(0.3);
        break;
      case SlotStatus.selected:
        backgroundColor = AppColors.primaryGold;
        textColor = Colors.white;
        borderColor = AppColors.primaryGold;
        break;
      case SlotStatus.booked:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        borderColor = Colors.grey.shade300;
        break;
    }
    
    return GestureDetector(
      onTap: () => _toggleSlotSelection(slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: slot.status == SlotStatus.selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.displayTime,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slot.status == SlotStatus.booked
                  ? 'Booked'
                  : 'RM ${slot.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
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

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodPaymentScreen(
          pod: widget.pod,
          selectedDate: widget.selectedDate,
          selectedSlots: List.from(_selectedSlots),
          totalAmount: _totalAmount,
        ),
      ),
    );
  }
}
