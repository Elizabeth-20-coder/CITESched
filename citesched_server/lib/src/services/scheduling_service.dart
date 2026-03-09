import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'conflict_service.dart';

/// Service class for handling scheduling logic.
/// Uses [ConflictService] to validate schedule entries and generates schedules.
/// Respects faculty availability preferences from the FacultyAvailability table.
class SchedulingService {
  final ConflictService _conflictService = ConflictService();
  static const Set<String> _labRoomNames = {'IT LAB', 'EMC LAB'};
  static const String _lectureRoomName = 'ROOM 1';

  /// Generate schedules using a greedy algorithm.
  /// Attempts to assign each subject to available timeslots while respecting
  /// all constraints including faculty day/time availability.
  Future<GenerateScheduleResponse> generateSchedule(
    Session session,
    GenerateScheduleRequest request,
  ) async {
    final generatedSchedules = <Schedule>[];
    final conflicts = <ScheduleConflict>[];

    if (request.subjectIds.isEmpty) {
      return GenerateScheduleResponse(
        success: false,
        message: 'No subjects provided for schedule generation',
        totalAssigned: 0,
        conflictsDetected: 0,
        unassignedSubjects: 0,
      );
    }

    if (request.facultyIds.isEmpty) {
      return GenerateScheduleResponse(
        success: false,
        message: 'No faculty provided for schedule generation',
        totalAssigned: 0,
        conflictsDetected: 0,
        unassignedSubjects: request.subjectIds.length,
      );
    }

    if (request.sections.isEmpty) {
      return GenerateScheduleResponse(
        success: false,
        message: 'No sections provided for schedule generation',
        totalAssigned: 0,
        conflictsDetected: 0,
        unassignedSubjects: 0,
      );
    }

    final subjects = await Future.wait(
      request.subjectIds.map((id) => Subject.db.findById(session, id)),
    );
    final faculties = await Future.wait(
      request.facultyIds.map((id) => Faculty.db.findById(session, id)),
    );
    final rooms = await Future.wait(
      request.roomIds.map((id) => Room.db.findById(session, id)),
    );
    final timeslots = await Future.wait(
      request.timeslotIds.map((id) => Timeslot.db.findById(session, id)),
    );
    final existingSchedules = await Schedule.db.find(
      session,
      where: (t) => t.isActive.equals(true),
    );

    final validSubjects = subjects
        .whereType<Subject>()
        .where((s) => s.isActive)
        .toList();
    final validFaculties = faculties
        .whereType<Faculty>()
        .where((f) => f.isActive)
        .toList();
    final validRooms = rooms.whereType<Room>().where((r) => r.isActive).toList();
    final validTimeslots = timeslots.whereType<Timeslot>().toList();

    final allSections = await Section.db.find(session);
    final requestedSections = request.sections
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    final candidateSections = allSections
        .where((s) => s.isActive && requestedSections.contains(s.sectionCode.trim()))
        .toList();

    final facultyAvailMap = <int, List<FacultyAvailability>>{};
    for (final faculty in validFaculties) {
      final avails = await FacultyAvailability.db.find(
        session,
        where: (t) => t.facultyId.equals(faculty.id!),
      );
      facultyAvailMap[faculty.id!] = avails;
    }

    final facultyAssignments = <int, double>{};
    final facultyTimeslotUsage = <int, Map<int, int>>{};
    for (final faculty in validFaculties) {
      facultyAssignments[faculty.id!] = 0;
      facultyTimeslotUsage[faculty.id!] = {};
    }

    for (final existing in existingSchedules) {
      final current = facultyAssignments[existing.facultyId];
      if (current == null) continue;
      facultyAssignments[existing.facultyId] = current + (existing.units ?? 0);
      if (existing.timeslotId != null) {
        final usage = facultyTimeslotUsage[existing.facultyId]!;
        usage[existing.timeslotId!] = (usage[existing.timeslotId!] ?? 0) + 1;
      }
    }

    final assignedSubjectSectionKeys = <String>{
      for (final s in existingSchedules)
        _subjectSectionKey(s.subjectId, s.sectionId, s.section),
    };

    for (final subject in validSubjects) {
      final matchingSections = candidateSections.where((section) {
        if (section.program != subject.program) return false;
        if (subject.yearLevel != null && section.yearLevel != subject.yearLevel) {
          return false;
        }
        return true;
      }).toList();

      if (matchingSections.isEmpty) {
        conflicts.add(
          ScheduleConflict(
            type: 'generation_failed',
            message:
                'No matching section found for ${subject.name} (${subject.code})',
            details:
                'Subject program/year does not match any available active section.',
          ),
        );
        continue;
      }

      for (final section in matchingSections) {
        final pairKey = _subjectSectionKey(subject.id!, section.id, section.sectionCode);
        if (assignedSubjectSectionKeys.contains(pairKey)) {
          continue;
        }

        var assigned = false;
        final requiredHours = _requiredHours(subject);
        final eligibleRooms = _eligibleRoomsForSubject(
          rooms: validRooms,
          subject: subject,
        );
        if (eligibleRooms.isEmpty) {
          conflicts.add(
            ScheduleConflict(
              type: 'generation_failed',
              message: 'No eligible room for ${subject.name} (${subject.code})',
              details: 'No room matches subject type/program constraints.',
            ),
          );
          continue;
        }

        final rankedFaculties = [...validFaculties]..sort((a, b) {
          final aLoad = facultyAssignments[a.id!] ?? 0;
          final bLoad = facultyAssignments[b.id!] ?? 0;
          final aMax = (a.maxLoad ?? 1).toDouble();
          final bMax = (b.maxLoad ?? 1).toDouble();
          final aRatio = aMax <= 0 ? 1.0 : aLoad / aMax;
          final bRatio = bMax <= 0 ? 1.0 : bLoad / bMax;
          return aRatio.compareTo(bRatio);
        });

        for (final faculty in rankedFaculties) {
          if (assigned) break;

          // If a subject is explicitly assigned to an instructor, enforce it.
          if (subject.facultyId != null && faculty.id != subject.facultyId) {
            continue;
          }

          if (faculty.program != null && faculty.program != subject.program) {
            continue;
          }

          final currentLoad = facultyAssignments[faculty.id!] ?? 0;
          final subjectUnits = subject.units.toDouble();
          if ((currentLoad + subjectUnits) > (faculty.maxLoad ?? 0)) continue;

          final candidateTimeslots = _rankTimeslotsForFaculty(
            timeslots: validTimeslots,
            availability: facultyAvailMap[faculty.id!] ?? const [],
            timeslotUsage: facultyTimeslotUsage[faculty.id!] ?? const {},
            requiredHours: requiredHours,
          );
          if (candidateTimeslots.isEmpty) {
            continue;
          }

          for (final timeslot in candidateTimeslots) {
            if (assigned) break;

            for (final room in eligibleRooms) {
              if (assigned) break;

              final candidate = Schedule(
                subjectId: subject.id!,
                facultyId: faculty.id!,
                roomId: room.id!,
                timeslotId: timeslot.id!,
                section: section.sectionCode,
                sectionId: section.id,
                units: subject.units.toDouble(),
                hours: requiredHours,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final validationConflicts = await _conflictService.validateSchedule(
                session,
                candidate,
              );

              if (validationConflicts.isEmpty) {
                generatedSchedules.add(candidate);
                facultyAssignments[faculty.id!] =
                    (facultyAssignments[faculty.id!] ?? 0) + subjectUnits;
                final usage = facultyTimeslotUsage[faculty.id!]!;
                usage[timeslot.id!] = (usage[timeslot.id!] ?? 0) + 1;
                assignedSubjectSectionKeys.add(pairKey);
                assigned = true;
              }
            }
          }
        }

        if (!assigned) {
          var details =
              'No valid faculty/room/timeslot combination satisfies all constraints.';

          if (subject.facultyId != null) {
            final lockedFaculty = await Faculty.db.findById(session, subject.facultyId!);
            final lockedName = lockedFaculty?.name ?? 'Faculty ID ${subject.facultyId}';

            if (lockedFaculty == null || !lockedFaculty.isActive) {
              details =
                  'Subject ${subject.code} is locked to $lockedName, but that faculty member is missing or inactive.';
            } else if (!request.facultyIds.contains(lockedFaculty.id)) {
              details =
                  'Subject ${subject.code} is locked to $lockedName, but that faculty member is not included in the selected faculty filter.';
            } else if (lockedFaculty.program != null &&
                lockedFaculty.program != subject.program) {
              details =
                  'Subject ${subject.code} is locked to $lockedName, but program does not match (${lockedFaculty.program} vs ${subject.program}).';
            } else {
              final lockedId = lockedFaculty.id!;
              final lockedCurrentLoad = facultyAssignments[lockedId] ??
                  existingSchedules
                      .where((s) => s.facultyId == lockedId)
                      .fold<double>(0, (sum, s) => sum + (s.units ?? 0));
              final subjectUnits = subject.units.toDouble();

              if ((lockedCurrentLoad + subjectUnits) >
                  (lockedFaculty.maxLoad ?? 0).toDouble()) {
                details =
                    'Subject ${subject.code} is locked to $lockedName, but assigning it would exceed max load (${lockedCurrentLoad.toStringAsFixed(1)} + ${subjectUnits.toStringAsFixed(1)} > ${(lockedFaculty.maxLoad ?? 0).toDouble().toStringAsFixed(1)}).';
              } else {
                final lockedAvailability = facultyAvailMap[lockedId] ??
                    await FacultyAvailability.db.find(
                      session,
                      where: (t) => t.facultyId.equals(lockedId),
                    );
                final lockedUsage = facultyTimeslotUsage[lockedId] ??
                    <int, int>{
                      for (final s in existingSchedules.where(
                        (s) => s.facultyId == lockedId && s.timeslotId != null,
                      ))
                        s.timeslotId!: 1,
                    };
                final lockedTimeslots = _rankTimeslotsForFaculty(
                  timeslots: validTimeslots,
                  availability: lockedAvailability,
                  timeslotUsage: lockedUsage,
                  requiredHours: requiredHours,
                );

                if (lockedTimeslots.isEmpty) {
                  details =
                      'Subject ${subject.code} is locked to $lockedName, but no timeslot fits preferred availability and required hours.';
                } else {
                  details =
                      'Subject ${subject.code} is locked to $lockedName, but no room/timeslot combination is conflict-free for section ${section.sectionCode}.';
                }
              }
            }
          }

          conflicts.add(
            ScheduleConflict(
              type: 'generation_failed',
              message:
                  'Could not assign ${subject.name} (${subject.code}) - Section ${section.sectionCode}',
              details: details,
            ),
          );
        }
      }
    }

    if (generatedSchedules.isNotEmpty) {
      for (final schedule in generatedSchedules) {
        await Schedule.db.insertRow(session, schedule);
      }
    }

    return GenerateScheduleResponse(
      success: conflicts.isEmpty,
      schedules: generatedSchedules,
      conflicts: conflicts.isEmpty ? null : conflicts,
      totalAssigned: generatedSchedules.length,
      conflictsDetected: conflicts.length,
      unassignedSubjects: conflicts.length,
      message: conflicts.isEmpty
          ? 'Successfully generated ${generatedSchedules.length} schedule entries'
          : '${generatedSchedules.length} assigned, ${conflicts.length} unassigned',
    );
  }

  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  bool _timeslotFitsAvailability(
    Timeslot timeslot,
    FacultyAvailability availability,
  ) {
    if (timeslot.day != availability.dayOfWeek) return false;
    final tsStart = _parseTimeToMinutes(timeslot.startTime);
    final tsEnd = _parseTimeToMinutes(timeslot.endTime);
    final avStart = _parseTimeToMinutes(availability.startTime);
    final avEnd = _parseTimeToMinutes(availability.endTime);
    return tsStart >= avStart && tsEnd <= avEnd;
  }

  bool _timeslotExactAvailabilityMatch(
    Timeslot timeslot,
    FacultyAvailability availability,
  ) {
    if (timeslot.day != availability.dayOfWeek) return false;
    final tsStart = _parseTimeToMinutes(timeslot.startTime);
    final tsEnd = _parseTimeToMinutes(timeslot.endTime);
    final avStart = _parseTimeToMinutes(availability.startTime);
    final avEnd = _parseTimeToMinutes(availability.endTime);
    return tsStart == avStart && tsEnd == avEnd;
  }

  double _requiredHours(Subject subject) {
    final value = subject.hours ?? subject.units.toDouble();
    return value <= 0 ? subject.units.toDouble() : value;
  }

  double _timeslotHours(Timeslot timeslot) {
    final durationMinutes =
        _parseTimeToMinutes(timeslot.endTime) - _parseTimeToMinutes(timeslot.startTime);
    return durationMinutes / 60.0;
  }

  String _subjectSectionKey(int subjectId, int? sectionId, String sectionCode) {
    if (sectionId != null) return '$subjectId|$sectionId';
    return '$subjectId|${sectionCode.trim().toLowerCase()}';
  }

  int _dayRank(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.mon:
        return 1;
      case DayOfWeek.tue:
        return 2;
      case DayOfWeek.wed:
        return 3;
      case DayOfWeek.thu:
        return 4;
      case DayOfWeek.fri:
        return 5;
      case DayOfWeek.sat:
        return 6;
      case DayOfWeek.sun:
        return 7;
    }
  }

