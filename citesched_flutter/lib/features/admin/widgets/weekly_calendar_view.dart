import 'package:citesched_client/citesched_client.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyCalendarView extends StatefulWidget {
  final List<ScheduleInfo> schedules;
  final List<FacultyAvailability>? availabilities;
  final Function(Schedule)? onEdit;
  final Color maroonColor;
  final bool isInstructorView;
  final Faculty? selectedFaculty;
  final bool isStudentView;

  const WeeklyCalendarView({
    super.key,
    required this.schedules,
    required this.maroonColor,
    this.availabilities,
    this.isInstructorView = false,
    this.selectedFaculty,
    this.onEdit,
    this.isStudentView = false,
  });

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  List<ScheduleInfo> get schedules => widget.schedules;
  List<FacultyAvailability>? get availabilities => widget.availabilities;
  Function(Schedule)? get onEdit => widget.onEdit;
  Color get maroonColor => widget.maroonColor;
  bool get isInstructorView => widget.isInstructorView;
  Faculty? get selectedFaculty => widget.selectedFaculty;
  bool get isStudentView => widget.isStudentView;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToEarliestSchedule();
    });
  }

  @override
  void didUpdateWidget(covariant WeeklyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedules != widget.schedules) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToEarliestSchedule();
      });
    }
  }

  void _jumpToEarliestSchedule() {
    if (!_verticalController.hasClients) return;
    const int startHour = 7;
    final withTimeslot = schedules
        .where((s) => s.schedule.timeslot != null)
        .toList();
    if (withTimeslot.isEmpty) return;
    final earliest = withTimeslot
        .map((s) => _parseTime(s.schedule.timeslot!.startTime))
        .reduce((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin <= bMin ? a : b;
    });
    final hourHeight = isStudentView ? 64.0 : 100.0;
    final target = ((earliest.hour - startHour - 1).clamp(0, 24) +
            (earliest.minute / 60.0)) *
        hourHeight;
    _verticalController.jumpTo(
      target.clamp(0.0, _verticalController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? Colors.white12 : Colors.black12;

    // Config
    final double hourHeight = isStudentView ? 64.0 : 100.0;
    const double dayWidth = 150.0;
    const int startHour = 7;
    const int endHour = 19; // 7AM–7PM per student view spec
    final List<DayOfWeek> days = [
      DayOfWeek.mon,
      DayOfWeek.tue,
      DayOfWeek.wed,
      DayOfWeek.thu,
      DayOfWeek.fri,
      DayOfWeek.sat,
    ];

    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Container(
          width: 80 + (dayWidth * days.length),
          height: hourHeight * (endHour - startHour + 1),
          child: Stack(
            children: [
              // 1. Grid Background & Headers
              _buildGrid(
                context,
                days,
                startHour,
                endHour,
                hourHeight,
                dayWidth,
                gridColor,
              ),

              // 2. Preference Cardboxes (High Visibility Black/Faded Highlight)
              if (availabilities != null)
                ...availabilities!
                    .where((a) => a.isPreferred)
                    .map(
                      (avail) => _buildPreferenceCardbox(
                        avail,
                        days,
                        startHour,
                        hourHeight,
                        dayWidth,
                      ),
                    ),

              // 3. Shift Preference Watermarks (Faded vertical labels)
              if (selectedFaculty != null && availabilities == null)
                ...days.map(
                  (day) => _buildShiftWatermark(
                    day,
                    days,
                    startHour,
                    hourHeight,
                    dayWidth,
                  ),
                ),

              // 4. Schedule Blocks
              ...schedules.map(
                (info) => _buildScheduleBlock(
                  context,
                  info,
                  days,
                  startHour,
                  hourHeight,
                  dayWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<DayOfWeek> days,
    int startHour,
    int endHour,
    double hourHeight,
    double dayWidth,
    Color gridColor,
  ) {
    final prefRange = _getPreferenceRange();

    return Column(
      children: [
        // Day Headers
        Row(
          children: [
            const SizedBox(width: 80),
            ...days.map(
              (day) => Container(
                width: dayWidth,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isDayHighlighted(day)
                      ? maroonColor.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: gridColor),
                    left: BorderSide(color: gridColor),
                  ),
                ),
                child: Text(
                  _getDayName(day),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isDayHighlighted(day) ? maroonColor : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Time Rows
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: endHour - startHour + 1,
            itemBuilder: (context, index) {
              final hour = startHour + index;
              final isPreferredTime =
                  prefRange != null &&
                  hour >= prefRange.start &&
                  hour < prefRange.end;

              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: gridColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.all(4),
                      decoration: isPreferredTime
                          ? BoxDecoration(
                              color: Colors.black,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            )
                          : null,
                      child: Column(
                        children: [
                          Text(
                            _formatHour(hour),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isPreferredTime
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                          if (isPreferredTime)
                            Text(
                              'PREF',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...days.map(
                      (day) => Container(
                        width: dayWidth,
                        decoration: BoxDecoration(
                          color: isPreferredTime
                              ? Colors.black.withOpacity(0.04)
                              : (_isDayHighlighted(day) &&
                                        _isTimeHighlighted(hour)
                                    ? maroonColor.withOpacity(0.03)
                                    : Colors.transparent),
                          border: Border(left: BorderSide(color: gridColor)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _PreferenceRange? _getPreferenceRange() {
    if (selectedFaculty == null) return null;

    final shift = selectedFaculty!.shiftPreference;
    if (shift == null) return null;

    switch (shift) {
      case FacultyShiftPreference.morning:
        return _PreferenceRange(7, 12);
      case FacultyShiftPreference.afternoon:
        return _PreferenceRange(13, 18);
      case FacultyShiftPreference.evening:
        return _PreferenceRange(18, 21);
      case FacultyShiftPreference.any:
        return _PreferenceRange(7, 21);
      case FacultyShiftPreference.custom:
        if (selectedFaculty!.preferredHours == null) return null;
        return _parseCustomHours(selectedFaculty!.preferredHours!);
    }
  }

  _PreferenceRange? _parseCustomHours(String hours) {
    try {
      // Expected format: "7:00 AM - 12:00 PM"
      final parts = hours.split('-');
      if (parts.length != 2) return null;

      final startStr = parts[0].trim();
      final endStr = parts[1].trim();

      final startTime = _parseTimeString(startStr);
      final endTime = _parseTimeString(endStr);

      return _PreferenceRange(
        startTime.hour,
        endTime.hour + (endTime.minute > 0 ? 1 : 0),
      );
    } catch (e) {
      debugPrint('Error parsing custom hours: $e');
      return null;
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Format: "7:00 AM" or "12:00 PM"
    final timeParts = timeStr.split(' ');
    final amPm = timeParts[1].toUpperCase();
    final parts = timeParts[0].split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (amPm == 'PM' && hour != 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _buildPreferenceCardbox(
    FacultyAvailability avail,
    List<DayOfWeek> days,
    int startHour,
    double hourHeight,
    double dayWidth,
  ) {
    final dayIndex = days.indexOf(avail.dayOfWeek);
    if (dayIndex == -1) return const SizedBox.shrink();

    final start = _parseTime(avail.startTime);
    final end = _parseTime(avail.endTime);

    final double top =
        40 + (start.hour - startHour + start.minute / 60.0) * hourHeight;
    final double height =
        (end.hour - start.hour + (end.minute - start.minute) / 60.0) *
        hourHeight;
    final double left = 80 + (dayIndex * dayWidth);

    return Positioned(
      top: top + 2,
      left: left + 4,
      width: dayWidth - 8,
      height: height - 4,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 2.5,
              style: BorderStyle
                  .none, // Dashed look via custom painter? No, just use a solid faded border for now
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    size: 24,
                    color: Colors.black.withOpacity(0.15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildAssignedSlotLabel(avail, start, end) ??
                        'PREFERRED SLOT',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.2),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftWatermark(
    DayOfWeek day,
    List<DayOfWeek> days,
    int startHour,
    double hourHeight,
    double dayWidth,
  ) {
    final prefRange = _getPreferenceRange();
    if (prefRange == null) return const SizedBox.shrink();

    final dayIndex = days.indexOf(day);
    final double top = 40 + (prefRange.start - startHour) * hourHeight;
    final double height = (prefRange.end - prefRange.start) * hourHeight;
    final double left = 80 + (dayIndex * dayWidth);

    // Build label
    String shiftLabel = '';
    String timeRange = '';
    switch (selectedFaculty?.shiftPreference) {
      case FacultyShiftPreference.morning:
        shiftLabel = 'Morning';
        timeRange = '7AM – 12PM';
        break;
      case FacultyShiftPreference.afternoon:
        shiftLabel = 'Afternoon';
        timeRange = '1PM – 6PM';
        break;
      case FacultyShiftPreference.evening:
        shiftLabel = 'Evening';
        timeRange = '6PM – 9PM';
        break;
      case FacultyShiftPreference.any:
        shiftLabel = 'Any Shift';
        timeRange = 'Flexible';
        break;
      case FacultyShiftPreference.custom:
        shiftLabel = 'Custom';
        timeRange = selectedFaculty?.preferredHours ?? '';
        break;
      default:
        break;
    }

    return Positioned(
      top: top + 4,
      left: left + 4,
      width: dayWidth - 8,
      height: height - 8,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: maroonColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: maroonColor.withOpacity(0.35),
              width: 2.0,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.stars_rounded,
                size: 20,
                color: maroonColor.withOpacity(0.6),
              ),
              const SizedBox(height: 6),
              Text(
                'PREFERRED',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: maroonColor.withOpacity(0.8),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                shiftLabel.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: maroonColor.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (timeRange.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: maroonColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeRange,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: maroonColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBlock(
    BuildContext context,
    ScheduleInfo info,
    List<DayOfWeek> days,
    int startHour,
    double hourHeight,
    double dayWidth,
  ) {
    final schedule = info.schedule;
    final timeslot = schedule.timeslot;
    if (timeslot == null) return const SizedBox.shrink();

    final dayIndex = days.indexOf(timeslot.day);
    if (dayIndex == -1) return const SizedBox.shrink();

    final startTime = _parseTime(timeslot.startTime);
    final endTime = _parseTime(timeslot.endTime);

    final double top =
        40 +
        (startTime.hour - startHour + startTime.minute / 60.0) * hourHeight;
    final double height =
        (endTime.hour -
            startTime.hour +
            (endTime.minute - startTime.minute) / 60.0) *
        hourHeight;
    final double left = 80 + (dayIndex * dayWidth);

    final bool hasAvailabilityViolation =
        _isOutsidePreferredAvailability(schedule);
    final bool hasConflict =
        info.conflicts.isNotEmpty || hasAvailabilityViolation;

    // Styles
    final Color blockColor = isStudentView
        ? Colors.white
        : hasConflict
            ? const Color(0xFF2D0000)
            : Colors.black;

    final Color borderColor = hasConflict
        ? Colors.red.shade400
        : isStudentView
            ? Colors.black87
            : Colors.grey[800]!;

    return Positioned(
      top: top + 2,
      left: left + 4,
      width: dayWidth - 8,
      height: height - 4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showScheduleDetails(context, info),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: hasConflict ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isStudentView)
                  _buildStudentCardContent(
                    schedule: schedule,
                    timeslot: timeslot,
                    hasConflict: hasConflict,
                  )
                else ...[
                  // Existing instructor/admin style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: maroonColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (schedule.faculty?.name ?? 'UNASSIGNED').toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  schedule.subject?.code ?? 'TBA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: Text(
                                schedule.subject?.name ?? 'No Subject Title',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.1,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'SEC ${schedule.section} | Y${schedule.subject?.yearLevel?.toString() ?? '-'}',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.75),
                                height: 1.0,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${timeslot.startTime} - ${timeslot.endTime}',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasConflict)
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.red[300],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCardContent({
    required Schedule schedule,
    required Timeslot timeslot,
    required bool hasConflict,
  }) {
    final subj = schedule.subject;
    final faculty = schedule.faculty?.name ?? 'TBA';
    final program = subj?.program.name.toUpperCase() ?? schedule.section;
    final year = subj?.yearLevel != null ? 'Y${subj!.yearLevel}' : '';
    final room = schedule.room?.name ?? 'Room TBA';
    final timeRange = '${timeslot.startTime} - ${timeslot.endTime}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: instructor / program / room
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black54),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                faculty,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
              Text(
                '$program ${year.isNotEmpty ? '– $year' : ''}',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
              ),
              Text(
                room,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Bottom white content area
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black45),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subj?.code ?? 'TBA',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subj?.name ?? 'No Subject Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (hasConflict)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.red[700],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showScheduleDetails(BuildContext context, ScheduleInfo info) {
    final schedule = info.schedule;
    final hasConflict = info.conflicts.isNotEmpty;
    final hasAvailabilityViolation =
        _isOutsidePreferredAvailability(schedule);
    final shouldShowConflict = hasConflict || hasAvailabilityViolation;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              shouldShowConflict ? Icons.warning_rounded : Icons.event_note,
              color: shouldShowConflict ? Colors.red : maroonColor,
            ),
            const SizedBox(width: 12),
            const Text('Schedule Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Subject', schedule.subject?.name ?? 'N/A'),
            _buildDetailItem('Code', schedule.subject?.code ?? 'N/A'),
            _buildDetailItem(
              'Instructor',
              schedule.faculty?.name ?? 'Unassigned',
            ),
            _buildDetailItem('Room', schedule.room?.name ?? 'N/A'),
            _buildDetailItem('Section', schedule.section),
            _buildDetailItem(
              'Year Level',
              schedule.subject?.yearLevel?.toString() ?? 'N/A',
            ),
            _buildDetailItem(
              'Time',
              '${schedule.timeslot?.day.name.toUpperCase()} ${schedule.timeslot?.startTime} - ${schedule.timeslot?.endTime}',
            ),
            if (shouldShowConflict) ...[
              const Divider(height: 24),
              Text(
                'CONFLICT DETECTED:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ...info.conflicts.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${c.message}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEdit?.call(schedule);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  bool _isDayHighlighted(DayOfWeek day) {
    if (!isInstructorView) return false;
    return schedules.any((s) => s.schedule.timeslot?.day == day);
  }

  bool _isTimeHighlighted(int hour) {
    if (!isInstructorView) return false;
    return schedules.any((s) {
      final ts = s.schedule.timeslot;
      if (ts == null) return false;
      final start = _parseTime(ts.startTime);
      final end = _parseTime(ts.endTime);
      return hour >= start.hour && hour < end.hour;
    });
  }

  bool _isOutsidePreferredAvailability(Schedule schedule) {
    if (availabilities == null) return false;
    final preferred = availabilities!.where((a) => a.isPreferred).toList();
    if (preferred.isEmpty) return false;
    final timeslot = schedule.timeslot;
    if (timeslot == null) return false;

    final tsStart = _parseTime(timeslot.startTime);
    final tsEnd = _parseTime(timeslot.endTime);
    final tsStartMinutes = tsStart.hour * 60 + tsStart.minute;
    final tsEndMinutes = tsEnd.hour * 60 + tsEnd.minute;

    for (final a in preferred) {
      if (a.dayOfWeek != timeslot.day) continue;
      final aStart = _parseTime(a.startTime);
      final aEnd = _parseTime(a.endTime);
      final aStartMinutes = aStart.hour * 60 + aStart.minute;
      final aEndMinutes = aEnd.hour * 60 + aEnd.minute;
      if (tsStartMinutes >= aStartMinutes && tsEndMinutes <= aEndMinutes) {
        return false;
      }
    }

    return true;
  }

  TimeOfDay _parseTime(String time) {
    // Expected format: "08:30" or "14:15"
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$suffix';
  }

  String? _buildAssignedSlotLabel(
    FacultyAvailability avail,
    TimeOfDay prefStart,
    TimeOfDay prefEnd,
  ) {
    final prefStartMinutes = prefStart.hour * 60 + prefStart.minute;
    final prefEndMinutes = prefEnd.hour * 60 + prefEnd.minute;

    for (final info in schedules) {
      final ts = info.schedule.timeslot;
      if (ts == null) continue;
      if (ts.day != avail.dayOfWeek) continue;

      final tsStart = _parseTime(ts.startTime);
      final tsEnd = _parseTime(ts.endTime);
      final tsStartMinutes = tsStart.hour * 60 + tsStart.minute;
      final tsEndMinutes = tsEnd.hour * 60 + tsEnd.minute;

      if (tsStartMinutes < prefStartMinutes ||
          tsEndMinutes > prefEndMinutes) {
        continue;
      }

      final timeLabel =
          '${_formatTimeOfDay(tsStart)} - ${_formatTimeOfDay(tsEnd)}';
      final facultyName =
          info.schedule.faculty?.name ?? selectedFaculty?.name ?? '';
      final subjectCode = info.schedule.subject?.code ?? '';
      final subjectName = info.schedule.subject?.name ?? '';

      return [
        timeLabel,
        facultyName,
        subjectCode,
        subjectName,
      ].where((s) => s.trim().isNotEmpty).join(' ');
    }

    return null;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _getDayName(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.mon:
        return 'Mon';
      case DayOfWeek.tue:
        return 'Tue';
      case DayOfWeek.wed:
        return 'Wed';
      case DayOfWeek.thu:
        return 'Thu';
      case DayOfWeek.fri:
        return 'Fri';
      case DayOfWeek.sat:
        return 'Sat';
      case DayOfWeek.sun:
        return 'Sun';
    }
  }
}

class _PreferenceRange {
  final int start;
  final int end;
  _PreferenceRange(this.start, this.end);
}
