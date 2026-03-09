import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/core/providers/schedule_sync_provider.dart';
import 'package:citesched_flutter/features/admin/widgets/weekly_calendar_view.dart';
import 'package:citesched_flutter/features/admin/widgets/timetable_filter_panel.dart';
import 'package:citesched_flutter/features/admin/widgets/timetable_summary_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citesched_flutter/core/providers/admin_providers.dart';
import 'package:google_fonts/google_fonts.dart';

class TimetableFilterNotifier extends Notifier<TimetableFilterRequest> {
  @override
  TimetableFilterRequest build() => TimetableFilterRequest();

  void update(TimetableFilterRequest filter) => state = filter;
}

final timetableFilterProvider =
    NotifierProvider<TimetableFilterNotifier, TimetableFilterRequest>(() {
      return TimetableFilterNotifier();
    });

final filteredSchedulesProvider = FutureProvider<List<ScheduleInfo>>((
  ref,
) async {
  ref.watch(
    schedulesProvider,
  ); // Ensure real-time reflection of schedule changes
  final filter = ref.watch(timetableFilterProvider);
  return await client.timetable.getSchedules(filter);
});

final timetableSummaryProvider = FutureProvider<TimetableSummary>((ref) async {
  ref.watch(
    schedulesProvider,
  ); // Ensure real-time reflection of schedule changes
  final filter = ref.watch(timetableFilterProvider);
  return await client.timetable.getSummary(filter);
});

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  final Color maroonColor = const Color(0xFF720045);
  List<Faculty> _facultyList = [];
  List<Room> _roomList = [];

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final faculty = await client.admin.getAllFaculty(isActive: true);
      final rooms = await client.admin.getAllRooms(isActive: true);
      final roles = await client.admin.getAllUserRoles();
      final adminUserIds = roles
          .where((r) => r.role.trim().toLowerCase() == 'admin')
          .map((r) => r.userId.trim())
          .toSet();
      final schedulableFaculty = faculty
          .where((f) => !adminUserIds.contains(f.userInfoId.toString()))
          .toList();
      setState(() {
        _facultyList = schedulableFaculty;
        _roomList = rooms;
      });
    } catch (e) {
      debugPrint('Error loading metadata: $e');
    }
  }

  Future<void> _generateSchedule() async {
    final activeFilter = ref.read(timetableFilterProvider);
    if (activeFilter.facultyId != null) {
      await _generateScheduleForFaculty(activeFilter.facultyId!);
      return;
    }

    // Step 1: Pre-check
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    GenerateScheduleResponse? precheck;
    try {
      precheck = await client.admin.precheckSchedule();
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pre-check failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (mounted) Navigator.pop(context);

    final precheckResult = precheck;
    if (!precheckResult.success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Not Ready',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              precheckResult?.message ?? 'Missing required data.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: maroonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Step 2: Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: maroonColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'Re-Generate AI Schedule',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All existing schedules will be cleared before regeneration.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              precheckResult?.message ?? '',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(
              'Generate',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Step 3: Run regeneration
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: maroonColor),
              const SizedBox(height: 16),
              Text(
                'Generating schedule...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await client.admin.regenerateSchedule();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        notifyScheduleDataChanged(ref);
        ref.invalidate(filteredSchedulesProvider);
        ref.invalidate(timetableSummaryProvider);
        _showSummaryDialog(response);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _generateScheduleForFaculty(int facultyId) async {
    final selected = _facultyList.where((f) => f.id == facultyId).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected faculty is not schedulable.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_search_rounded, color: maroonColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'Generate For ${selected.first.name}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'This will clear existing schedules of ${selected.first.name} and generate only for this faculty.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Generate',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: maroonColor),
              const SizedBox(height: 16),
              Text(
                'Generating for ${selected.first.name}...',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final existing = await client.admin.getFacultySchedule(facultyId);
      for (final schedule in existing) {
        if (schedule.id != null) {
          await client.admin.deleteSchedule(schedule.id!);
        }
      }

      final subjects = await client.admin.getAllSubjects(isActive: true);
      final rooms = await client.admin.getAllRooms(isActive: true);
      final timeslots = await client.admin.getAllTimeslots();
      final sections = await client.admin.getAllSections();
      final selectedFaculty = selected.first;

      final scopedSubjects = selectedFaculty.program == null
          ? subjects
          : subjects
                .where((s) => s.program == selectedFaculty.program)
                .toList();
      final scopedSections = selectedFaculty.program == null
          ? sections
          : sections
                .where(
                  (s) => s.program == selectedFaculty.program && s.isActive,
                )
                .toList();
      if (scopedSubjects.isEmpty || scopedSections.isEmpty) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No matching active subjects or sections for selected faculty program.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final request = GenerateScheduleRequest(
        subjectIds: scopedSubjects.map((s) => s.id!).toList(),
        facultyIds: [facultyId],
        roomIds: rooms.map((r) => r.id!).toList(),
        timeslotIds: timeslots.map((t) => t.id!).toList(),
        sections: scopedSections.map((s) => s.sectionCode).toList(),
      );

      final response = await client.admin.generateSchedule(request);

      if (mounted) Navigator.pop(context);
      if (mounted) {
        notifyScheduleDataChanged(ref);
        ref.invalidate(filteredSchedulesProvider);
        ref.invalidate(timetableSummaryProvider);
        _showSummaryDialog(response);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSummaryDialog(GenerateScheduleResponse response) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              response.success
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: response.success ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Generation Complete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryStatRow(
              icon: Icons.check_rounded,
              color: Colors.green,
              label: 'Assigned',
              value: '${response.totalAssigned ?? 0}',
            ),
            const SizedBox(height: 8),
            _buildSummaryStatRow(
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              label: 'Conflicts Detected',
              value: '${response.conflictsDetected ?? 0}',
            ),
            const SizedBox(height: 8),
            _buildSummaryStatRow(
              icon: Icons.block_rounded,
              color: Colors.red,
              label: 'Unassigned Subjects',
              value: '${response.unassignedSubjects ?? 0}',
            ),
            if (response.message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  response.message!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 13))),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(filteredSchedulesProvider);
    final summaryAsync = ref.watch(timetableSummaryProvider);
    final currentFilter = ref.watch(timetableFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Filters
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TimetableFilterPanel(
                currentFilter: currentFilter,
                facultyList: _facultyList,
                roomList: _roomList,
                onFilterChanged: (newFilter) {
                  ref.read(timetableFilterProvider.notifier).update(newFilter);
                },
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Standardized Maroon Gradient Banner)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [maroonColor, const Color(0xFF8e005b)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: maroonColor.withValues(alpha: 0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_view_week_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Timetable',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Visualizing class schedules and potential conflicts',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _generateSchedule,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 24),
                        label: Text(
                          'GENERATE AI SCHEDULE',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: maroonColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Calendar Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: schedulesAsync.when(
                      data: (schedules) => Column(
                        children: [
                          if (currentFilter.facultyId != null &&
                              schedules.isNotEmpty)
                            _buildInstructorSummary(schedules),
                          Expanded(
                            child: WeeklyCalendarView(
                              schedules: schedules,
                              maroonColor: maroonColor,
                              availabilities: currentFilter.facultyId != null
                                  ? ref
                                      .watch(
                                        facultyAvailabilityProvider(
                                          currentFilter.facultyId!,
                                        ),
                                      )
                                      .maybeWhen(
                                        data: (v) => v,
                                        orElse: () => null,
                                      )
                                  : null,
                              selectedFaculty: currentFilter.facultyId != null
                                  ? _facultyList.firstWhere(
                                      (f) => f.id == currentFilter.facultyId,
                                    )
                                  : null,
                              isInstructorView: currentFilter.facultyId != null,
                              onEdit: (s) {
                                // TODO: Open edit modal
                              },
                            ),
                          ),
                        ],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary Side Panel (Floating-like)
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: summaryAsync.when(
                data: (summary) => TimetableSummaryPanel(summary: summary),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading summary'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSummary(List<ScheduleInfo> schedules) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    final faculty = schedules.first.schedule.faculty;
    if (faculty == null) return const SizedBox.shrink();

    double totalHours = 0;
    for (var s in schedules) {
      final ts = s.schedule.timeslot;
      if (ts == null) continue;
      final start = _parseTime(ts.startTime);
      final end = _parseTime(ts.endTime);
      totalHours +=
          (end.hour - start.hour) + (end.minute - start.minute) / 60.0;
    }

    final efficiency = (totalHours / (faculty.maxLoad ?? 1)) * 100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: maroonColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: maroonColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: maroonColor,
            radius: 20,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faculty.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${faculty.employmentStatus?.name.toUpperCase() ?? ""} ${faculty.program?.name.toUpperCase() ?? ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryStat('Total Hours', '${totalHours.toStringAsFixed(1)}h'),
          _buildSummaryStat('Load', '${efficiency.toStringAsFixed(0)}%'),
          _buildSummaryStat('Subjects', '${schedules.length}'),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: maroonColor,
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
