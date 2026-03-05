import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service class responsible for validating all scheduling constraints.
/// Ensures the timetable remains conflict-free.
///
/// Conflict Types (standardized codes):
///   room_conflict       – Room double-booked at same timeslot
///   faculty_conflict    – Faculty double-booked at same timeslot
///   section_conflict    – Section double-booked at same timeslot
///   program_mismatch    – Subject program ≠ Room program
///   capacity_exceeded   – Room capacity < subject student count
///   max_load_exceeded   – Faculty total units > maxLoad
///   room_inactive       – Room is marked inactive
///   faculty_unavailable – Timeslot falls outside faculty availability
class ConflictService {
  static const Set<String> _labRoomNames = {'IT LAB', 'EMC LAB'};
  static const String _lectureRoomName = 'ROOM 1';

  String _normalizeRoomName(String name) => name.trim().toUpperCase();

  bool _isLabSubject(Subject subject) {
    return subject.types.contains(SubjectType.laboratory);
  }

  ScheduleConflict? _buildRoomTypeConflict({
    required Schedule schedule,
    required Subject subject,
    required Room room,
  }) {
    final normalizedRoomName = _normalizeRoomName(room.name);
    final isLabSubject = _isLabSubject(subject);

    if (isLabSubject && !_labRoomNames.contains(normalizedRoomName)) {
      return ScheduleConflict(
        type: 'room_type_mismatch',
        message: 'Lab subjects can only be assigned to IT LAB or EMC LAB',
        facultyId: schedule.facultyId,
        roomId: room.id,
        subjectId: schedule.subjectId,
        scheduleId: schedule.id,
        details:
            '${subject.name} requires a laboratory room, but was assigned to ${room.name}',
      );
    }

    if (!isLabSubject && normalizedRoomName != _lectureRoomName) {
      return ScheduleConflict(
        type: 'room_type_mismatch',
        message: 'Non-lab subjects can only be assigned to ROOM 1',
        facultyId: schedule.facultyId,
        roomId: room.id,
        subjectId: schedule.subjectId,
        scheduleId: schedule.id,
        details:
            '${subject.name} is non-laboratory, but was assigned to ${room.name}',
      );
    }

    return null;
  }
  // ─── Individual Conflict Checks ────────────────────────────────────

