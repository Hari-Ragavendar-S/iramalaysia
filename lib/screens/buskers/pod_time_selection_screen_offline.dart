import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/pod_booking.dart';
import '../../services/mock_data_service.dart';
import 'pod_payment_screen.dart';

class PodTimeSelectionScreenOffline extends StatefulWidget {
  final AvailablePod pod;
  final DateTime selectedDate;

  const PodTimeSelectionScreenOffline({
    super.key,
    required this.pod,
    required this.selectedDate,
  });

  @override
  State<PodTimeSelectionScreenOffline> createState() => _PodTimeSelectionScreenOfflineState();
}

class _PodTimeSelectionScreenOfflineState extends State<PodTimeSelectionScreenOffline> {
  final MockDataService _mockService = MockDataService();
  List<TimeSlot> _timeSlots = [];
  List<TimeSlot> _selectedSlots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  void _loadTimeSlots() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final slots = _mockService.generateMockTimeSlots(widget.selectedDate);
      setState(() {
        _timeSlots = slots;
        _isLoading = false;
      });
    });
  }

  void _toggleSlotSelection(TimeSlot slot) {
    if (slot.status != SlotStatus.available) return;

    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
    });
  }

  double get _totalAmount {
    return _selectedSlots.fold(0.0, (sum, slot) => sum + slot.price);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slots'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Pod Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundCard,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.primaryGold,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pod.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.pod.mall}, ${widget.pod.city}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatDate(widget.selectedDate),
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedSlots.length} slot${_selectedSlots.length > 1 ? 's' : ''} selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        Text(
                          'RM${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading available time slots...'),
                      ],
                    ),
                  )
                : _timeSlots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No time slots available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please select a different date',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Time Slots',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select multiple time slots',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _timeSlots.length,
                              itemBuilder: (context, index) {
                                final slot = _timeSlots[index];
                                return _buildTimeSlotCard(slot);
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLegendItem(
                                  color: AppColors.primaryGold,
                                  label: 'Available',
                                ),
                                _buildLegendItem(
                                  color: Colors.grey[400]!,
                                  label: 'Occupied',
                                ),
                                _buildLegendItem(
                                  color: AppColors.primaryGold,
                                  label: 'Selected',
                                  isSelected: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
          ),

          // Continue Button
          if (_selectedSlots.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodPaymentScreen(
                          pod: widget.pod,
                          selectedDate: widget.selectedDate,
                          selectedSlots: _selectedSlots,
                          totalAmount: _totalAmount,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Continue to Payment - RM${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    final isSelected = _selectedSlots.contains(slot);
    final isAvailable = slot.status == SlotStatus.available;
    
    return GestureDetector(
      onTap: () => _toggleSlotSelection(slot),
      child: Container(
        decoration: BoxDecoration(
          color: !isAvailable
              ? Colors.grey[200]
              : isSelected
                  ? AppColors.primaryGold
                  : AppColors.primaryGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !isAvailable
                ? Colors.grey[400]!
                : isSelected
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.displayTime.split(' - ')[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: !isAvailable
                      ? Colors.grey[600]
                      : isSelected
                          ? Colors.white
                          : AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                !isAvailable
                    ? 'Occupied'
                    : 'RM${slot.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: !isAvailable
                      ? Colors.grey[600]
                      : isSelected
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.primaryGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isSelected = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}