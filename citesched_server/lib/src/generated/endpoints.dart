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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/admin_endpoint.dart' as _i4;
import '../endpoints/custom_auth_endpoint.dart' as _i5;
import '../endpoints/debug_endpoint.dart' as _i6;
import '../endpoints/faculty_endpoint.dart' as _i7;
import '../endpoints/nlp_endpoint.dart' as _i8;
import '../endpoints/setup_endpoint.dart' as _i9;
import '../endpoints/student_endpoint.dart' as _i10;
import '../endpoints/student_schedule_endpoint.dart' as _i11;
import '../endpoints/timetable_endpoint.dart' as _i12;
import '../greetings/greeting_endpoint.dart' as _i13;
import '../auth/google_idp_endpoint.dart' as _i27;
import 'package:citesched_server/src/generated/faculty.dart' as _i14;
import 'package:citesched_server/src/generated/student.dart' as _i15;
import 'package:citesched_server/src/generated/room.dart' as _i16;
import 'package:citesched_server/src/generated/subject.dart' as _i17;
import 'package:citesched_server/src/generated/timeslot.dart' as _i18;
import 'package:citesched_server/src/generated/schedule.dart' as _i19;
import 'package:citesched_server/src/generated/generate_schedule_request.dart'
    as _i20;
import 'package:citesched_server/src/generated/section.dart' as _i21;
import 'package:citesched_server/src/generated/faculty_availability.dart'
    as _i22;
