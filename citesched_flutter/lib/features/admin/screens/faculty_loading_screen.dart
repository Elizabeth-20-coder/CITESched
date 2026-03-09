import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/core/utils/date_utils.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/features/admin/screens/faculty_load_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:citesched_flutter/core/providers/conflict_provider.dart';
import 'package:citesched_flutter/core/providers/admin_providers.dart';
import 'package:citesched_flutter/core/providers/schedule_sync_provider.dart';

String _programDisplayLabel(Program program) {
  switch (program) {
    case Program.it:
      return 'BSIT';
    case Program.emc:
      return 'BSEMC';
  }
}

String _sectionDisplayLabel(Section section) {
  final code = section.sectionCode.trim();
  final program = _programDisplayLabel(section.program);
  if (code.toUpperCase().startsWith('$program -')) return code;
  return '$program - $code';
}

String _getDayAbbr(DayOfWeek day) {
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

const Set<String> _labRoomNames = {'IT LAB', 'EMC LAB'};
const String _lectureRoomName = 'ROOM 1';

String _normalizedRoomName(String value) => value.trim().toUpperCase();

bool _requiresLaboratoryRoom(List<SubjectType> types) {
  return types.contains(SubjectType.laboratory) ||
      types.contains(SubjectType.blended);
}

double _hoursForSubjectTypes(List<SubjectType> types) {
  final hasLecture = types.contains(SubjectType.lecture);
  final hasLaboratory = types.contains(SubjectType.laboratory);
  final hasBlended = types.contains(SubjectType.blended);

  if (hasBlended || (hasLecture && hasLaboratory)) return 5.0;
  if (hasLaboratory) return 3.0;
  return 2.0;
}

String _formatLoadValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

bool _isRoomAllowedForTypes({
  required Room room,
  required List<SubjectType> loadTypes,
}) {
  final normalizedName = _normalizedRoomName(room.name);
  if (_requiresLaboratoryRoom(loadTypes)) {
    return _labRoomNames.contains(normalizedName);
  }
  return normalizedName == _lectureRoomName;
}

bool _isSupportedSchedulingRoom(Room room) {
  final normalizedName = _normalizedRoomName(room.name);
  return normalizedName == _lectureRoomName ||
      _labRoomNames.contains(normalizedName);
}

String _facultyNameById(List<Faculty> list, int? id) {
  if (id == null) return 'Unknown faculty';
  for (final f in list) {
    if (f.id == id) return f.name;
  }
  return 'Faculty #$id';
}

String _subjectNameById(List<Subject> list, int? id) {
  if (id == null) return 'Unknown subject';
  for (final s in list) {
    if (s.id == id) return s.name;
  }
  return 'Subject #$id';
}

Program? _programForSectionId(List<Section> sections, int? sectionId) {
  if (sectionId == null) return null;
  for (final section in sections) {
    if (section.id == sectionId) return section.program;
  }
  return null;
}

Program? _programForFacultyId(List<Faculty> faculties, int? facultyId) {
  if (facultyId == null) return null;
  for (final faculty in faculties) {
    if (faculty.id == facultyId) return faculty.program;
  }
  return null;
}

Program? _programForSubjectId(List<Subject> subjects, int? subjectId) {
  if (subjectId == null) return null;
  for (final subject in subjects) {
    if (subject.id == subjectId) return subject.program;
  }
  return null;
}

List<Subject> _subjectsAssignedToFaculty(
  List<Subject> subjects,
  int? facultyId,
) {
  if (facultyId == null) return const [];
  return subjects.where((s) => s.isActive && s.facultyId == facultyId).toList();
}

String _roomNameById(List<Room> list, int? id) {
  if (id == null) return 'Unknown room';
  for (final r in list) {
    if (r.id == id) return r.name;
  }
  return 'Room #$id';
}

String _sectionLabelById(
  List<Section> list,
  int? id,
  String? fallbackCode,
) {
  if (id != null) {
    for (final s in list) {
      if (s.id == id) return _sectionDisplayLabel(s);
    }
  }
  if (fallbackCode != null && fallbackCode.trim().isNotEmpty) {
    return fallbackCode.trim();
  }
  return 'Unknown section';
}

String _timeslotLabelById(List<Timeslot> list, int? id) {
  if (id == null) return 'TBA';
  for (final t in list) {
    if (t.id == id) {
      return CITESchedDateUtils.formatTimeslot(
        t.day,
        t.startTime,
        t.endTime,
      );
    }
  }
  return 'Timeslot #$id';
}

int _timeToMinutes(String time) {
  var value = time.trim();
  if (value.isEmpty) return 0;

  final upper = value.toUpperCase();
  final hasAm = upper.contains('AM');
  final hasPm = upper.contains('PM');

  if (hasAm || hasPm) {
    final pieces = upper.split(' ');
    final clock = pieces.first;
    final clockParts = clock.split(':');
    if (clockParts.length < 2) return 0;
    var hour = int.tryParse(clockParts[0]) ?? 0;
    final minute =
        int.tryParse(clockParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (hasPm && hour < 12) hour += 12;
    if (hasAm && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  final parts = value.split(':');
  if (parts.length < 2) return 0;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return hour * 60 + minute;
}

bool _timeslotWithinAvailability(Timeslot slot, FacultyAvailability avail) {
  if (slot.day != avail.dayOfWeek) return false;
  final slotStart = _timeToMinutes(slot.startTime);
  final slotEnd = _timeToMinutes(slot.endTime);
  final availStart = _timeToMinutes(avail.startTime);
  final availEnd = _timeToMinutes(avail.endTime);
  if (slotEnd <= slotStart || availEnd <= availStart) return false;
  // Strict match: only show timeslots that exactly match availability windows.
  return slotStart == availStart && slotEnd == availEnd;
}

bool _timeslotMatchesAvailabilityWindow(
  Timeslot slot,
  FacultyAvailability avail,
) {
  if (slot.day != avail.dayOfWeek) return false;
  return _timeToMinutes(slot.startTime) == _timeToMinutes(avail.startTime) &&
      _timeToMinutes(slot.endTime) == _timeToMinutes(avail.endTime);
}

List<Timeslot> _dedupeTimeslotsByWindow(List<Timeslot> timeslots) {
  final byWindow = <String, Timeslot>{};
  for (final slot in timeslots) {
    final key = '${slot.day.name}|${slot.startTime}|${slot.endTime}';
    final existing = byWindow[key];
    if (existing == null) {
      byWindow[key] = slot;
      continue;
    }
    final existingId = existing.id ?? 1 << 30;
    final slotId = slot.id ?? 1 << 30;
    if (slotId < existingId) {
      byWindow[key] = slot;
    }
  }
  return byWindow.values.toList();
}

Future<void> _createTimeslotsFromAvailability({
  required WidgetRef ref,
  required BuildContext context,
  required List<FacultyAvailability> availabilityList,
}) async {
  if (availabilityList.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No availability to generate timeslots from.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final existing = await client.admin.getAllTimeslots();
    final existingKeys = existing
        .map((t) => '${t.day.name}|${t.startTime}|${t.endTime}')
        .toSet();

    var createdCount = 0;
    for (final avail in availabilityList) {
      final key = '${avail.dayOfWeek.name}|${avail.startTime}|${avail.endTime}';
      if (existingKeys.contains(key)) continue;
      final label =
          '${_getDayAbbr(avail.dayOfWeek)} ${avail.startTime}-${avail.endTime}';
      await client.admin.createTimeslot(
        Timeslot(
          day: avail.dayOfWeek,
          startTime: avail.startTime,
          endTime: avail.endTime,
          label: label,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      createdCount += 1;
    }

    ref.invalidate(timeslotsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount > 0
                ? 'Created $createdCount timeslot(s).'
                : 'All matching timeslots already exist.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create timeslots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

bool _matchesSection(
  Schedule schedule,
  int? sectionId,
  String? sectionCodeFallback,
) {
  if (sectionId != null && schedule.sectionId != null) {
    return schedule.sectionId == sectionId;
  }
  if (sectionCodeFallback != null && sectionCodeFallback.trim().isNotEmpty) {
    return schedule.section.trim() == sectionCodeFallback.trim();
  }
  return false;
}

String? _detectAssignmentConflict({
  required List<Schedule> schedules,
  required int? currentScheduleId,
  required int facultyId,
  required int subjectId,
  required int? sectionId,
  required String? sectionCodeFallback,
  required int? roomId,
  required int? timeslotId,
  required bool isAutoAssign,
  required List<Faculty> facultyList,
  required List<Subject> subjectList,
  required List<Room> roomList,
  required List<Timeslot> timeslotList,
  required List<Section> sectionList,
}) {
  final facultyName = _facultyNameById(facultyList, facultyId);
  final subjectName = _subjectNameById(subjectList, subjectId);
  final sectionLabel = _sectionLabelById(
    sectionList,
    sectionId,
    sectionCodeFallback,
  );
  final timeslotLabel = _timeslotLabelById(timeslotList, timeslotId);
  final roomLabel = _roomNameById(roomList, roomId);

  for (final schedule in schedules) {
    if (currentScheduleId != null && schedule.id == currentScheduleId) {
      continue;
    }

    final sameSection = _matchesSection(
      schedule,
      sectionId,
      sectionCodeFallback,
    );

    if (sameSection &&
        schedule.subjectId == subjectId &&
        schedule.facultyId != facultyId) {
      final otherFaculty = _facultyNameById(facultyList, schedule.facultyId);
      return 'Subject $subjectName is already assigned to $otherFaculty for $sectionLabel.';
    }

    if (sameSection &&
        schedule.subjectId == subjectId &&
        schedule.facultyId == facultyId) {
      return 'This assignment already exists for $facultyName in $sectionLabel.';
    }

    if (!isAutoAssign &&
        timeslotId != null &&
        schedule.facultyId == facultyId &&
        schedule.timeslotId == timeslotId) {
      return '$facultyName already has a class at $timeslotLabel.';
    }

    if (!isAutoAssign &&
        roomId != null &&
        timeslotId != null &&
        schedule.roomId == roomId &&
        schedule.timeslotId == timeslotId) {
      return 'Room $roomLabel is already booked at $timeslotLabel.';
    }
  }

  return null;
}

class FacultyLoadingScreen extends ConsumerStatefulWidget {
  const FacultyLoadingScreen({super.key});

  @override
  ConsumerState<FacultyLoadingScreen> createState() =>
      _FacultyLoadingScreenState();
}

class _FacultyLoadingScreenState extends ConsumerState<FacultyLoadingScreen> {
  String _searchQuery = '';
  String? _selectedFaculty;
  bool _showConflictDetails = false;
  final TextEditingController _searchController = TextEditingController();

  // Color scheme matching admin sidebar
  final Color maroonColor = const Color(0xFF720045);
  final Color innerMenuBg = const Color(0xFF7b004f);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewAssignmentModal() {
    showDialog(
      context: context,
      builder: (context) => _NewAssignmentModal(
        maroonColor: maroonColor,
        onSuccess: () {
          notifyScheduleDataChanged(ref);
          ref.invalidate(schedulesProvider);
        },
      ),
    );
  }

  void _showEditAssignmentModal(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => _EditAssignmentModal(
        schedule: schedule,
        maroonColor: maroonColor,
        onSuccess: () {
          notifyScheduleDataChanged(ref);
          ref.invalidate(schedulesProvider);
        },
      ),
    );
  }

  void _deleteSchedule(Schedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Assignment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this schedule assignment?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await client.admin.deleteSchedule(schedule.id!);
        notifyScheduleDataChanged(ref);
        ref.invalidate(schedulesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting assignment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);
    final allConflicts = ref.watch(allConflictsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final isMobile = ResponsiveHelper.isMobile(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: maroonColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: maroonColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Faculty Loading',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage faculty schedule assignments and workload',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showNewAssignmentModal,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        'Assign Subject',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: maroonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
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
              const SizedBox(height: 24),

              // Conflict Warning Banner
              _buildConflictBanner(
                schedulesAsync,
                facultyAsync,
                allConflicts,
              ),
              const SizedBox(height: 20),

              // Search and Filter Row
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.transparent
                              : Colors.grey[300]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: maroonColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              cursorColor: maroonColor,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Search by faculty, subject, or section...',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Faculty Filter
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.transparent
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: facultyAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => const Text('Error'),
                        data: (faculty) => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFaculty,
                            hint: Text(
                              'Filter by Faculty',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  'All Faculty',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                              ...faculty.map(
                                (f) => DropdownMenuItem<String>(
                                  value: f.id.toString(),
                                  child: Text(
                                    f.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedFaculty = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: maroonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: maroonColor.withValues(alpha: 0.2),
                    ),
                  ),
                  indicatorColor: maroonColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: maroonColor,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Faculty Loading Summary'),
                    Tab(text: 'Subject Assignments'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Content Area
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFacultySummaryView(
                      schedulesAsync,
                      facultyAsync,
                      subjectsAsync,
                      roomsAsync,
                      timeslotsAsync,
                      isDark,
                    ),
                    _buildSubjectAssignmentsView(
                      schedulesAsync,
                      facultyAsync,
                      subjectsAsync,
                      roomsAsync,
                      timeslotsAsync,
                      isDark,
                      maroonColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectAssignmentsView(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
    AsyncValue<List<Subject>> subjectsAsync,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<Timeslot>> timeslotsAsync,
    bool isDark,
    Color maroonColor,
  ) {
    return Column(
      children: [
        Expanded(
          child: schedulesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading schedules',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(schedulesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (schedules) {
              return facultyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(child: Text('Error')),
                data: (facultyList) {
                  return subjectsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Center(child: Text('Error')),
                    data: (subjectList) {
                      return roomsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) =>
                            const Center(child: Text('Error')),
                        data: (roomList) {
                          return timeslotsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) =>
                                const Center(child: Text('Error')),
                            data: (timeslotList) {
                              // Create maps for lookup
                              final facultyMap = {
                                for (var f in facultyList) f.id!: f,
                              };
                              final subjectMap = {
                                for (var s in subjectList) s.id!: s,
                              };
                              final roomMap = {
                                for (var r in roomList) r.id!: r,
                              };
                              final timeslotMap = {
                                for (var t in timeslotList) t.id!: t,
                              };

                              final filteredSchedules = schedules.where((
                                schedule,
                              ) {
                                final matchesSearch =
                                    _searchQuery.isEmpty ||
                                    () {
                                      final faculty =
                                          facultyMap[schedule.facultyId];
                                      final subject =
                                          subjectMap[schedule.subjectId];
                                      return (faculty?.name
                                                  .toLowerCase()
                                                  .contains(_searchQuery) ??
                                              false) ||
                                          (subject?.name.toLowerCase().contains(
                                                _searchQuery,
                                              ) ??
                                              false) ||
                                          schedule.section
                                              .toLowerCase()
                                              .contains(_searchQuery);
                                    }();

                                final matchesFaculty =
                                    _selectedFaculty == null ||
                                    schedule.facultyId.toString() ==
                                        _selectedFaculty;

                                return matchesSearch && matchesFaculty;
                              }).toList();

                              if (filteredSchedules.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchQuery.isEmpty
                                            ? 'No assignments yet'
                                            : 'No assignments found',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (_searchQuery.isEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Click "New Assignment" to get started',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: maroonColor.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.assignment_rounded,
                                            color: maroonColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Schedule Assignments',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: maroonColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: maroonColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${filteredSchedules.length} Total',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minWidth: constraints.maxWidth,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: DataTable(
                                                  headingRowColor:
                                                      WidgetStateProperty.all(
                                                        maroonColor,
                                                      ),
                                                  headingTextStyle:
                                                      GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        letterSpacing: 0.5,
                                                      ),
                                                  dataRowMinHeight: 70,
                                                  dataRowMaxHeight: 90,
                                                  columnSpacing: 28,
                                                  horizontalMargin: 24,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('FACULTY'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('SUBJECT'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('SECTION'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('YEAR'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('LOAD'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('UNITS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('HOURS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'ROOM & SCHEDULE',
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text('STATUS'),
                                                    ),
                                                    DataColumn(
                                                      label: Text('ACTIONS'),
                                                    ),
                                                  ],
                                                  rows: filteredSchedules.asMap().entries.map((
                                                    entry,
                                                  ) {
                                                    final schedule =
                                                        entry.value;
                                                    final index = entry.key;
                                                    final faculty =
                                                        facultyMap[schedule
                                                            .facultyId];
                                                    final subject =
                                                        subjectMap[schedule
                                                            .subjectId];
                                                    final room =
                                                        roomMap[schedule
                                                            .roomId];
                                                    final timeslot =
                                                        timeslotMap[schedule
                                                            .timeslotId];

                                                    final isAutoAssign =
                                                        schedule.roomId == -1 ||
                                                        schedule.timeslotId ==
                                                            -1;

                                                    return DataRow(
                                                      color: WidgetStateProperty.resolveWith<Color?>(
                                                        (states) {
                                                          if (states.contains(
                                                            WidgetState.hovered,
                                                          )) {
                                                            return maroonColor
                                                                .withValues(
                                                                  alpha: 0.05,
                                                                );
                                                          }
                                                          return index.isEven
                                                              ? (isDark
                                                                    ? Colors
                                                                          .white
                                                                          .withValues(
                                                                            alpha:
                                                                                0.02,
                                                                          )
                                                                    : Colors
                                                                          .grey
                                                                          .withValues(
                                                                            alpha:
                                                                                0.02,
                                                                          ))
                                                              : null;
                                                        },
                                                      ),
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    colors: [
                                                                      maroonColor,
                                                                      maroonColor.withValues(
                                                                        alpha:
                                                                            0.7,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    (faculty?.name.isNotEmpty ??
                                                                            false)
                                                                        ? faculty!
                                                                              .name[0]
                                                                              .toUpperCase()
                                                                        : '?',
                                                                    style: GoogleFonts.poppins(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 12,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    faculty?.name ??
                                                                        'Unknown',
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  if (faculty
                                                                          ?.facultyId !=
                                                                      null)
                                                                    Text(
                                                                      'ID: ${faculty!.facultyId}',
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                subject?.name ??
                                                                    'Unknown',
                                                                style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                              if (subject
                                                                      ?.code !=
                                                                  null)
                                                                Text(
                                                                  subject!.code,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .grey[600],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: maroonColor
                                                                  .withValues(
                                                                    alpha: 0.08,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              schedule.section,
                                                              style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                                color:
                                                                    maroonColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            subject?.yearLevel
                                                                    ?.toString() ??
                                                                '-',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  _getLoadTypeColor(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ).withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    _getLoadTypeColor(
                                                                      schedule
                                                                          .loadTypes,
                                                                    ).withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  _getLoadTypeIcon(
                                                                    (schedule.loadTypes !=
                                                                                null &&
                                                                            schedule.loadTypes!.isNotEmpty)
                                                                        ? schedule
                                                                              .loadTypes!
                                                                              .first
                                                                        : null,
                                                                  ),
                                                                  size: 14,
                                                                  color: _getLoadTypeColor(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  _getLoadTypeText(
                                                                    schedule
                                                                        .loadTypes,
                                                                  ),
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: _getLoadTypeColor(
                                                                      schedule
                                                                          .loadTypes,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            schedule.units
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            schedule.hours
                                                                    ?.toString() ??
                                                                'N/A',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .meeting_room_rounded,
                                                                    size: 16,
                                                                    color:
                                                                        isAutoAssign
                                                                        ? Colors
                                                                              .orange
                                                                        : maroonColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    room?.name ??
                                                                        'Waiting for AI...',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          isAutoAssign
                                                                          ? Colors.orange
                                                                          : Colors.black87,
                                                                      fontStyle:
                                                                          isAutoAssign
                                                                          ? FontStyle.italic
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time_rounded,
                                                                    size: 16,
                                                                    color:
                                                                        isAutoAssign
                                                                        ? Colors
                                                                              .orange
                                                                        : Colors
                                                                              .grey[600],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    timeslot !=
                                                                            null
                                                                        ? '${_getDayAbbr(timeslot.day)} ${timeslot.startTime}-${timeslot.endTime}'
                                                                        : 'Waiting for AI...',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          isAutoAssign
                                                                          ? Colors.orange
                                                                          : Colors.grey[700],
                                                                      fontStyle:
                                                                          isAutoAssign
                                                                          ? FontStyle.italic
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors:
                                                                    isAutoAssign
                                                                    ? [
                                                                        Colors
                                                                            .orange,
                                                                        Colors.orange.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                      ]
                                                                    : [
                                                                        Colors
                                                                            .green,
                                                                        Colors.green.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                      ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color:
                                                                      (isAutoAssign
                                                                              ? Colors.orange
                                                                              : Colors.green)
                                                                          .withValues(
                                                                            alpha:
                                                                                0.3,
                                                                          ),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  isAutoAssign
                                                                      ? Icons
                                                                            .pending_actions
                                                                      : Icons
                                                                            .check_circle,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const SizedBox(
                                                                  width: 6,
                                                                ),
                                                                Text(
                                                                  isAutoAssign
                                                                      ? 'Pending AI'
                                                                      : 'Scheduled',
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  onTap: () =>
                                                                      _showEditAssignmentModal(
                                                                        schedule,
                                                                      ),
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: maroonColor.withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .edit_outlined,
                                                                      color:
                                                                          maroonColor,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  onTap: () =>
                                                                      _deleteSchedule(
                                                                        schedule,
                                                                      ),
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red
                                                                          .withValues(
                                                                            alpha:
                                                                                0.1,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFacultySummaryView(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
    AsyncValue<List<Subject>> subjectsAsync,
    AsyncValue<List<Room>> roomsAsync,
    AsyncValue<List<Timeslot>> timeslotsAsync,
    bool isDark,
  ) {
    final maroonColor = const Color(0xFF4f003b);

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (schedules) => facultyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (facultyList) {
          final subjectList = subjectsAsync.maybeWhen(
            data: (d) => d,
            orElse: () => <Subject>[],
          );
          final timeslotList = timeslotsAsync.maybeWhen(
            data: (d) => d,
            orElse: () => <Timeslot>[],
          );

          final subjectMap = {for (var s in subjectList) s.id ?? -1: s};
          final timeslotMap = {for (var t in timeslotList) t.id ?? -1: t};
          final allConflicts = ref.watch(allConflictsProvider);

          // Pre-calculate stats for each faculty to avoid work in build/rows
          final List<Map<String, dynamic>> facultyStats = facultyList
              .where((f) {
                if (_searchQuery.isEmpty) return true;
                return f.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              })
              .map((faculty) {
                final assignments = schedules
                    .where((s) => s.facultyId == faculty.id)
                    .toList();

                double totalUnits = 0;
                double totalHours = 0;
                bool hasConflicts = false;

                for (var schedule in assignments) {
                  // Units from schedule or fallback to subject
                  totalUnits +=
                      schedule.units ??
                      (subjectMap[schedule.subjectId]?.units.toDouble() ?? 0.0);

                  // Hours (prefer explicit hours field, fallback to timeslot)
                  if (schedule.hours != null) {
                    totalHours += schedule.hours!;
                  } else if (schedule.timeslotId != null) {
                    final t = timeslotMap[schedule.timeslotId];
                    if (t != null) {
                      try {
                        final startParts = t.startTime.split(':');
                        final endParts = t.endTime.split(':');
                        final startMin =
                            int.parse(startParts[0]) * 60 +
                            int.parse(startParts[1]);
                        final endMin =
                            int.parse(endParts[0]) * 60 +
                            int.parse(endParts[1]);
                        totalHours += (endMin - startMin) / 60.0;
                      } catch (e) {
                        /* ignore */
                      }
                    }
                  }

                  // Conflicts check
                  final conflictsForSchedule = allConflicts.maybeWhen(
                    data: (conflicts) => conflicts
                        .where(
                          (c) =>
                              c.facultyId == faculty.id ||
                              c.conflictingScheduleId == schedule.id ||
                              c.scheduleId == schedule.id,
                        )
                        .isNotEmpty,
                    orElse: () => false,
                  );

                  if (conflictsForSchedule) hasConflicts = true;
                }

                return {
                  'faculty': faculty,
                  'assignedSubjects': assignments.length,
                  'totalUnits': totalUnits,
                  'totalHours': totalHours,
                  'hasConflicts': hasConflicts,
                  'remainingLoad': (faculty.maxLoad ?? 0) - totalUnits,
                };
              })
              .toList();

          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 24,
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  maroonColor.withValues(alpha: 0.05),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'FACULTY NAME',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'SUBJECTS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'UNITS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'HOURS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'REMAINING',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                rows: facultyStats.map((stats) {
                  final f = stats['faculty'] as Faculty;
                  final hasC = stats['hasConflicts'] as bool;
                  final remLoad = stats['remainingLoad'] as double;

                  return DataRow(
                    onSelectChanged: (_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacultyLoadDetailsScreen(
                            faculty: f,
                            initialSchedules: schedules
                                .where((s) => s.facultyId == f.id)
                                .toList(),
                          ),
                        ),
                      );
                    },
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            if (hasC)
                              const Icon(
                                Icons.warning_rounded,
                                color: Colors.orange,
                                size: 16,
                              ),
                            if (hasC) const SizedBox(width: 4),
                            Text(
                              f.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          stats['assignedSubjects'].toString(),
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DataCell(
                        Text(
                          stats['totalUnits'].toString(),
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${(stats['totalHours'] as double).toStringAsFixed(1)}h',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: remLoad < 0
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            remLoad.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              color: remLoad < 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        hasC
                            ? const Icon(Icons.error_outline, color: Colors.red)
                            : const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getLoadTypeColor(List<SubjectType>? types) {
    if (types == null || types.isEmpty) return Colors.grey;
    if (types.contains(SubjectType.lecture) &&
        types.contains(SubjectType.laboratory))
      return Colors.orange;
    if (types.contains(SubjectType.lecture)) return Colors.purple;
    if (types.contains(SubjectType.laboratory)) return Colors.teal;
    return Colors.blue;
  }

  String _getLoadTypeText(List<SubjectType>? types) {
    if (types == null || types.isEmpty) return 'N/A';
    return types.map((t) => t.name.toUpperCase()).join(' / ');
  }

  IconData _getLoadTypeIcon(SubjectType? type) {
    if (type == null) return Icons.help_outline;
    switch (type) {
      case SubjectType.lecture:
        return Icons.menu_book;
      case SubjectType.laboratory:
        return Icons.science;
      case SubjectType.blended:
        return Icons.layers_outlined;
    }
  }

  String _getDayAbbr(DayOfWeek day) {
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

  Widget _buildConflictBanner(
    AsyncValue<List<Schedule>> schedulesAsync,
    AsyncValue<List<Faculty>> facultyAsync,
    AsyncValue<List<ScheduleConflict>> allConflicts,
  ) {
    return schedulesAsync.when(
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
      data: (schedules) {
        // Use centralized conflict service results for professional detail.
        final conflicts = allConflicts.maybeWhen(
          data: (list) => list
              .map(
                (c) => c.details != null && c.details!.isNotEmpty
                    ? '${c.message}” ${c.details}'
                    : c.message,
              )
              .toList(),
          orElse: () => <String>[],
        );
        final hasConflicts = conflicts.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: hasConflicts ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: hasConflicts ? Colors.red : Colors.green,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: (hasConflicts ? Colors.red : Colors.green).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: hasConflicts
                    ? () {
                        setState(() {
                          _showConflictDetails = !_showConflictDetails;
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasConflicts
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          hasConflicts
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          color: hasConflicts ? Colors.red : Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasConflicts
                                  ? 'Schedule Conflicts Detected'
                                  : 'No Conflicts Detected',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: hasConflicts
                                    ? Colors.red[900]
                                    : Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasConflicts
                                  ? '${conflicts.length} conflict(s) found. Click to view details.'
                                  : 'All faculty schedules are properly assigned without conflicts.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: hasConflicts
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasConflicts)
                        Icon(
                          _showConflictDetails
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.red[700],
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
              if (hasConflicts && _showConflictDetails)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conflict Details:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...conflicts.take(5).map((conflict) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  conflict,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (conflicts.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '... and ${conflicts.length - 5} more conflicts',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// New Assignment Modal
class _NewAssignmentModal extends ConsumerStatefulWidget {
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _NewAssignmentModal({
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<_NewAssignmentModal> createState() =>
      _NewAssignmentModalState();
}

class _NewAssignmentModalState extends ConsumerState<_NewAssignmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _hoursController = TextEditingController();

  int? _selectedFacultyId;
  int? _selectedSubjectId;
  int? _selectedSectionId;
  int? _selectedRoomId;
  int? _selectedTimeslotId;
  bool _isAutoAssign = false;
  bool _isLoading = false;

  void _applySubjectDefaults(Subject? subject) {
    if (subject == null) {
      _unitsController.clear();
      _hoursController.clear();
      return;
    }
    _unitsController.text = _formatLoadValue(subject.units.toDouble());
    _hoursController.text = _formatLoadValue(
      _hoursForSubjectTypes(subject.types),
    );
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sections = ref
          .read(sectionListProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Section>[],
          );
      final section = sections.firstWhere(
        (s) => s.id == _selectedSectionId,
        orElse: () => sections.isNotEmpty
            ? sections.first
            : Section(
                sectionCode: '',
                program: Program.it,
                yearLevel: 1,
                semester: 1,
                academicYear: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
      );

      final schedules = ref
          .read(schedulesProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Schedule>[],
          );
      final facultyList = ref
          .read(facultyListProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Faculty>[],
          );
      final subjectList = ref
          .read(subjectsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Subject>[],
          );
      final roomList = ref
          .read(roomsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Room>[],
          );
      final timeslotList = ref
          .read(timeslotsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Timeslot>[],
          );
      Faculty? selectedFaculty;
      for (final faculty in facultyList) {
        if (faculty.id == _selectedFacultyId) {
          selectedFaculty = faculty;
          break;
        }
      }
      Subject? selectedSubject;
      for (final subject in subjectList) {
        if (subject.id == _selectedSubjectId) {
          selectedSubject = subject;
          break;
        }
      }
      if (selectedSubject == null) {
        throw Exception(
          'Please select a valid subject assigned to this faculty.',
        );
      }
      if (selectedFaculty == null) {
        throw Exception('Please select a valid faculty member.');
      }
      if (selectedFaculty.program != null &&
          selectedFaculty.program != section.program) {
        throw Exception(
          'Faculty program must match the selected section program.',
        );
      }
      if (selectedSubject.program != section.program) {
        throw Exception(
          'Subject program must match the selected section program.',
        );
      }

      final effectiveTypes = selectedSubject.types;

      if (!_isAutoAssign && _selectedRoomId != null) {
        Room? selectedRoom;
        for (final room in roomList) {
          if (room.id == _selectedRoomId) {
            selectedRoom = room;
            break;
          }
        }
        if (selectedRoom != null && !_isSupportedSchedulingRoom(selectedRoom)) {
          throw Exception(
            'Only IT LAB, EMC LAB, and ROOM 1 are allowed for scheduling.',
          );
        }
        if (selectedRoom != null &&
            effectiveTypes.isNotEmpty &&
            !_isRoomAllowedForTypes(
              room: selectedRoom,
              loadTypes: effectiveTypes,
            )) {
          throw Exception(
            _requiresLaboratoryRoom(effectiveTypes)
                ? 'Laboratory or blended subjects can only be assigned to IT LAB or EMC LAB.'
                : 'Lecture-only subjects can only be assigned to ROOM 1.',
          );
        }
      }

      final conflictMessage = _detectAssignmentConflict(
        schedules: schedules,
        currentScheduleId: null,
        facultyId: _selectedFacultyId!,
        subjectId: _selectedSubjectId!,
        sectionId: _selectedSectionId,
        sectionCodeFallback: section.sectionCode,
        roomId: _selectedRoomId,
        timeslotId: _selectedTimeslotId,
        isAutoAssign: _isAutoAssign,
        facultyList: facultyList,
        subjectList: subjectList,
        roomList: roomList,
        timeslotList: timeslotList,
        sectionList: sections,
      );

      if (conflictMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(conflictMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final schedule = Schedule(
        facultyId: _selectedFacultyId!,
        subjectId: _selectedSubjectId!,
        roomId: _isAutoAssign ? null : _selectedRoomId,
        timeslotId: _isAutoAssign ? null : _selectedTimeslotId,
        section: section.sectionCode,
        sectionId: _selectedSectionId,
        loadTypes: selectedSubject.types,
        units: selectedSubject.units.toDouble(),
        hours: _hoursForSubjectTypes(selectedSubject.types),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await client.admin.createSchedule(schedule);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        widget.onSuccess();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Assignment created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);
    final sectionsAsync = ref.watch(sectionListProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.maroonColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_add,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'New Schedule Assignment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Faculty Dropdown
                      facultyAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading faculty'),
                        data: (facultyList) {
                          final filteredFaculty = facultyList
                              .where((f) => f.isActive && f.program != null)
                              .toList();

                          if (filteredFaculty.isEmpty) {
                            return const Text(
                              'No active faculty instructors available.',
                            );
                          }

                          return _buildDropdown<int>(
                            label: 'Faculty',
                            value: _selectedFacultyId,
                            items: filteredFaculty.map((f) => f.id!).toList(),
                            itemLabel: (id) => filteredFaculty
                                .firstWhere((f) => f.id == id)
                                .name,
                            onChanged: (value) => setState(() {
                              _selectedFacultyId = value;
                              final allSubjects = ref
                                  .read(subjectsProvider)
                                  .maybeWhen(
                                    data: (s) => s,
                                    orElse: () => <Subject>[],
                                  );
                              final allowed = _subjectsAssignedToFaculty(
                                allSubjects,
                                _selectedFacultyId,
                              );
                              if (_selectedSubjectId != null &&
                                  !allowed.any(
                                    (s) => s.id == _selectedSubjectId,
                                  )) {
                                _selectedSubjectId = null;
                                _applySubjectDefaults(null);
                              }
                            }),
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject Dropdown
                      subjectsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading subjects'),
                        data: (subjectList) {
                          final facultyProgram = _programForFacultyId(
                            ref
                                .read(facultyListProvider)
                                .maybeWhen(
                                  data: (s) => s,
                                  orElse: () => <Faculty>[],
                                ),
                            _selectedFacultyId,
                          );
                          final sectionProgram = _programForSectionId(
                            ref
                                .read(sectionListProvider)
                                .maybeWhen(
                                  data: (s) => s,
                                  orElse: () => <Section>[],
                                ),
                            _selectedSectionId,
                          );
                          if (facultyProgram != null &&
                              sectionProgram != null &&
                              facultyProgram != sectionProgram) {
                            return const Text(
                              'Selected faculty does not match the section program. Choose an aligned faculty.',
                            );
                          }
                          if (_selectedFacultyId == null) {
                            return const Text(
                              'Select a faculty member first to see assigned subjects.',
                            );
                          }
                          final filtered = _subjectsAssignedToFaculty(
                            subjectList,
                            _selectedFacultyId,
                          );
                          if (filtered.isEmpty) {
                            return const Text(
                              'No subject is assigned to this faculty in Subject Management.',
                            );
                          }
                          return _buildDropdown<int>(
                            label: 'Subject',
                            value: _selectedSubjectId,
                            items: filtered.map((s) => s.id!).toList(),
                            itemLabel: (id) =>
                                filtered.firstWhere((s) => s.id == id).name,
                            onChanged: (value) => setState(() {
                              _selectedSubjectId = value;
                              final selected = filtered.where(
                                (s) => s.id == value,
                              );
                              _applySubjectDefaults(
                                selected.isNotEmpty ? selected.first : null,
                              );
                            }),
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Section (only sections that still have active students)
                      studentsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading students'),
                        data: (students) => sectionsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading sections'),
                          data: (sections) {
                            final enrolledSectionIds = students
                                .where((s) => s.sectionId != null)
                                .map((s) => s.sectionId!)
                                .toSet();
                            final enrolledSectionCodes = students
                                .map((s) => s.section?.trim())
                                .whereType<String>()
                                .where((code) => code.isNotEmpty)
                                .toSet();
                            final filteredById = <int, Section>{};
                            final selectedFacultyProgram = _programForFacultyId(
                              ref
                                  .read(facultyListProvider)
                                  .maybeWhen(
                                    data: (s) => s,
                                    orElse: () => <Faculty>[],
                                  ),
                              _selectedFacultyId,
                            );
                            final selectedSubjectProgram = _programForSubjectId(
                              ref
                                  .read(subjectsProvider)
                                  .maybeWhen(
                                    data: (s) => s,
                                    orElse: () => <Subject>[],
                                  ),
                              _selectedSubjectId,
                            );
                            final targetProgram =
                                selectedFacultyProgram ??
                                selectedSubjectProgram;
                            for (final s in sections) {
                              if (s.id != null &&
                                  (enrolledSectionIds.contains(s.id) ||
                                      enrolledSectionCodes.contains(
                                        s.sectionCode.trim(),
                                      )) &&
                                  (targetProgram == null ||
                                      s.program == targetProgram)) {
                                filteredById[s.id!] = s;
                              }
                            }
                            final filtered = filteredById.values.toList()
                              ..sort(
                                (a, b) => _sectionDisplayLabel(
                                  a,
                                ).compareTo(_sectionDisplayLabel(b)),
                              );

                            if (filtered.isEmpty) {
                              return const Text('No sections available');
                            }

                            final items = filtered.map((s) => s.id!).toList();
                            if ((_selectedSectionId == null ||
                                    !items.contains(_selectedSectionId)) &&
                                items.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _selectedSectionId = items.first;
                                });
                              });
                            }
                            final initialId =
                                (_selectedSectionId != null &&
                                    items.contains(_selectedSectionId))
                                ? _selectedSectionId
                                : items.first;

                            return _buildDropdown<int>(
                              label: 'Section',
                              value: initialId,
                              items: items,
                              itemLabel: (id) => _sectionDisplayLabel(
                                filtered.firstWhere((s) => s.id == id),
                              ),
                              onChanged: (value) =>
                                  setState(() => _selectedSectionId = value),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Units
                      _buildTextField(
                        controller: _unitsController,
                        label: 'Units',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Hours
                      _buildTextField(
                        controller: _hoursController,
                        label: 'Hours',
                        icon: Icons.access_time,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),

                      // Auto-Assign Checkbox
                      CheckboxListTile(
                        value: _isAutoAssign,
                        onChanged: (value) {
                          setState(() {
                            _isAutoAssign = value ?? false;
                            if (_isAutoAssign) {
                              _selectedRoomId = null;
                              _selectedTimeslotId = null;
                            }
                          });
                        },
                        title: Text(
                          'Auto-Assign Room & Timeslot',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Let the system automatically assign room and time',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        activeColor: widget.maroonColor,
                      ),
                      const SizedBox(height: 16),

                      // Room & Timeslot (if not auto-assign)
                      if (!_isAutoAssign) ...[
                        roomsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading rooms'),
                          data: (roomList) {
                            final subjects = ref
                                .read(subjectsProvider)
                                .maybeWhen(
                                  data: (list) => list,
                                  orElse: () => <Subject>[],
                                );
                            Subject? selectedSubject;
                            for (final subject in subjects) {
                              if (subject.id == _selectedSubjectId) {
                                selectedSubject = subject;
                                break;
                              }
                            }
                            final effectiveTypes =
                                selectedSubject?.types ?? const <SubjectType>[];
                            final filteredRooms = effectiveTypes.isEmpty
                                ? roomList
                                      .where(_isSupportedSchedulingRoom)
                                      .toList()
                                : roomList
                                      .where(
                                        (room) => _isRoomAllowedForTypes(
                                          room: room,
                                          loadTypes: effectiveTypes,
                                        ),
                                      )
                                      .toList();

                            if (filteredRooms.isEmpty) {
                              return Text(
                                _requiresLaboratoryRoom(effectiveTypes)
                                    ? 'No lab rooms available. Only IT LAB and EMC LAB are allowed.'
                                    : 'No lecture room available. ROOM 1 is required.',
                                style: GoogleFonts.poppins(fontSize: 12),
                              );
                            }

                            return _buildDropdown<int>(
                              label: 'Room',
                              value: _selectedRoomId,
                              items: filteredRooms.map((r) => r.id!).toList(),
                              itemLabel: (id) => filteredRooms
                                  .firstWhere((r) => r.id == id)
                                  .name,
                              onChanged: (value) =>
                                  setState(() => _selectedRoomId = value),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        timeslotsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading timeslots'),
                          data: (timeslotList) {
                            if (_selectedFacultyId == null) {
                              return Text(
                                'Select a faculty member to load available timeslots',
                                style: GoogleFonts.poppins(fontSize: 12),
                              );
                            }

                            final availabilityAsync = ref.watch(
                              facultyAvailabilityProvider(_selectedFacultyId!),
                            );

                            return availabilityAsync.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text(
                                'Error loading availability',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              data: (availabilityList) {
                                final filtered = _dedupeTimeslotsByWindow(
                                  timeslotList
                                      .where(
                                        (t) => availabilityList.any(
                                          (a) =>
                                              _timeslotWithinAvailability(t, a),
                                        ),
                                      )
                                      .toList(),
                                );
                                final missingWindows = availabilityList
                                    .where(
                                      (a) => !timeslotList.any(
                                        (t) =>
                                            _timeslotMatchesAvailabilityWindow(
                                              t,
                                              a,
                                            ),
                                      ),
                                    )
                                    .toList();

                                if (availabilityList.isEmpty) {
                                  return Text(
                                    'No preferred timeslots for this faculty',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (missingWindows.isNotEmpty) ...[
                                      Text(
                                        'Some preferred windows are not yet in Timeslots.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _createTimeslotsFromAvailability(
                                              ref: ref,
                                              context: context,
                                              availabilityList:
                                                  availabilityList,
                                            ),
                                        icon: const Icon(Icons.auto_fix_high),
                                        label: Text(
                                          'Generate Missing Timeslots',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (filtered.isEmpty)
                                      Text(
                                        'No preferred timeslots for this faculty',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      )
                                    else
                                      _buildDropdown<int>(
                                        label: 'Timeslot',
                                        value: _selectedTimeslotId,
                                        items: filtered
                                            .map((t) => t.id!)
                                            .toList(),
                                        itemLabel: (id) {
                                          final t = filtered.firstWhere(
                                            (t) => t.id == id,
                                          );
                                          return CITESchedDateUtils.formatTimeslot(
                                            t.day,
                                            t.startTime,
                                            t.endTime,
                                          );
                                        },
                                        onChanged: (value) => setState(
                                          () => _selectedTimeslotId = value,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Create Assignment',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: widget.maroonColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    final uniqueItems = items.toSet().toList();
    final hasSingleMatch = value == null
        ? true
        : uniqueItems.where((item) => item == value).length == 1;
    final safeValue = hasSingleMatch ? value : null;

    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      items: uniqueItems.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.black87),
    );
  }
}

// Edit Assignment Modal (similar structure to New Assignment)
class _EditAssignmentModal extends ConsumerStatefulWidget {
  final Schedule schedule;
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _EditAssignmentModal({
    required this.schedule,
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<_EditAssignmentModal> createState() =>
      _EditAssignmentModalState();
}

class _EditAssignmentModalState extends ConsumerState<_EditAssignmentModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitsController;
  late TextEditingController _hoursController;

  late int _selectedFacultyId;
  late int _selectedSubjectId;
  int? _selectedSectionId;
  int? _selectedRoomId;
  int? _selectedTimeslotId;
  bool _isAutoAssign = false;
  bool _isLoading = false;

  void _applySubjectDefaults(Subject? subject) {
    if (subject == null) return;
    _unitsController.text = _formatLoadValue(subject.units.toDouble());
    _hoursController.text = _formatLoadValue(
      _hoursForSubjectTypes(subject.types),
    );
  }

  @override
  void initState() {
    super.initState();
    _unitsController = TextEditingController(
      text: widget.schedule.units?.toString() ?? '',
    );
    _hoursController = TextEditingController(
      text: widget.schedule.hours?.toString() ?? '',
    );
    _selectedSectionId = widget.schedule.sectionId;
    _selectedFacultyId = widget.schedule.facultyId;
    _selectedSubjectId = widget.schedule.subjectId;
    _selectedRoomId = widget.schedule.roomId == -1
        ? null
        : widget.schedule.roomId;
    _selectedTimeslotId = widget.schedule.timeslotId == -1
        ? null
        : widget.schedule.timeslotId;
    _isAutoAssign =
        widget.schedule.roomId == -1 || widget.schedule.timeslotId == -1;

    final subjects = ref
        .read(subjectsProvider)
        .maybeWhen(
          data: (s) => s,
          orElse: () => <Subject>[],
        );
    for (final subject in subjects) {
      if (subject.id == _selectedSubjectId) {
        _applySubjectDefaults(subject);
        break;
      }
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sections = ref
          .read(sectionListProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Section>[],
          );
      final section = sections.firstWhere(
        (s) => s.id == _selectedSectionId,
        orElse: () => sections.firstWhere(
          (s) => s.sectionCode == widget.schedule.section,
          orElse: () => sections.isNotEmpty
              ? sections.first
              : Section(
                  sectionCode: widget.schedule.section,
                  program: Program.it,
                  yearLevel: 1,
                  semester: 1,
                  academicYear: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
        ),
      );

      final schedules = ref
          .read(schedulesProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Schedule>[],
          );
      final facultyList = ref
          .read(facultyListProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Faculty>[],
          );
      final subjectList = ref
          .read(subjectsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Subject>[],
          );
      final roomList = ref
          .read(roomsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Room>[],
          );
      final timeslotList = ref
          .read(timeslotsProvider)
          .maybeWhen(
            data: (s) => s,
            orElse: () => <Timeslot>[],
          );
      Subject? selectedSubject;
      for (final subject in subjectList) {
        if (subject.id == _selectedSubjectId) {
          selectedSubject = subject;
          break;
        }
      }
      if (selectedSubject == null) {
        throw Exception(
          'Please select a valid subject assigned to this faculty.',
        );
      }

      final effectiveTypes = selectedSubject.types;

      if (!_isAutoAssign && _selectedRoomId != null) {
        Room? selectedRoom;
        for (final room in roomList) {
          if (room.id == _selectedRoomId) {
            selectedRoom = room;
            break;
          }
        }
        if (selectedRoom != null && !_isSupportedSchedulingRoom(selectedRoom)) {
          throw Exception(
            'Only IT LAB, EMC LAB, and ROOM 1 are allowed for scheduling.',
          );
        }
        if (selectedRoom != null &&
            effectiveTypes.isNotEmpty &&
            !_isRoomAllowedForTypes(
              room: selectedRoom,
              loadTypes: effectiveTypes,
            )) {
          throw Exception(
            _requiresLaboratoryRoom(effectiveTypes)
                ? 'Laboratory or blended subjects can only be assigned to IT LAB or EMC LAB.'
                : 'Lecture-only subjects can only be assigned to ROOM 1.',
          );
        }
      }

      final conflictMessage = _detectAssignmentConflict(
        schedules: schedules,
        currentScheduleId: widget.schedule.id,
        facultyId: _selectedFacultyId,
        subjectId: _selectedSubjectId,
        sectionId: _selectedSectionId ?? widget.schedule.sectionId,
        sectionCodeFallback: section.sectionCode,
        roomId: _selectedRoomId,
        timeslotId: _selectedTimeslotId,
        isAutoAssign: _isAutoAssign,
        facultyList: facultyList,
        subjectList: subjectList,
        roomList: roomList,
        timeslotList: timeslotList,
        sectionList: sections,
      );

      if (conflictMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(conflictMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final updatedSchedule = Schedule(
        id: widget.schedule.id,
        facultyId: _selectedFacultyId,
        subjectId: _selectedSubjectId,
        roomId: _isAutoAssign ? null : _selectedRoomId,
        timeslotId: _isAutoAssign ? null : _selectedTimeslotId,
        section: section.sectionCode,
        sectionId: _selectedSectionId ?? widget.schedule.sectionId,
        loadTypes: selectedSubject.types,
        units: selectedSubject.units.toDouble(),
        hours: _hoursForSubjectTypes(selectedSubject.types),
        createdAt: widget.schedule.createdAt,
        updatedAt: DateTime.now(),
      );

      await client.admin.updateSchedule(updatedSchedule);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        widget.onSuccess();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Edit saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyListProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final timeslotsAsync = ref.watch(timeslotsProvider);
    final sectionsAsync = ref.watch(sectionListProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.maroonColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Schedule Assignment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form (same structure as New Assignment)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Faculty Dropdown
                      facultyAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading faculty'),
                        data: (facultyList) {
                          final filteredFaculty = facultyList
                              .where((f) => f.isActive && f.program != null)
                              .toList();
                          if (!filteredFaculty.any(
                            (f) => f.id == _selectedFacultyId,
                          )) {
                            final current = facultyList.where(
                              (f) => f.id == _selectedFacultyId,
                            );
                            if (current.isNotEmpty) {
                              filteredFaculty.add(current.first);
                            }
                          }
                          return _buildDropdown<int>(
                            label: 'Faculty',
                            value: _selectedFacultyId,
                            items: filteredFaculty.map((f) => f.id!).toList(),
                            itemLabel: (id) => filteredFaculty
                                .firstWhere((f) => f.id == id)
                                .name,
                            onChanged: (value) => setState(() {
                              _selectedFacultyId = value!;
                              final allSubjects = ref
                                  .read(subjectsProvider)
                                  .maybeWhen(
                                    data: (s) => s,
                                    orElse: () => <Subject>[],
                                  );
                              final allowed = _subjectsAssignedToFaculty(
                                allSubjects,
                                _selectedFacultyId,
                              );
                              if (!allowed.any(
                                (s) => s.id == _selectedSubjectId,
                              )) {
                                _selectedSubjectId = allowed.isNotEmpty
                                    ? allowed.first.id!
                                    : _selectedSubjectId;
                                final selected = allowed.where(
                                  (s) => s.id == _selectedSubjectId,
                                );
                                _applySubjectDefaults(
                                  selected.isNotEmpty ? selected.first : null,
                                );
                              }
                            }),
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject Dropdown
                      subjectsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading subjects'),
                        data: (subjectList) {
                          final filtered = _subjectsAssignedToFaculty(
                            subjectList,
                            _selectedFacultyId,
                          );
                          if (!filtered.any(
                            (s) => s.id == _selectedSubjectId,
                          )) {
                            final current = subjectList.where(
                              (s) => s.id == _selectedSubjectId,
                            );
                            if (current.isNotEmpty) {
                              filtered.add(current.first);
                            }
                          }
                          if (filtered.isEmpty) {
                            return const Text(
                              'No subject is assigned to this faculty in Subject Management.',
                            );
                          }
                          return _buildDropdown<int>(
                            label: 'Subject',
                            value: _selectedSubjectId,
                            items: filtered.map((s) => s.id!).toList(),
                            itemLabel: (id) =>
                                filtered.firstWhere((s) => s.id == id).name,
                            onChanged: (value) => setState(() {
                              _selectedSubjectId = value!;
                              final selected = filtered.where(
                                (s) => s.id == value,
                              );
                              _applySubjectDefaults(
                                selected.isNotEmpty ? selected.first : null,
                              );
                            }),
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Section (only sections that still have active students)
                      studentsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) =>
                            const Text('Error loading students'),
                        data: (students) => sectionsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading sections'),
                          data: (sections) {
                            final enrolledSectionIds = students
                                .where((s) => s.sectionId != null)
                                .map((s) => s.sectionId!)
                                .toSet();
                            final enrolledSectionCodes = students
                                .map((s) => s.section?.trim())
                                .whereType<String>()
                                .where((code) => code.isNotEmpty)
                                .toSet();
                            final filteredById = <int, Section>{};
                            for (final s in sections) {
                              if (s.id != null &&
                                  (enrolledSectionIds.contains(s.id) ||
                                      enrolledSectionCodes.contains(
                                        s.sectionCode.trim(),
                                      ))) {
                                filteredById[s.id!] = s;
                              }
                            }
                            // Always include the schedule's current section so
                            // the edit dropdown cannot visually drift from
                            // what will actually be saved.
                            for (final s in sections) {
                              if (s.id == null) continue;
                              if (s.id == widget.schedule.sectionId ||
                                  s.sectionCode == widget.schedule.section) {
                                filteredById[s.id!] = s;
                              }
                            }
                            final filtered = filteredById.values.toList()
                              ..sort(
                                (a, b) => _sectionDisplayLabel(
                                  a,
                                ).compareTo(_sectionDisplayLabel(b)),
                              );

                            if (filtered.isEmpty) {
                              return const Text('No sections available');
                            }

                            final items = filtered.map((s) => s.id!).toList();
                            final fallbackId = filtered
                                .firstWhere(
                                  (s) =>
                                      s.id == widget.schedule.sectionId ||
                                      s.sectionCode == widget.schedule.section,
                                  orElse: () => filtered.first,
                                )
                                .id!;
                            final initialId =
                                (_selectedSectionId != null &&
                                    items.contains(_selectedSectionId))
                                ? _selectedSectionId
                                : fallbackId;

                            return _buildDropdown<int>(
                              label: 'Section',
                              value: initialId,
                              items: items,
                              itemLabel: (id) => _sectionDisplayLabel(
                                filtered.firstWhere((s) => s.id == id),
                              ),
                              onChanged: (value) =>
                                  setState(() => _selectedSectionId = value),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Units
                      _buildTextField(
                        controller: _unitsController,
                        label: 'Units',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Hours
                      _buildTextField(
                        controller: _hoursController,
                        label: 'Hours',
                        icon: Icons.access_time,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),

                      // Auto-Assign Checkbox
                      CheckboxListTile(
                        value: _isAutoAssign,
                        onChanged: (value) {
                          setState(() {
                            _isAutoAssign = value ?? false;
                            if (_isAutoAssign) {
                              _selectedRoomId = null;
                              _selectedTimeslotId = null;
                            }
                          });
                        },
                        title: Text(
                          'Auto-Assign Room & Timeslot',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Let the system automatically assign room and time',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        activeColor: widget.maroonColor,
                      ),
                      const SizedBox(height: 16),

                      // Room & Timeslot (if not auto-assign)
                      if (!_isAutoAssign) ...[
                        roomsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading rooms'),
                          data: (roomList) {
                            final subjects = ref
                                .read(subjectsProvider)
                                .maybeWhen(
                                  data: (list) => list,
                                  orElse: () => <Subject>[],
                                );
                            Subject? selectedSubject;
                            for (final subject in subjects) {
                              if (subject.id == _selectedSubjectId) {
                                selectedSubject = subject;
                                break;
                              }
                            }
                            final effectiveTypes =
                                selectedSubject?.types ?? const <SubjectType>[];
                            final filteredRooms = effectiveTypes.isEmpty
                                ? roomList
                                      .where(_isSupportedSchedulingRoom)
                                      .toList()
                                : roomList
                                      .where(
                                        (room) => _isRoomAllowedForTypes(
                                          room: room,
                                          loadTypes: effectiveTypes,
                                        ),
                                      )
                                      .toList();

                            if (filteredRooms.isEmpty) {
                              return Text(
                                _requiresLaboratoryRoom(effectiveTypes)
                                    ? 'No lab rooms available. Only IT LAB and EMC LAB are allowed.'
                                    : 'No lecture room available. ROOM 1 is required.',
                                style: GoogleFonts.poppins(fontSize: 12),
                              );
                            }

                            return _buildDropdown<int>(
                              label: 'Room',
                              value: _selectedRoomId,
                              items: filteredRooms.map((r) => r.id!).toList(),
                              itemLabel: (id) => filteredRooms
                                  .firstWhere((r) => r.id == id)
                                  .name,
                              onChanged: (value) =>
                                  setState(() => _selectedRoomId = value),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        timeslotsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) =>
                              const Text('Error loading timeslots'),
                          data: (timeslotList) {
                            final availabilityAsync = ref.watch(
                              facultyAvailabilityProvider(_selectedFacultyId),
                            );

                            return availabilityAsync.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text(
                                'Error loading availability',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              data: (availabilityList) {
                                final filtered = _dedupeTimeslotsByWindow(
                                  timeslotList
                                      .where(
                                        (t) => availabilityList.any(
                                          (a) =>
                                              _timeslotWithinAvailability(t, a),
                                        ),
                                      )
                                      .toList(),
                                );
                                final missingWindows = availabilityList
                                    .where(
                                      (a) => !timeslotList.any(
                                        (t) =>
                                            _timeslotMatchesAvailabilityWindow(
                                              t,
                                              a,
                                            ),
                                      ),
                                    )
                                    .toList();

                                if (availabilityList.isEmpty) {
                                  return Text(
                                    'No preferred timeslots for this faculty',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (missingWindows.isNotEmpty) ...[
                                      Text(
                                        'Some preferred windows are not yet in Timeslots.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _createTimeslotsFromAvailability(
                                              ref: ref,
                                              context: context,
                                              availabilityList:
                                                  availabilityList,
                                            ),
                                        icon: const Icon(Icons.auto_fix_high),
                                        label: Text(
                                          'Generate Missing Timeslots',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (filtered.isEmpty)
                                      Text(
                                        'No preferred timeslots for this faculty',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      )
                                    else
                                      _buildDropdown<int>(
                                        label: 'Timeslot',
                                        value: _selectedTimeslotId,
                                        items: filtered
                                            .map((t) => t.id!)
                                            .toList(),
                                        itemLabel: (id) {
                                          final t = filtered.firstWhere(
                                            (t) => t.id == id,
                                          );
                                          return CITESchedDateUtils.formatTimeslot(
                                            t.day,
                                            t.startTime,
                                            t.endTime,
                                          );
                                        },
                                        onChanged: (value) => setState(
                                          () => _selectedTimeslotId = value,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.maroonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: widget.maroonColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    final uniqueItems = items.toSet().toList();
    final hasSingleMatch = value == null
        ? true
        : uniqueItems.where((item) => item == value).length == 1;
    final safeValue = hasSingleMatch ? value : null;

    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: widget.maroonColor, width: 2),
        ),
      ),
      items: uniqueItems.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.black87),
    );
  }
}