  /// Check if a room is available at a given timeslot.
  Future<Schedule?> checkRoomAvailability(
    Session session, {
    required int? roomId,
    required int? timeslotId,
    int? excludeScheduleId,
  }) async {
    if (roomId == null || timeslotId == null) return null;

    var conflicts = await Schedule.db.find(
      session,
      where: (t) => t.roomId.equals(roomId) & t.timeslotId.equals(timeslotId),
    );

    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a faculty member is available at a given timeslot.
  Future<Schedule?> checkFacultyAvailability(
    Session session, {
    required int facultyId,
    required int? timeslotId,
    int? excludeScheduleId,
  }) async {
    if (timeslotId == null) return null;

    var conflicts = await Schedule.db.find(
      session,
      where: (t) =>
          t.facultyId.equals(facultyId) & t.timeslotId.equals(timeslotId),
    );

    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a section is available at a given timeslot.
  Future<Schedule?> checkSectionAvailability(
    Session session, {
    required String section,
    required int? timeslotId,
    int? excludeScheduleId,
  }) async {
    if (timeslotId == null || section.isEmpty) return null;

    var conflicts = await Schedule.db.find(
      session,
      where: (t) => t.section.equals(section) & t.timeslotId.equals(timeslotId),
    );

    if (excludeScheduleId != null) {
      conflicts = conflicts.where((s) => s.id != excludeScheduleId).toList();
    }

    return conflicts.isNotEmpty ? conflicts.first : null;
  }

  /// Check if a faculty member has exceeded their maximum teaching load.
  Future<bool> checkFacultyMaxLoad(
    Session session, {
    required int facultyId,
    double newUnits = 0,
    int? excludeScheduleId,
  }) async {
    var faculty = await Faculty.db.findById(session, facultyId);
    if (faculty == null) {
      session.log(
        'Warning: Faculty not found for ID $facultyId during max load check.',
        level: LogLevel.warning,
      );
      return true;
    }

    var schedules = await Schedule.db.find(
      session,
      where: (t) => t.facultyId.equals(facultyId),
    );

    if (excludeScheduleId != null) {
      schedules = schedules.where((s) => s.id != excludeScheduleId).toList();
    }

    // Resolve subject units for rows where schedule.units is null.
    var subjectUnitsById = <int, double>{};
    var subjectIds = schedules.map((s) => s.subjectId).toSet().toList();
    if (subjectIds.isNotEmpty) {
      var subjects = await Subject.db.find(
        session,
        where: (t) => t.id.inSet(subjectIds.toSet()),
      );
      for (var subject in subjects) {
        if (subject.id != null) {
          subjectUnitsById[subject.id!] = subject.units.toDouble();
        }
      }
    }

    double currentLoad = 0;
    for (var s in schedules) {
      currentLoad += s.units ?? (subjectUnitsById[s.subjectId] ?? 0);
    }

    return (currentLoad + newUnits) <= (faculty.maxLoad ?? 0);
  }

  /// Check if a faculty member is available on the day/time of a given timeslot
  /// based on their FacultyAvailability preferences.
  /// Returns true if available (or no preferences set), false if outside preferred times.
  Future<bool> checkFacultyDayTimeAvailability(
    Session session, {
    required int facultyId,
    required int timeslotId,
  }) async {
    // Get the timeslot details
    var timeslot = await Timeslot.db.findById(session, timeslotId);
    if (timeslot == null) return true; // Can't validate without timeslot

    // Get faculty availability preferences
    var availabilities = await FacultyAvailability.db.find(
      session,
      where: (t) => t.facultyId.equals(facultyId),
    );

    // If no preferences set, faculty is available anytime
    if (availabilities.isEmpty) return true;

    // Parse timeslot day and times
    final timeslotDay = timeslot.day;
    final tsStartMinutes = _parseTimeToMinutes(timeslot.startTime);
    final tsEndMinutes = _parseTimeToMinutes(timeslot.endTime);

    // Check if any availability window covers this timeslot
    for (var avail in availabilities) {
      if (avail.dayOfWeek == timeslotDay) {
        final availStart = _parseTimeToMinutes(avail.startTime);
        final availEnd = _parseTimeToMinutes(avail.endTime);

        // Timeslot must fit within the availability window
        if (tsStartMinutes >= availStart && tsEndMinutes <= availEnd) {
          return true;
        }
      }
    }

    return false; // No matching availability window
  }

  /// Helper: parse "HH:MM" or "H:MM" to minutes since midnight.
  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }

  // ─── Full Schedule Validation ──────────────────────────────────────

  /// Validate a schedule entry against ALL conflict rules.
  /// Returns a list of conflicts (empty if valid).
  Future<List<ScheduleConflict>> validateSchedule(
    Session session,
    Schedule schedule, {
    int? excludeScheduleId,
  }) async {
    var conflicts = <ScheduleConflict>[];
    final subject = await Subject.db.findById(session, schedule.subjectId);

    // 1. Room Conflict
    var roomId = schedule.roomId;
    var timeslotId = schedule.timeslotId;

    if (roomId != null && timeslotId != null) {
      var roomConflict = await checkRoomAvailability(
        session,
        roomId: roomId,
        timeslotId: timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (roomConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'room_conflict',
            message: 'Room is already booked for this timeslot',
            conflictingScheduleId: roomConflict.id,
            facultyId: schedule.facultyId,
            roomId: roomId,
            subjectId: schedule.subjectId,
            details:
                'Room ID $roomId is already assigned to schedule ID ${roomConflict.id}',
          ),
        );
      }

      // Fetch Room for property checks (subject already loaded)
      var room = await Room.db.findById(session, roomId);

      if (subject != null && room != null) {
        // 2. Program Mismatch
        final normalizedRoomName = _normalizeRoomName(room.name);
        if (subject.program != room.program &&
            normalizedRoomName != _lectureRoomName) {
          conflicts.add(
            ScheduleConflict(
              type: 'program_mismatch',
              message: 'Subject program does not match Room program',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details:
                  '${subject.name} (${subject.program.name.toUpperCase()}) cannot use ${room.name} (${room.program.name.toUpperCase()})',
            ),
          );
        }

        // 3. Capacity Exceeded
        if (room.capacity < subject.studentsCount) {
          conflicts.add(
            ScheduleConflict(
              type: 'capacity_exceeded',
              message: 'Room capacity is smaller than student count',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details:
                  '${room.name} capacity: ${room.capacity}, ${subject.name} students: ${subject.studentsCount}',
            ),
          );
        }

        // 4. Room Inactive
        if (!room.isActive) {
          conflicts.add(
            ScheduleConflict(
              type: 'room_inactive',
              message: 'The selected room is currently inactive',
              facultyId: schedule.facultyId,
              roomId: roomId,
              subjectId: schedule.subjectId,
              details: '${room.name} must be active for assignment',
            ),
          );
        }

        // 5. Lab/Lecture Room Rule
        final roomTypeConflict = _buildRoomTypeConflict(
          schedule: schedule,
          subject: subject,
          room: room,
        );
        if (roomTypeConflict != null) {
          conflicts.add(roomTypeConflict);
        }
      }
    }

    // 6. Faculty Time Conflict
    if (schedule.timeslotId != null) {
      var facultyConflict = await checkFacultyAvailability(
        session,
        facultyId: schedule.facultyId,
        timeslotId: schedule.timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (facultyConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'faculty_conflict',
            message: 'Faculty is already assigned at this timeslot',
            conflictingScheduleId: facultyConflict.id,
            facultyId: schedule.facultyId,
            roomId: schedule.roomId,
            subjectId: schedule.subjectId,
            details:
                'Faculty ID ${schedule.facultyId} already teaches at schedule ID ${facultyConflict.id}',
          ),
        );
      }
    }

