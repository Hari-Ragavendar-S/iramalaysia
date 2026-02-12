import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/colors.dart';
import '../../models/pod_booking.dart';
import '../../widgets/safe_network_image.dart';
import 'pod_time_selection_screen.dart';

class PodDateSelectionScreen extends StatefulWidget {
  final AvailablePod pod;

  const PodDateSelectionScreen({
    super.key,
    required this.pod,
  });

  @override
  State<PodDateSelectionScreen> createState() => _PodDateSelectionScreenState();
}

class _PodDateSelectionScreenState extends State<PodDateSelectionScreen> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'Select Date',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Pod Info Header
          Container(
            margin: const EdgeInsets.all(AppColors.spacingM),
            padding: const EdgeInsets.all(AppColors.spacingM),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppColors.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppColors.radiusM),
                  child: SafeNetworkImage(
                    imageUrl: widget.pod.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppColors.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pod.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${widget.pod.mall}, ${widget.pod.city}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM ${widget.pod.basePrice.toStringAsFixed(0)}/hour',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.pod.status.color,
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  child: Text(
                    widget.pod.status.displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppColors.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your performance date',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppColors.spacingS),
                  Text(
                    'Select a date to check available time slots',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppColors.spacingL),
                  
                  // Calendar Widget
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(AppColors.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar<Event>(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      eventLoader: _getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) {
                        return _selectedDate != null && isSameDay(_selectedDate!, day);
                      },
                      onDaySelected: _onDaySelected,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                        ),
                        holidayTextStyle: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                        ),
                        defaultTextStyle: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                        ),
                        disabledTextStyle: GoogleFonts.poppins(
                          color: AppColors.textTertiary,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: GoogleFonts.poppins(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        canMarkersOverflow: false,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppColors.radiusS),
                        ),
                        formatButtonTextStyle: GoogleFonts.poppins(
                          color: AppColors.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        titleTextStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.primaryPurple,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppColors.spacingL),
                  
                  // Selected Date Info
                  if (_selectedDate != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppColors.spacingM),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryPurple.withOpacity(0.1),
                            AppColors.primaryPurple.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppColors.radiusL),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppColors.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Date',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatSelectedDate(_selectedDate!),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppColors.spacingL),
                  ],
                  
                  // Availability Info
                  Container(
                    padding: const EdgeInsets.all(AppColors.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(AppColors.radiusL),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: AppColors.spacingS),
                            Text(
                              'Booking Information',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppColors.spacingM),
                        _buildInfoRow(
                          Icons.access_time,
                          'Operating Hours',
                          '9:00 AM - 10:00 PM',
                        ),
                        const SizedBox(height: AppColors.spacingS),
                        _buildInfoRow(
                          Icons.schedule,
                          'Minimum Booking',
                          '1 hour slot',
                        ),
                        const SizedBox(height: AppColors.spacingS),
                        _buildInfoRow(
                          Icons.payment,
                          'Advance Payment',
                          'Required for booking',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppColors.spacingL),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
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
              onPressed: _selectedDate != null ? _navigateToTimeSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedDate != null 
                    ? AppColors.primaryPurple 
                    : AppColors.textTertiary,
                foregroundColor: Colors.white,
                elevation: _selectedDate != null ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusM),
                ),
              ),
              child: Text(
                'Continue to Time Selection',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppColors.spacingS),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Mock data - in real app, this would come from API
    // Return events that indicate busy/available slots
    return [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      setState(() {
        _selectedDate = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateToTimeSelection() {
    if (_selectedDate == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PodTimeSelectionScreen(
          pod: widget.pod,
          selectedDate: _selectedDate!,
        ),
      ),
    );
  }
}

class Event {
  final String title;
  
  const Event(this.title);
  
  @override
  String toString() => title;
}
