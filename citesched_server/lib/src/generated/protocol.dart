/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i4;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i5;
import 'dashboard_stats.dart' as _i6;
import 'day_of_week.dart' as _i7;
import 'distribution_data.dart' as _i8;
import 'employment_status.dart' as _i9;
import 'faculty.dart' as _i10;
import 'faculty_availability.dart' as _i11;
import 'faculty_load_data.dart' as _i12;
import 'faculty_shift_preference.dart' as _i13;
import 'generate_schedule_request.dart' as _i14;
import 'generate_schedule_response.dart' as _i15;
import 'greetings/greeting.dart' as _i16;
import 'nlp_intent.dart' as _i17;
import 'nlp_response.dart' as _i18;
import 'program.dart' as _i19;
import 'reports/conflict_summary_report.dart' as _i20;
import 'reports/faculty_load_report.dart' as _i21;
import 'reports/room_utilization_report.dart' as _i22;
import 'reports/schedule_overview_report.dart' as _i23;
import 'room.dart' as _i24;
import 'room_type.dart' as _i25;
import 'schedule.dart' as _i26;
import 'schedule_conflict.dart' as _i27;
import 'schedule_info.dart' as _i28;
import 'section.dart' as _i29;
import 'student.dart' as _i30;
import 'subject.dart' as _i31;
import 'subject_type.dart' as _i32;
import 'timeslot.dart' as _i33;
import 'timetable_filter_request.dart' as _i34;
import 'timetable_summary.dart' as _i35;
import 'user_role.dart' as _i36;
import 'package:citesched_server/src/generated/user_role.dart' as _i37;
import 'package:citesched_server/src/generated/faculty.dart' as _i38;
import 'package:citesched_server/src/generated/student.dart' as _i39;
import 'package:citesched_server/src/generated/room.dart' as _i40;
import 'package:citesched_server/src/generated/subject.dart' as _i41;
import 'package:citesched_server/src/generated/timeslot.dart' as _i42;
import 'package:citesched_server/src/generated/schedule.dart' as _i43;
import 'package:citesched_server/src/generated/schedule_conflict.dart' as _i44;
import 'package:citesched_server/src/generated/reports/faculty_load_report.dart'
    as _i45;
import 'package:citesched_server/src/generated/reports/room_utilization_report.dart'
    as _i46;
import 'package:citesched_server/src/generated/section.dart' as _i47;
import 'package:citesched_server/src/generated/faculty_availability.dart'
    as _i48;