    // 6. Section Conflict
    if (schedule.timeslotId != null && schedule.section.isNotEmpty) {
      var sectionConflict = await checkSectionAvailability(
        session,
        section: schedule.section,
        timeslotId: schedule.timeslotId,
        excludeScheduleId: excludeScheduleId,
      );

      if (sectionConflict != null) {
        conflicts.add(
          ScheduleConflict(
            type: 'section_conflict',
            message: 'Section is already in another class at this timeslot',
            conflictingScheduleId: sectionConflict.id,
            facultyId: schedule.facultyId,
            roomId: schedule.roomId,
            subjectId: schedule.subjectId,
            details:
                'Section ${schedule.section} is already in schedule ID ${sectionConflict.id}',
          ),
        );
      }
    }

    // 7. Faculty Max Load
    var newUnits = schedule.units ?? 0;
    if (newUnits == 0) {
      var subject = await Subject.db.findById(session, schedule.subjectId);
      newUnits = subject?.units.toDouble() ?? 0;
    }

    var canTakeMore = await checkFacultyMaxLoad(
      session,
      facultyId: schedule.facultyId,
      newUnits: newUnits,
      excludeScheduleId: excludeScheduleId,
    );

    if (!canTakeMore) {
      var faculty = await Faculty.db.findById(session, schedule.facultyId);
      conflicts.add(
        ScheduleConflict(
          type: 'max_load_exceeded',
          message: 'Faculty has reached maximum teaching load',
          facultyId: schedule.facultyId,
          subjectId: schedule.subjectId,
          details:
              '${faculty?.name ?? 'Faculty ID ${schedule.facultyId}'} has reached max load of ${faculty?.maxLoad ?? 0} units',
        ),
      );
    }