  List<Timeslot> _rankTimeslotsForFaculty({
    required List<Timeslot> timeslots,
    required List<FacultyAvailability> availability,
    required Map<int, int> timeslotUsage,
    required double requiredHours,
  }) {
    final hourFit = timeslots
        .where((t) => _timeslotHours(t) + 1e-6 >= requiredHours)
        .toList();
    if (hourFit.isEmpty) return const [];

    final candidates = availability.isEmpty
        ? hourFit
        : hourFit
            .where((t) => availability.any((a) => _timeslotFitsAvailability(t, a)))
            .toList();
    if (candidates.isEmpty) return const [];

    candidates.sort((a, b) {
      final aExact = availability.any((av) => _timeslotExactAvailabilityMatch(a, av));
      final bExact = availability.any((av) => _timeslotExactAvailabilityMatch(b, av));
      if (aExact != bExact) return aExact ? -1 : 1;

      final aUse = timeslotUsage[a.id!] ?? 0;
      final bUse = timeslotUsage[b.id!] ?? 0;
      if (aUse != bUse) return aUse.compareTo(bUse);

      final dayCompare = _dayRank(a.day).compareTo(_dayRank(b.day));
      if (dayCompare != 0) return dayCompare;
      return _parseTimeToMinutes(a.startTime)
          .compareTo(_parseTimeToMinutes(b.startTime));
    });

    return candidates;
  }

  List<Room> _eligibleRoomsForSubject({
    required List<Room> rooms,
    required Subject subject,
  }) {
    final requiresLabRoom = subject.types.contains(SubjectType.laboratory) ||
        subject.types.contains(SubjectType.blended);

    return rooms.where((room) {
      final normalized = room.name.trim().toUpperCase();
      if (requiresLabRoom) {
        return _labRoomNames.contains(normalized) && room.program == subject.program;
      }
      return normalized == _lectureRoomName;
    }).toList();
  }
}