import 'package:citesched_server/src/generated/timetable_filter_request.dart'
    as _i23;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i24;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i25;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i26;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'googleIdp': _i27.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'admin': _i4.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'customAuth': _i5.CustomAuthEndpoint()
        ..initialize(
          server,
          'customAuth',
          null,
        ),
      'debug': _i6.DebugEndpoint()
        ..initialize(
          server,
          'debug',
          null,
        ),
      'faculty': _i7.FacultyEndpoint()
        ..initialize(
          server,
          'faculty',
          null,
        ),
      'nLP': _i8.NLPEndpoint()
        ..initialize(
          server,
          'nLP',
          null,
        ),
      'setup': _i9.SetupEndpoint()
        ..initialize(
          server,
          'setup',
          null,
        ),
      'student': _i10.StudentEndpoint()
        ..initialize(
          server,
          'student',
          null,
        ),
      'studentSchedule': _i11.StudentScheduleEndpoint()
        ..initialize(
          server,
          'studentSchedule',
          null,
        ),
      'timetable': _i12.TimetableEndpoint()
        ..initialize(
          server,
          'timetable',
          null,
        ),
      'greeting': _i13.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i27.GoogleIdpEndpoint).login(
                session,
                idToken: params['idToken'],
                accessToken: params['accessToken'],
              ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['admin'] = _i1.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'assignRole': _i1.MethodConnector(
          name: 'assignRole',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint).assignRole(
                session,
                userId: params['userId'],
                role: params['role'],
              ),
        ),
        'getAllUserRoles': _i1.MethodConnector(
          name: 'getAllUserRoles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getAllUserRoles(session),
        ),
        'createFaculty': _i1.MethodConnector(
          name: 'createFaculty',
          params: {
            'faculty': _i1.ParameterDescription(
              name: 'faculty',
              type: _i1.getType<_i14.Faculty>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createFaculty(
                    session,
                    params['faculty'],
                  ),
        ),
        'getAllFaculty': _i1.MethodConnector(
          name: 'getAllFaculty',
          params: {
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getAllFaculty(
                    session,
                    isActive: params['isActive'],
                  ),
        ),
        'updateFaculty': _i1.MethodConnector(
          name: 'updateFaculty',
          params: {
            'faculty': _i1.ParameterDescription(
              name: 'faculty',
              type: _i1.getType<_i14.Faculty>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateFaculty(
                    session,
                    params['faculty'],
                  ),
        ),
        'deleteFaculty': _i1.MethodConnector(
          name: 'deleteFaculty',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteFaculty(
                    session,
                    params['id'],
                  ),
        ),
        'createStudent': _i1.MethodConnector(
          name: 'createStudent',
          params: {
            'student': _i1.ParameterDescription(
              name: 'student',
              type: _i1.getType<_i15.Student>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createStudent(
                    session,
                    params['student'],
                  ),
        ),
        'getAllStudents': _i1.MethodConnector(
          name: 'getAllStudents',
          params: {
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getAllStudents(
                    session,
                    isActive: params['isActive'],
                  ),
        ),
        'updateStudent': _i1.MethodConnector(
          name: 'updateStudent',
          params: {
            'student': _i1.ParameterDescription(
              name: 'student',
              type: _i1.getType<_i15.Student>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateStudent(
                    session,
                    params['student'],
                  ),
        ),
        'getDistinctStudentSections': _i1.MethodConnector(
          name: 'getDistinctStudentSections',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getDistinctStudentSections(session),
        ),
        'deleteStudent': _i1.MethodConnector(
          name: 'deleteStudent',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteStudent(
                    session,
                    params['id'],
                  ),
        ),
        'createRoom': _i1.MethodConnector(
          name: 'createRoom',
          params: {
            'room': _i1.ParameterDescription(
              name: 'room',
              type: _i1.getType<_i16.Room>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint).createRoom(
                session,
                params['room'],
              ),
        ),
        'getAllRooms': _i1.MethodConnector(
          name: 'getAllRooms',
          params: {
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint).getAllRooms(
                session,
                isActive: params['isActive'],
              ),
        ),
        'updateRoom': _i1.MethodConnector(
          name: 'updateRoom',
          params: {
            'room': _i1.ParameterDescription(
              name: 'room',
              type: _i1.getType<_i16.Room>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint).updateRoom(
                session,
                params['room'],
              ),
        ),
        'deleteRoom': _i1.MethodConnector(
          name: 'deleteRoom',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint).deleteRoom(
                session,
                params['id'],
              ),
        ),
        'createSubject': _i1.MethodConnector(
          name: 'createSubject',
          params: {
            'subject': _i1.ParameterDescription(
              name: 'subject',
              type: _i1.getType<_i17.Subject>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createSubject(
                    session,
                    params['subject'],
                  ),
        ),
        'getAllSubjects': _i1.MethodConnector(
          name: 'getAllSubjects',
          params: {
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getAllSubjects(
                    session,
                    isActive: params['isActive'],
                  ),
        ),
        'updateSubject': _i1.MethodConnector(
          name: 'updateSubject',
          params: {
            'subject': _i1.ParameterDescription(
              name: 'subject',
              type: _i1.getType<_i17.Subject>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateSubject(
                    session,
                    params['subject'],
                  ),
        ),
        'deleteSubject': _i1.MethodConnector(
          name: 'deleteSubject',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteSubject(
                    session,
                    params['id'],
                  ),
        ),
        'createTimeslot': _i1.MethodConnector(
          name: 'createTimeslot',
          params: {
            'timeslot': _i1.ParameterDescription(
              name: 'timeslot',
              type: _i1.getType<_i18.Timeslot>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createTimeslot(
                    session,
                    params['timeslot'],
                  ),
        ),
        'getAllTimeslots': _i1.MethodConnector(
          name: 'getAllTimeslots',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getAllTimeslots(session),
        ),
        'updateTimeslot': _i1.MethodConnector(
          name: 'updateTimeslot',
          params: {
            'timeslot': _i1.ParameterDescription(
              name: 'timeslot',
              type: _i1.getType<_i18.Timeslot>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateTimeslot(
                    session,
                    params['timeslot'],
                  ),
        ),
        'deleteTimeslot': _i1.MethodConnector(
          name: 'deleteTimeslot',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteTimeslot(
                    session,
                    params['id'],
                  ),
        ),
        'createSchedule': _i1.MethodConnector(
          name: 'createSchedule',
          params: {
            'schedule': _i1.ParameterDescription(
              name: 'schedule',
              type: _i1.getType<_i19.Schedule>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createSchedule(
                    session,
                    params['schedule'],
                  ),
        ),
        'testMaxLoadValidation': _i1.MethodConnector(
          name: 'testMaxLoadValidation',
          params: {
            'facultyId': _i1.ParameterDescription(
              name: 'facultyId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'units': _i1.ParameterDescription(
              name: 'units',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .testMaxLoadValidation(
                    session,
                    params['facultyId'],
                    params['units'],
                  ),
        ),
        'getAllSchedules': _i1.MethodConnector(
          name: 'getAllSchedules',
          params: {
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getAllSchedules(
                    session,
                    isActive: params['isActive'],
                  ),
        ),
        'getFacultySchedule': _i1.MethodConnector(
          name: 'getFacultySchedule',
          params: {
            'facultyId': _i1.ParameterDescription(
              name: 'facultyId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getFacultySchedule(
                    session,
                    params['facultyId'],
                    isActive: params['isActive'],
                  ),
        ),
        'getSubjectSchedule': _i1.MethodConnector(
          name: 'getSubjectSchedule',
          params: {
            'subjectId': _i1.ParameterDescription(
              name: 'subjectId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getSubjectSchedule(
                    session,
                    params['subjectId'],
                    isActive: params['isActive'],
                  ),
        ),
        'getRoomSchedule': _i1.MethodConnector(
          name: 'getRoomSchedule',
          params: {
            'roomId': _i1.ParameterDescription(
              name: 'roomId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).getRoomSchedule(
                    session,
                    params['roomId'],
                    isActive: params['isActive'],
                  ),
        ),
        'updateSchedule': _i1.MethodConnector(
          name: 'updateSchedule',
          params: {
            'schedule': _i1.ParameterDescription(
              name: 'schedule',
              type: _i1.getType<_i19.Schedule>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateSchedule(
                    session,
                    params['schedule'],
                  ),
        ),
        'deleteSchedule': _i1.MethodConnector(
          name: 'deleteSchedule',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteSchedule(
                    session,
                    params['id'],
                  ),
        ),
        'generateSchedule': _i1.MethodConnector(
          name: 'generateSchedule',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i20.GenerateScheduleRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).generateSchedule(
                    session,
                    params['request'],
                  ),
        ),
        'getDashboardStats': _i1.MethodConnector(
          name: 'getDashboardStats',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getDashboardStats(session),
        ),
        'validateSchedule': _i1.MethodConnector(
          name: 'validateSchedule',
          params: {
            'schedule': _i1.ParameterDescription(
              name: 'schedule',
              type: _i1.getType<_i19.Schedule>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).validateSchedule(
                    session,
                    params['schedule'],
                  ),
        ),
        'getAllConflicts': _i1.MethodConnector(
          name: 'getAllConflicts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getAllConflicts(session),
        ),
        'getFacultyLoadReport': _i1.MethodConnector(
          name: 'getFacultyLoadReport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getFacultyLoadReport(session),
        ),
        'getRoomUtilizationReport': _i1.MethodConnector(
          name: 'getRoomUtilizationReport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getRoomUtilizationReport(session),
        ),
        'getConflictSummaryReport': _i1.MethodConnector(
          name: 'getConflictSummaryReport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getConflictSummaryReport(session),
        ),
        'getScheduleOverviewReport': _i1.MethodConnector(
          name: 'getScheduleOverviewReport',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getScheduleOverviewReport(session),
        ),
        'createSection': _i1.MethodConnector(
          name: 'createSection',
          params: {
            'section': _i1.ParameterDescription(
              name: 'section',
              type: _i1.getType<_i21.Section>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).createSection(
                    session,
                    params['section'],
                  ),
        ),
        'getAllSections': _i1.MethodConnector(
          name: 'getAllSections',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getAllSections(session),
        ),
        'updateSection': _i1.MethodConnector(
          name: 'updateSection',
          params: {
            'section': _i1.ParameterDescription(
              name: 'section',
              type: _i1.getType<_i21.Section>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).updateSection(
                    session,
                    params['section'],
                  ),
        ),
        'deleteSection': _i1.MethodConnector(
          name: 'deleteSection',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i4.AdminEndpoint).deleteSection(
                    session,
                    params['id'],
                  ),
        ),
        'setFacultyAvailability': _i1.MethodConnector(
          name: 'setFacultyAvailability',
          params: {
            'facultyId': _i1.ParameterDescription(
              name: 'facultyId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'availabilities': _i1.ParameterDescription(
              name: 'availabilities',
              type: _i1.getType<List<_i22.FacultyAvailability>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .setFacultyAvailability(
                    session,
                    params['facultyId'],
                    params['availabilities'],
                  ),
        ),
        'getFacultyAvailability': _i1.MethodConnector(
          name: 'getFacultyAvailability',
          params: {
            'facultyId': _i1.ParameterDescription(
              name: 'facultyId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getFacultyAvailability(
                    session,
                    params['facultyId'],
                  ),
        ),
        'getAllFacultyAvailabilities': _i1.MethodConnector(
          name: 'getAllFacultyAvailabilities',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .getAllFacultyAvailabilities(session),
        ),
        'deleteFacultyAvailability': _i1.MethodConnector(
          name: 'deleteFacultyAvailability',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .deleteFacultyAvailability(
                    session,
                    params['id'],
                  ),
        ),
        'precheckSchedule': _i1.MethodConnector(
          name: 'precheckSchedule',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .precheckSchedule(session),
        ),
        'regenerateSchedule': _i1.MethodConnector(
          name: 'regenerateSchedule',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i4.AdminEndpoint)
                  .regenerateSchedule(session),
        ),
      },
    );
    connectors['customAuth'] = _i1.EndpointConnector(
      name: 'customAuth',
      endpoint: endpoints['customAuth']!,
      methodConnectors: {
        'loginWithId': _i1.MethodConnector(
          name: 'loginWithId',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['customAuth'] as _i5.CustomAuthEndpoint)
                  .loginWithId(
                    session,
                    id: params['id'],
                    password: params['password'],
                    role: params['role'],
                  ),
        ),
      },
    );
    connectors['debug'] = _i1.EndpointConnector(
      name: 'debug',
      endpoint: endpoints['debug']!,
      methodConnectors: {
        'getSessionInfo': _i1.MethodConnector(
          name: 'getSessionInfo',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['debug'] as _i6.DebugEndpoint)
                  .getSessionInfo(session),
        ),
      },
    );
    connectors['faculty'] = _i1.EndpointConnector(
      name: 'faculty',
      endpoint: endpoints['faculty']!,
      methodConnectors: {
        'getMySchedule': _i1.MethodConnector(
          name: 'getMySchedule',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['faculty'] as _i7.FacultyEndpoint)
                  .getMySchedule(session),
        ),
        'getMyProfile': _i1.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['faculty'] as _i7.FacultyEndpoint)
                  .getMyProfile(session),
        ),
      },
    );
    connectors['nLP'] = _i1.EndpointConnector(
      name: 'nLP',
      endpoint: endpoints['nLP']!,
      methodConnectors: {
        'query': _i1.MethodConnector(
          name: 'query',
          params: {
            'text': _i1.ParameterDescription(
              name: 'text',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['nLP'] as _i8.NLPEndpoint).query(
                session,
                params['text'],
              ),
        ),
      },
    );
    connectors['setup'] = _i1.EndpointConnector(
      name: 'setup',
      endpoint: endpoints['setup']!,
      methodConnectors: {
        'createAccount': _i1.MethodConnector(
          name: 'createAccount',
          params: {
            'userName': _i1.ParameterDescription(
              name: 'userName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'studentId': _i1.ParameterDescription(
              name: 'studentId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'facultyId': _i1.ParameterDescription(
              name: 'facultyId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'section': _i1.ParameterDescription(
              name: 'section',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['setup'] as _i9.SetupEndpoint).createAccount(
                    session,
                    userName: params['userName'],
                    email: params['email'],
                    password: params['password'],
                    role: params['role'],
                    studentId: params['studentId'],
                    facultyId: params['facultyId'],
                    section: params['section'],
                  ),
        ),
        'getUserInfoByEmail': _i1.MethodConnector(
          name: 'getUserInfoByEmail',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['setup'] as _i9.SetupEndpoint).getUserInfoByEmail(
                    session,
                    email: params['email'],
                  ),
        ),
      },
    );
    connectors['student'] = _i1.EndpointConnector(
      name: 'student',
      endpoint: endpoints['student']!,
      methodConnectors: {
        'getSchedules': _i1.MethodConnector(
          name: 'getSchedules',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getSchedules(session),
        ),
        'getScheduleById': _i1.MethodConnector(
          name: 'getScheduleById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getScheduleById(
                    session,
                    params['id'],
                  ),
        ),
        'getMyProfile': _i1.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getMyProfile(session),
        ),
        'updateMyProfile': _i1.MethodConnector(
          name: 'updateMyProfile',
          params: {
            'updatedProfile': _i1.ParameterDescription(
              name: 'updatedProfile',
              type: _i1.getType<_i15.Student>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .updateMyProfile(
                    session,
                    params['updatedProfile'],
                  ),
        ),
        'getFaculty': _i1.MethodConnector(
          name: 'getFaculty',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getFaculty(session),
        ),
        'getRooms': _i1.MethodConnector(
          name: 'getRooms',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getRooms(session),
        ),
        'getSubjects': _i1.MethodConnector(
          name: 'getSubjects',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getSubjects(session),
        ),
        'getTimeslots': _i1.MethodConnector(
          name: 'getTimeslots',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['student'] as _i10.StudentEndpoint)
                  .getTimeslots(session),
        ),
      },
    );
    connectors['studentSchedule'] = _i1.EndpointConnector(
      name: 'studentSchedule',
      endpoint: endpoints['studentSchedule']!,
      methodConnectors: {
        'fetchMySchedule': _i1.MethodConnector(
          name: 'fetchMySchedule',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['studentSchedule'] as _i11.StudentScheduleEndpoint)
                      .fetchMySchedule(session),
        ),
      },
    );
    connectors['timetable'] = _i1.EndpointConnector(
      name: 'timetable',
      endpoint: endpoints['timetable']!,
      methodConnectors: {
        'getSchedules': _i1.MethodConnector(
          name: 'getSchedules',
          params: {
            'filter': _i1.ParameterDescription(
              name: 'filter',
              type: _i1.getType<_i23.TimetableFilterRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['timetable'] as _i12.TimetableEndpoint)
                  .getSchedules(
                    session,
                    params['filter'],
                  ),
        ),
        'getSummary': _i1.MethodConnector(
          name: 'getSummary',
          params: {
            'filter': _i1.ParameterDescription(
              name: 'filter',
              type: _i1.getType<_i23.TimetableFilterRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['timetable'] as _i12.TimetableEndpoint).getSummary(
                    session,
                    params['filter'],
                  ),
        ),
        'getPersonalSchedule': _i1.MethodConnector(
          name: 'getPersonalSchedule',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['timetable'] as _i12.TimetableEndpoint)
                  .getPersonalSchedule(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i13.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i24.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth'] = _i25.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i26.Endpoints()
      ..initializeEndpoints(server);
  }
}