    // 8. Faculty Day/Time Availability Preference
    if (schedule.timeslotId != null) {
      var isWithinPreference = await checkFacultyDayTimeAvailability(
        session,
        facultyId: schedule.facultyId,
        timeslotId: schedule.timeslotId!,
      );

      if (!isWithinPreference) {
        conflicts.add(
          ScheduleConflict(
            type: 'faculty_unavailable',
            message: 'Timeslot is outside faculty preferred availability',
            facultyId: schedule.facultyId,
            subjectId: schedule.subjectId,
            details:
                'Faculty ID ${schedule.facultyId} has no availability window covering this timeslot',
          ),
        );
      }

      // Continuous-block validation: timeslot duration must cover subject total hours (lecture + lab combined)
      if (subject != null) {
        final timeslot = await Timeslot.db.findById(
          session,
          schedule.timeslotId!,
        );
        final requiredHours =
            subject.hours ?? subject.units.toDouble() ?? schedule.hours ?? 0;
        if (timeslot != null && requiredHours > 0) {
          final tsMinutes =
              _parseTimeToMinutes(timeslot.endTime) -
              _parseTimeToMinutes(timeslot.startTime);
          final tsHours = tsMinutes / 60.0;
          if (tsHours + 1e-6 < requiredHours) {
            conflicts.add(
              ScheduleConflict(
                type: 'insufficient_block',
                message:
                    'Timeslot ${timeslot.day.name} ${timeslot.startTime}-${timeslot.endTime} is too short for ${subject.name}',
                scheduleId: schedule.id,
                facultyId: schedule.facultyId,
                subjectId: schedule.subjectId,
                details:
                    'Required continuous hours: ${requiredHours.toStringAsFixed(1)}, available: ${tsHours.toStringAsFixed(1)}',
              ),
            );
          }
        }
      }
    }