import 'package:citesched_server/src/generated/schedule_info.dart' as _i49;
export 'dashboard_stats.dart';
export 'day_of_week.dart';
export 'distribution_data.dart';
export 'employment_status.dart';
export 'faculty.dart';
export 'faculty_availability.dart';
export 'faculty_load_data.dart';
export 'faculty_shift_preference.dart';
export 'generate_schedule_request.dart';
export 'generate_schedule_response.dart';
export 'greetings/greeting.dart';
export 'nlp_intent.dart';
export 'nlp_response.dart';
export 'program.dart';
export 'reports/conflict_summary_report.dart';
export 'reports/faculty_load_report.dart';
export 'reports/room_utilization_report.dart';
export 'reports/schedule_overview_report.dart';
export 'room.dart';
export 'room_type.dart';
export 'schedule.dart';
export 'schedule_conflict.dart';
export 'schedule_info.dart';
export 'section.dart';
export 'student.dart';
export 'subject.dart';
export 'subject_type.dart';
export 'timeslot.dart';
export 'timetable_filter_request.dart';
export 'timetable_summary.dart';
export 'user_role.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'faculty',
      dartName: 'Faculty',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'faculty_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'maxLoad',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'employmentStatus',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:EmploymentStatus?',
        ),
        _i2.ColumnDefinition(
          name: 'shiftPreference',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:FacultyShiftPreference?',
        ),
        _i2.ColumnDefinition(
          name: 'preferredHours',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'facultyId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'userInfoId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'program',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:Program?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'currentLoad',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'faculty_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'faculty_email_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'faculty_id_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'facultyId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'faculty_availability',
      dartName: 'FacultyAvailability',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'faculty_availability_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'facultyId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'dayOfWeek',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DayOfWeek',
        ),
        _i2.ColumnDefinition(
          name: 'startTime',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'endTime',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'isPreferred',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'faculty_availability_fk_0',
          columns: ['facultyId'],
          referenceTable: 'faculty',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'faculty_availability_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'room',
      dartName: 'Room',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'room_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'capacity',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:RoomType',
        ),
        _i2.ColumnDefinition(
          name: 'program',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Program',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'room_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'room_name_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'schedule',
      dartName: 'Schedule',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'schedule_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'subjectId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'facultyId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'roomId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'timeslotId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'section',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sectionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'loadTypes',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:SubjectType>?',
        ),
        _i2.ColumnDefinition(
          name: 'units',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'hours',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'schedule_fk_0',
          columns: ['subjectId'],
          referenceTable: 'subject',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'schedule_fk_1',
          columns: ['facultyId'],
          referenceTable: 'faculty',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'schedule_fk_2',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'schedule_fk_3',
          columns: ['timeslotId'],
          referenceTable: 'timeslot',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'schedule_fk_4',
          columns: ['sectionId'],
          referenceTable: 'section',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'schedule_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'section',
      dartName: 'Section',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'section_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'program',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Program',
        ),
        _i2.ColumnDefinition(
          name: 'yearLevel',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'sectionCode',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'academicYear',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'semester',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'section_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'section_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'program',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'yearLevel',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sectionCode',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'academicYear',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'semester',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'student',
      dartName: 'Student',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'student_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'studentNumber',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'course',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'yearLevel',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'section',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sectionId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'userInfoId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'student_fk_0',
          columns: ['sectionId'],
          referenceTable: 'section',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'student_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'student_email_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'student_number_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'studentNumber',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'subject',
      dartName: 'Subject',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'subject_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'code',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'units',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'hours',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _i2.ColumnDefinition(
          name: 'yearLevel',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'term',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'facultyId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'types',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:SubjectType>',
        ),
        _i2.ColumnDefinition(
          name: 'program',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:Program',
        ),
        _i2.ColumnDefinition(
          name: 'studentsCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'subject_fk_0',
          columns: ['facultyId'],
          referenceTable: 'faculty',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'subject_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'timeslot',
      dartName: 'Timeslot',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'timeslot_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'day',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DayOfWeek',
        ),
        _i2.ColumnDefinition(
          name: 'startTime',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'endTime',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'timeslot_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user_role',
      dartName: 'UserRole',
      schema: 'public',
      module: 'citesched',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'user_role_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_role_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_role_user_id_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i5.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6.DashboardStats) {
      return _i6.DashboardStats.fromJson(data) as T;
    }
    if (t == _i7.DayOfWeek) {
      return _i7.DayOfWeek.fromJson(data) as T;
    }
    if (t == _i8.DistributionData) {
      return _i8.DistributionData.fromJson(data) as T;
    }
    if (t == _i9.EmploymentStatus) {
      return _i9.EmploymentStatus.fromJson(data) as T;
    }
    if (t == _i10.Faculty) {
      return _i10.Faculty.fromJson(data) as T;
    }
    if (t == _i11.FacultyAvailability) {
      return _i11.FacultyAvailability.fromJson(data) as T;
    }
    if (t == _i12.FacultyLoadData) {
      return _i12.FacultyLoadData.fromJson(data) as T;
    }
    if (t == _i13.FacultyShiftPreference) {
      return _i13.FacultyShiftPreference.fromJson(data) as T;
    }
    if (t == _i14.GenerateScheduleRequest) {
      return _i14.GenerateScheduleRequest.fromJson(data) as T;
    }
    if (t == _i15.GenerateScheduleResponse) {
      return _i15.GenerateScheduleResponse.fromJson(data) as T;
    }
    if (t == _i16.Greeting) {
      return _i16.Greeting.fromJson(data) as T;
    }
    if (t == _i17.NLPIntent) {
      return _i17.NLPIntent.fromJson(data) as T;
    }
    if (t == _i18.NLPResponse) {
      return _i18.NLPResponse.fromJson(data) as T;
    }
    if (t == _i19.Program) {
      return _i19.Program.fromJson(data) as T;
    }
    if (t == _i20.ConflictSummaryReport) {
      return _i20.ConflictSummaryReport.fromJson(data) as T;
    }
    if (t == _i21.FacultyLoadReport) {
      return _i21.FacultyLoadReport.fromJson(data) as T;
    }
    if (t == _i22.RoomUtilizationReport) {
      return _i22.RoomUtilizationReport.fromJson(data) as T;
    }
    if (t == _i23.ScheduleOverviewReport) {
      return _i23.ScheduleOverviewReport.fromJson(data) as T;
    }
    if (t == _i24.Room) {
      return _i24.Room.fromJson(data) as T;
    }
    if (t == _i25.RoomType) {
      return _i25.RoomType.fromJson(data) as T;
    }
    if (t == _i26.Schedule) {
      return _i26.Schedule.fromJson(data) as T;
    }
    if (t == _i27.ScheduleConflict) {
      return _i27.ScheduleConflict.fromJson(data) as T;
    }
    if (t == _i28.ScheduleInfo) {
      return _i28.ScheduleInfo.fromJson(data) as T;
    }
    if (t == _i29.Section) {
      return _i29.Section.fromJson(data) as T;
    }
    if (t == _i30.Student) {
      return _i30.Student.fromJson(data) as T;
    }
    if (t == _i31.Subject) {
      return _i31.Subject.fromJson(data) as T;
    }
    if (t == _i32.SubjectType) {
      return _i32.SubjectType.fromJson(data) as T;
    }
    if (t == _i33.Timeslot) {
      return _i33.Timeslot.fromJson(data) as T;
    }
    if (t == _i34.TimetableFilterRequest) {
      return _i34.TimetableFilterRequest.fromJson(data) as T;
    }
    if (t == _i35.TimetableSummary) {
      return _i35.TimetableSummary.fromJson(data) as T;
    }
    if (t == _i36.UserRole) {
      return _i36.UserRole.fromJson(data) as T;
    }
    if (t == _i1.getType<_i6.DashboardStats?>()) {
      return (data != null ? _i6.DashboardStats.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DayOfWeek?>()) {
      return (data != null ? _i7.DayOfWeek.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DistributionData?>()) {
      return (data != null ? _i8.DistributionData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.EmploymentStatus?>()) {
      return (data != null ? _i9.EmploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Faculty?>()) {
      return (data != null ? _i10.Faculty.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.FacultyAvailability?>()) {
      return (data != null ? _i11.FacultyAvailability.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.FacultyLoadData?>()) {
      return (data != null ? _i12.FacultyLoadData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.FacultyShiftPreference?>()) {
      return (data != null ? _i13.FacultyShiftPreference.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.GenerateScheduleRequest?>()) {
      return (data != null ? _i14.GenerateScheduleRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.GenerateScheduleResponse?>()) {
      return (data != null
              ? _i15.GenerateScheduleResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.Greeting?>()) {
      return (data != null ? _i16.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.NLPIntent?>()) {
      return (data != null ? _i17.NLPIntent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.NLPResponse?>()) {
      return (data != null ? _i18.NLPResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.Program?>()) {
      return (data != null ? _i19.Program.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ConflictSummaryReport?>()) {
      return (data != null ? _i20.ConflictSummaryReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.FacultyLoadReport?>()) {
      return (data != null ? _i21.FacultyLoadReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.RoomUtilizationReport?>()) {
      return (data != null ? _i22.RoomUtilizationReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.ScheduleOverviewReport?>()) {
      return (data != null ? _i23.ScheduleOverviewReport.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.Room?>()) {
      return (data != null ? _i24.Room.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.RoomType?>()) {
      return (data != null ? _i25.RoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.Schedule?>()) {
      return (data != null ? _i26.Schedule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.ScheduleConflict?>()) {
      return (data != null ? _i27.ScheduleConflict.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.ScheduleInfo?>()) {
      return (data != null ? _i28.ScheduleInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.Section?>()) {
      return (data != null ? _i29.Section.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.Student?>()) {
      return (data != null ? _i30.Student.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.Subject?>()) {
      return (data != null ? _i31.Subject.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.SubjectType?>()) {
      return (data != null ? _i32.SubjectType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.Timeslot?>()) {
      return (data != null ? _i33.Timeslot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.TimetableFilterRequest?>()) {
      return (data != null ? _i34.TimetableFilterRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.TimetableSummary?>()) {
      return (data != null ? _i35.TimetableSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.UserRole?>()) {
      return (data != null ? _i36.UserRole.fromJson(data) : null) as T;
    }
    if (t == List<_i12.FacultyLoadData>) {
      return (data as List)
              .map((e) => deserialize<_i12.FacultyLoadData>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.ScheduleConflict>) {
      return (data as List)
              .map((e) => deserialize<_i27.ScheduleConflict>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.DistributionData>) {
      return (data as List)
              .map((e) => deserialize<_i8.DistributionData>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i26.Schedule>) {
      return (data as List).map((e) => deserialize<_i26.Schedule>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i26.Schedule>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i26.Schedule>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == _i1.getType<List<_i27.ScheduleConflict>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i27.ScheduleConflict>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_i32.SubjectType>) {
      return (data as List)
              .map((e) => deserialize<_i32.SubjectType>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i32.SubjectType>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i32.SubjectType>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i37.UserRole>) {
      return (data as List).map((e) => deserialize<_i37.UserRole>(e)).toList()
          as T;
    }
    if (t == List<_i38.Faculty>) {
      return (data as List).map((e) => deserialize<_i38.Faculty>(e)).toList()
          as T;
    }
    if (t == List<_i39.Student>) {
      return (data as List).map((e) => deserialize<_i39.Student>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i40.Room>) {
      return (data as List).map((e) => deserialize<_i40.Room>(e)).toList() as T;
    }
    if (t == List<_i41.Subject>) {
      return (data as List).map((e) => deserialize<_i41.Subject>(e)).toList()
          as T;
    }
    if (t == List<_i42.Timeslot>) {
      return (data as List).map((e) => deserialize<_i42.Timeslot>(e)).toList()
          as T;
    }
    if (t == List<_i43.Schedule>) {
      return (data as List).map((e) => deserialize<_i43.Schedule>(e)).toList()
          as T;
    }
    if (t == List<_i44.ScheduleConflict>) {
      return (data as List)
              .map((e) => deserialize<_i44.ScheduleConflict>(e))
              .toList()
          as T;
    }
    if (t == List<_i45.FacultyLoadReport>) {
      return (data as List)
              .map((e) => deserialize<_i45.FacultyLoadReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i46.RoomUtilizationReport>) {
      return (data as List)
              .map((e) => deserialize<_i46.RoomUtilizationReport>(e))
              .toList()
          as T;
    }
    if (t == List<_i47.Section>) {
      return (data as List).map((e) => deserialize<_i47.Section>(e)).toList()
          as T;
    }
    if (t == List<_i48.FacultyAvailability>) {
      return (data as List)
              .map((e) => deserialize<_i48.FacultyAvailability>(e))
              .toList()
          as T;
    }
    if (t == List<_i49.ScheduleInfo>) {
      return (data as List)
              .map((e) => deserialize<_i49.ScheduleInfo>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i5.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6.DashboardStats => 'DashboardStats',
      _i7.DayOfWeek => 'DayOfWeek',
      _i8.DistributionData => 'DistributionData',
      _i9.EmploymentStatus => 'EmploymentStatus',
      _i10.Faculty => 'Faculty',
      _i11.FacultyAvailability => 'FacultyAvailability',
      _i12.FacultyLoadData => 'FacultyLoadData',
      _i13.FacultyShiftPreference => 'FacultyShiftPreference',
      _i14.GenerateScheduleRequest => 'GenerateScheduleRequest',
      _i15.GenerateScheduleResponse => 'GenerateScheduleResponse',
      _i16.Greeting => 'Greeting',
      _i17.NLPIntent => 'NLPIntent',
      _i18.NLPResponse => 'NLPResponse',
      _i19.Program => 'Program',
      _i20.ConflictSummaryReport => 'ConflictSummaryReport',
      _i21.FacultyLoadReport => 'FacultyLoadReport',
      _i22.RoomUtilizationReport => 'RoomUtilizationReport',
      _i23.ScheduleOverviewReport => 'ScheduleOverviewReport',
      _i24.Room => 'Room',
      _i25.RoomType => 'RoomType',
      _i26.Schedule => 'Schedule',
      _i27.ScheduleConflict => 'ScheduleConflict',
      _i28.ScheduleInfo => 'ScheduleInfo',
      _i29.Section => 'Section',
      _i30.Student => 'Student',
      _i31.Subject => 'Subject',
      _i32.SubjectType => 'SubjectType',
      _i33.Timeslot => 'Timeslot',
      _i34.TimetableFilterRequest => 'TimetableFilterRequest',
      _i35.TimetableSummary => 'TimetableSummary',
      _i36.UserRole => 'UserRole',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('citesched.', '');
    }

    switch (data) {
      case _i6.DashboardStats():
        return 'DashboardStats';
      case _i7.DayOfWeek():
        return 'DayOfWeek';
      case _i8.DistributionData():
        return 'DistributionData';
      case _i9.EmploymentStatus():
        return 'EmploymentStatus';
      case _i10.Faculty():
        return 'Faculty';
      case _i11.FacultyAvailability():
        return 'FacultyAvailability';
      case _i12.FacultyLoadData():
        return 'FacultyLoadData';
      case _i13.FacultyShiftPreference():
        return 'FacultyShiftPreference';
      case _i14.GenerateScheduleRequest():
        return 'GenerateScheduleRequest';
      case _i15.GenerateScheduleResponse():
        return 'GenerateScheduleResponse';
      case _i16.Greeting():
        return 'Greeting';
      case _i17.NLPIntent():
        return 'NLPIntent';
      case _i18.NLPResponse():
        return 'NLPResponse';
      case _i19.Program():
        return 'Program';
      case _i20.ConflictSummaryReport():
        return 'ConflictSummaryReport';
      case _i21.FacultyLoadReport():
        return 'FacultyLoadReport';
      case _i22.RoomUtilizationReport():
        return 'RoomUtilizationReport';
      case _i23.ScheduleOverviewReport():
        return 'ScheduleOverviewReport';
      case _i24.Room():
        return 'Room';
      case _i25.RoomType():
        return 'RoomType';
      case _i26.Schedule():
        return 'Schedule';
      case _i27.ScheduleConflict():
        return 'ScheduleConflict';
      case _i28.ScheduleInfo():
        return 'ScheduleInfo';
      case _i29.Section():
        return 'Section';
      case _i30.Student():
        return 'Student';
      case _i31.Subject():
        return 'Subject';
      case _i32.SubjectType():
        return 'SubjectType';
      case _i33.Timeslot():
        return 'Timeslot';
      case _i34.TimetableFilterRequest():
        return 'TimetableFilterRequest';
      case _i35.TimetableSummary():
        return 'TimetableSummary';
      case _i36.UserRole():
        return 'UserRole';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i5.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'DashboardStats') {
      return deserialize<_i6.DashboardStats>(data['data']);
    }
    if (dataClassName == 'DayOfWeek') {
      return deserialize<_i7.DayOfWeek>(data['data']);
    }
    if (dataClassName == 'DistributionData') {
      return deserialize<_i8.DistributionData>(data['data']);
    }
    if (dataClassName == 'EmploymentStatus') {
      return deserialize<_i9.EmploymentStatus>(data['data']);
    }
    if (dataClassName == 'Faculty') {
      return deserialize<_i10.Faculty>(data['data']);
    }
    if (dataClassName == 'FacultyAvailability') {
      return deserialize<_i11.FacultyAvailability>(data['data']);
    }
    if (dataClassName == 'FacultyLoadData') {
      return deserialize<_i12.FacultyLoadData>(data['data']);
    }
    if (dataClassName == 'FacultyShiftPreference') {
      return deserialize<_i13.FacultyShiftPreference>(data['data']);
    }
    if (dataClassName == 'GenerateScheduleRequest') {
      return deserialize<_i14.GenerateScheduleRequest>(data['data']);
    }
    if (dataClassName == 'GenerateScheduleResponse') {
      return deserialize<_i15.GenerateScheduleResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i16.Greeting>(data['data']);
    }
    if (dataClassName == 'NLPIntent') {
      return deserialize<_i17.NLPIntent>(data['data']);
    }
    if (dataClassName == 'NLPResponse') {
      return deserialize<_i18.NLPResponse>(data['data']);
    }
    if (dataClassName == 'Program') {
      return deserialize<_i19.Program>(data['data']);
    }
    if (dataClassName == 'ConflictSummaryReport') {
      return deserialize<_i20.ConflictSummaryReport>(data['data']);
    }
    if (dataClassName == 'FacultyLoadReport') {
      return deserialize<_i21.FacultyLoadReport>(data['data']);
    }
    if (dataClassName == 'RoomUtilizationReport') {
      return deserialize<_i22.RoomUtilizationReport>(data['data']);
    }
    if (dataClassName == 'ScheduleOverviewReport') {
      return deserialize<_i23.ScheduleOverviewReport>(data['data']);
    }
    if (dataClassName == 'Room') {
      return deserialize<_i24.Room>(data['data']);
    }
    if (dataClassName == 'RoomType') {
      return deserialize<_i25.RoomType>(data['data']);
    }
    if (dataClassName == 'Schedule') {
      return deserialize<_i26.Schedule>(data['data']);
    }
    if (dataClassName == 'ScheduleConflict') {
      return deserialize<_i27.ScheduleConflict>(data['data']);
    }
    if (dataClassName == 'ScheduleInfo') {
      return deserialize<_i28.ScheduleInfo>(data['data']);
    }
    if (dataClassName == 'Section') {
      return deserialize<_i29.Section>(data['data']);
    }
    if (dataClassName == 'Student') {
      return deserialize<_i30.Student>(data['data']);
    }
    if (dataClassName == 'Subject') {
      return deserialize<_i31.Subject>(data['data']);
    }
    if (dataClassName == 'SubjectType') {
      return deserialize<_i32.SubjectType>(data['data']);
    }
    if (dataClassName == 'Timeslot') {
      return deserialize<_i33.Timeslot>(data['data']);
    }
    if (dataClassName == 'TimetableFilterRequest') {
      return deserialize<_i34.TimetableFilterRequest>(data['data']);
    }
    if (dataClassName == 'TimetableSummary') {
      return deserialize<_i35.TimetableSummary>(data['data']);
    }
    if (dataClassName == 'UserRole') {
      return deserialize<_i36.UserRole>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i4.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i5.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i5.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i10.Faculty:
        return _i10.Faculty.t;
      case _i11.FacultyAvailability:
        return _i11.FacultyAvailability.t;
      case _i24.Room:
        return _i24.Room.t;
      case _i26.Schedule:
        return _i26.Schedule.t;
      case _i29.Section:
        return _i29.Section.t;
      case _i30.Student:
        return _i30.Student.t;
      case _i31.Subject:
        return _i31.Subject.t;
      case _i33.Timeslot:
        return _i33.Timeslot.t;
      case _i36.UserRole:
        return _i36.UserRole.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'citesched';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i5.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
