import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/pod_booking.dart';
import '../../services/mock_data_service.dart';
import '../../utils/colors.dart';
import 'pod_time_selection_screen_offline.dart';

class PodDateSelectionScreenOffline extends StatefulWidget {
  final AvailablePod pod;

  const PodDateSelectionScreenOffline({
    super.key,
    required this.pod,
  });

  @override
  State<PodDateSelectionScreenOffline> createState() => _PodDateSelectionScreenOfflineState();
}

class _PodDateSelectionScreenOfflineState extends State<PodDateSelectionScreenOffline> {
  final MockDataService _mockService = MockDataService();
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<TimeSlot> _timeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots(_selectedDate);
  }

  void _loadTimeSlots(DateTime date) {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final slots = _mockService.generateMockTimeSlots(date);
      setState(() {
        _timeSlots = slots;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Pod Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundCard,
            child: Row(
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
                        'RM${widget.pod.basePrice.toStringAsFixed(0)}/hour',
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
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TableCalendar<Event>(
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(const Duration(days: 90)),
                            focusedDay: _focusedDate,
                            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            calendarStyle: CalendarStyle(
                              selectedDecoration: const BoxDecoration(
                                color: AppColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.primaryGold.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              weekendTextStyle: TextStyle(color: Colors.red[400]),
                              outsideDaysVisible: false,
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryGold),
                              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryGold),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDate = selectedDay;
                                _focusedDate = focusedDay;
                              });
                              _loadTimeSlots(selectedDay);
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDate = focusedDay;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Slots Preview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Available Time Slots',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _selectedDate.day == DateTime.now().day &&
                                _selectedDate.month == DateTime.now().month &&
                                _selectedDate.year == DateTime.now().year
                                    ? 'Today'
                                    : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_timeSlots.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No time slots available for this date',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: _timeSlots.take(6).length,
                                  itemBuilder: (context, index) {
                                    final slot = _timeSlots[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: slot.status == SlotStatus.available
                                            ? AppColors.primaryGold.withOpacity(0.1)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: slot.status == SlotStatus.available
                                              ? AppColors.primaryGold
                                              : Colors.grey[400]!,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              slot.displayTime.split(' - ')[0],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: slot.status == SlotStatus.available
                                                    ? AppColors.primaryGold
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              'RM${slot.price.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: slot.status == SlotStatus.available
                                                    ? AppColors.primaryGold
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_timeSlots.length > 6)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '+${_timeSlots.length - 6} more slots available',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _timeSlots.any((slot) => slot.status == SlotStatus.available)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PodTimeSelectionScreenOffline(
                              pod: widget.pod,
                              selectedDate: _selectedDate,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue to Time Selection',
                  style: TextStyle(
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
}

class Event {
  final String title;
  const Event(this.title);
}