    return conflicts;
  }

  // ─── Full System Conflict Scan ─────────────────────────────────────

  /// Scans the ENTIRE schedule system for all conflict types.
  /// This is a comprehensive check that detects:
  ///   - Room conflicts (same room, same timeslot)
  ///   - Faculty conflicts (same faculty, same timeslot)
  ///   - Section conflicts (same section, same timeslot)
  ///   - Program mismatches (subject program ≠ room program)
  ///   - Capacity exceeded (room capacity < student count)
  ///   - Faculty max load exceeded
  Future<List<ScheduleConflict>> getAllConflicts(Session session) async {
    var allSchedules = await Schedule.db.find(session);
    var allSubjects = await Subject.db.find(session);
    var allRooms = await Room.db.find(session);
    var allFaculty = await Faculty.db.find(session);
    var allTimeslots = await Timeslot.db.find(session);

    List<ScheduleConflict> conflicts = [];

    // Build lookup maps
    var subjectMap = <int, Subject>{};
    for (var s in allSubjects) {
      if (s.id != null) subjectMap[s.id!] = s;
    }
    var roomMap = <int, Room>{};
    for (var r in allRooms) {
      if (r.id != null) roomMap[r.id!] = r;
    }
    var facultyMap = <int, Faculty>{};
    for (var f in allFaculty) {
      if (f.id != null) facultyMap[f.id!] = f;
    }
    var timeslotMap = <int, Timeslot>{};
    for (var t in allTimeslots) {
      if (t.id != null) timeslotMap[t.id!] = t;
    }

    // Group schedules by timeslot for overlap checks
    var schedulesByTime = <int, List<Schedule>>{};
    for (var s in allSchedules) {
      var tid = s.timeslotId;
      if (tid != null) {
        schedulesByTime.putIfAbsent(tid, () => []).add(s);
      }
    }

    // ── 1. Room Conflicts (same room, same timeslot) ──
    for (var timeslotId in schedulesByTime.keys) {
      var concurrent = schedulesByTime[timeslotId]!;
      var byRoom = <int, List<Schedule>>{};
      for (var s in concurrent) {
        var rid = s.roomId;
        if (rid != null) {
          byRoom.putIfAbsent(rid, () => []).add(s);
        }
      }
      byRoom.forEach((roomId, roomSchedules) {
        if (roomSchedules.length > 1) {
          var room = roomMap[roomId];
          final ts = timeslotMap[timeslotId];
          final slotLabel = ts != null
              ? '${ts.day.name} ${ts.startTime}-${ts.endTime}'
              : 'timeslot $timeslotId';
          final occupants = roomSchedules
              .map((s) {
                final subj =
                    subjectMap[s.subjectId]?.code ?? 'Subject ${s.subjectId}';
                final fac =
                    facultyMap[s.facultyId]?.name ?? 'Faculty ${s.facultyId}';
                return '$subj / $fac / ${s.section}';
              })
              .join('; ');
          conflicts.add(
            ScheduleConflict(
              type: 'room_conflict',
              message:
                  '${room?.name ?? 'Room $roomId'} already booked at $slotLabel',
              roomId: roomId,
              details:
                  'Conflicts with: $occupants (Schedule IDs: ${roomSchedules.map((s) => s.id).join(', ')})',
            ),
          );
        }
      });

      // ── 2. Faculty Conflicts (same faculty, same timeslot) ──
      var byFaculty = <int, List<Schedule>>{};
      for (var s in concurrent) {
        byFaculty.putIfAbsent(s.facultyId, () => []).add(s);
      }
      byFaculty.forEach((facultyId, facSchedules) {
        if (facSchedules.length > 1) {
          var faculty = facultyMap[facultyId];
          final ts = timeslotMap[timeslotId];
          final slotLabel = ts != null
              ? '${ts.day.name} ${ts.startTime}-${ts.endTime}'
              : 'timeslot $timeslotId';
          final subjects = facSchedules
              .map(
                (s) =>
                    subjectMap[s.subjectId]?.code ?? 'Subject ${s.subjectId}',
              )
              .join(', ');
          conflicts.add(
            ScheduleConflict(
              type: 'faculty_conflict',
              message:
                  '${faculty?.name ?? 'Faculty $facultyId'} has overlapping classes at $slotLabel',
              facultyId: facultyId,
              details:
                  'Subjects: $subjects (Schedule IDs: ${facSchedules.map((s) => s.id).join(', ')})',
            ),
          );
        }
      });

      // ── 3. Section Conflicts (same section, same timeslot) ──
      var bySection = <String, List<Schedule>>{};
      for (var s in concurrent) {
        if (s.section.isNotEmpty) {
          bySection.putIfAbsent(s.section, () => []).add(s);
        }
      }
      bySection.forEach((section, secSchedules) {
        if (secSchedules.length > 1) {
          final ts = timeslotMap[timeslotId];
          final slotLabel = ts != null
              ? '${ts.day.name} ${ts.startTime}-${ts.endTime}'
              : 'timeslot $timeslotId';
          final subjects = secSchedules
              .map(
                (s) =>
                    subjectMap[s.subjectId]?.code ?? 'Subject ${s.subjectId}',
              )
              .join(', ');
          conflicts.add(
            ScheduleConflict(
              type: 'section_conflict',
              message: 'Section $section double-booked at $slotLabel',
              details:
                  'Subjects: $subjects (Schedule IDs: ${secSchedules.map((s) => s.id).join(', ')})',
            ),
          );
        }
      });
    }

    // ── 4. Program Mismatch (subject.program ≠ room.program) ──
    for (var s in allSchedules) {
      var subject = subjectMap[s.subjectId];
      var room = s.roomId != null ? roomMap[s.roomId!] : null;
      if (subject != null && room != null) {
        final normalizedRoomName = _normalizeRoomName(room.name);
        if (subject.program != room.program &&
            normalizedRoomName != _lectureRoomName) {
          conflicts.add(
            ScheduleConflict(
              type: 'program_mismatch',
              message:
                  '${subject.name} (${subject.program.name.toUpperCase()}) assigned to ${room.name} (${room.program.name.toUpperCase()})',
              scheduleId: s.id,
              subjectId: s.subjectId,
              roomId: s.roomId,
              facultyId: s.facultyId,
              details: 'Subject and Room programs do not match',
            ),
          );
        }

        // ── 5. Capacity Exceeded ──
        if (room.capacity < subject.studentsCount) {
          conflicts.add(
            ScheduleConflict(
              type: 'capacity_exceeded',
              message:
                  '${room.name} (capacity ${room.capacity}) too small for ${subject.name} (${subject.studentsCount} students)',
              scheduleId: s.id,
              subjectId: s.subjectId,
              roomId: s.roomId,
              details:
                  'Room capacity: ${room.capacity}, Required: ${subject.studentsCount}',
            ),
          );
        }

        final roomTypeConflict = _buildRoomTypeConflict(
          schedule: s,
          subject: subject,
          room: room,
        );
        if (roomTypeConflict != null) {
          conflicts.add(roomTypeConflict);
        }
      }
    }

    // ── 6. Faculty Max Load Exceeded ──
    var facultyUnits = <int, double>{};
    for (var s in allSchedules) {
      var subject = subjectMap[s.subjectId];
      var units = subject?.units.toDouble() ?? (s.units ?? 0);
      facultyUnits[s.facultyId] = (facultyUnits[s.facultyId] ?? 0) + units;
    }

    facultyUnits.forEach((facultyId, totalUnits) {
      var faculty = facultyMap[facultyId];
      if (faculty != null && totalUnits > (faculty.maxLoad ?? 0)) {
        conflicts.add(
          ScheduleConflict(
            type: 'max_load_exceeded',
            message:
                '${faculty.name} has ${totalUnits.toStringAsFixed(1)} units (max: ${faculty.maxLoad})',
            facultyId: facultyId,
            details:
                'Total assigned: ${totalUnits.toStringAsFixed(1)}, Max load: ${faculty.maxLoad}',
          ),
        );
      }
    });

    // ── 7. Room Inactive (room is inactive but used in a schedule) ──
    for (var s in allSchedules) {
      if (s.roomId != null) {
        var room = roomMap[s.roomId!];
        if (room != null && !room.isActive) {
          conflicts.add(
            ScheduleConflict(
              type: 'room_inactive',
              message: '${room.name} is inactive but assigned to a schedule',
              scheduleId: s.id,
              roomId: s.roomId,
              facultyId: s.facultyId,
              subjectId: s.subjectId,
              details:
                  'Room "${room.name}" must be set to active before being used in scheduling',
            ),
          );
        }
      }
    }

    // ── 8. Faculty Unavailable (timeslot outside faculty preferred hours) ──
    var allAvailabilities = await FacultyAvailability.db.find(session);

    var availByFaculty = <int, List<FacultyAvailability>>{};
    for (var a in allAvailabilities) {
      availByFaculty.putIfAbsent(a.facultyId, () => []).add(a);
    }

    for (var s in allSchedules) {
      if (s.timeslotId == null) continue;
      final avails = availByFaculty[s.facultyId];
      if (avails == null || avails.isEmpty) continue; // no prefs = always ok

      final ts = timeslotMap[s.timeslotId!];
      if (ts == null) continue;

      final tsStart = _parseTimeToMinutes(ts.startTime);
      final tsEnd = _parseTimeToMinutes(ts.endTime);
      final tsDay = ts.day;

      final covered = avails.any((a) {
        if (a.dayOfWeek != tsDay) return false;
        final aStart = _parseTimeToMinutes(a.startTime);
        final aEnd = _parseTimeToMinutes(a.endTime);
        return tsStart >= aStart && tsEnd <= aEnd;
      });

      if (!covered) {
        final faculty = facultyMap[s.facultyId];
        conflicts.add(
          ScheduleConflict(
            type: 'faculty_unavailable',
            message:
                '${faculty?.name ?? 'Faculty ${s.facultyId}'} scheduled outside preferred hours',
            scheduleId: s.id,
            facultyId: s.facultyId,
            subjectId: s.subjectId,
            details:
                'Timeslot ${ts.startTime}–${ts.endTime} on ${ts.day.name} is outside faculty availability',
          ),
        );
      }
    }

    // â”€â”€ 9. Continuous block check (timeslot duration vs subject hours) â”€â”€
    for (var s in allSchedules) {
      if (s.timeslotId == null) continue;
      final subject = subjectMap[s.subjectId];
      if (subject == null) continue;
      final requiredHours = subject.hours ?? subject.units.toDouble();
      if (requiredHours <= 0) continue;
      final ts = timeslotMap[s.timeslotId!];
      if (ts == null) continue;
      final tsMinutes =
          _parseTimeToMinutes(ts.endTime) - _parseTimeToMinutes(ts.startTime);
      final tsHours = tsMinutes / 60.0;
      if (tsHours + 1e-6 < requiredHours) {
        final faculty = facultyMap[s.facultyId];
        conflicts.add(
          ScheduleConflict(
            type: 'insufficient_block',
            message:
                '${subject.name} requires ${requiredHours.toStringAsFixed(1)}h but timeslot provides ${tsHours.toStringAsFixed(1)}h (${ts.day.name} ${ts.startTime}-${ts.endTime})',
            scheduleId: s.id,
            facultyId: s.facultyId,
            subjectId: s.subjectId,
            roomId: s.roomId,
            details:
                'Continuous block required. Faculty: ${faculty?.name ?? s.facultyId}, Section: ${s.section}, Room: ${roomMap[s.roomId ?? -1]?.name ?? 'N/A'}',
          ),
        );
      }
    }

    return conflicts;
  }
}
