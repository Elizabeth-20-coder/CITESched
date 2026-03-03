import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import '../generated/protocol.dart';

class SetupEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<bool> createAccount(
    Session session, {
    required String userName,
    required String email,
    required String password,
    required String role,
    String? studentId,
    String? facultyId,
    String? section,
  }) async {
    try {
      var userInfo = await Emails.createUser(
        session,
        userName,
        email,
        password,
      );
      if (userInfo == null) {
        session.log(
          'User $email might already exist. Trying to update scopes...',
        );
        userInfo = await UserInfo.db.findFirstRow(
          session,
          where: (t) => t.email.equals(email),
        );

        if (userInfo == null) {
          session.log(
            'Failed to find user $email even though createUser returned null.',
          );
          return false;
        }
      }

      // Sync the role to scopeNames for the client
      var currentScopes = userInfo.scopeNames.toSet();
      if (!currentScopes.contains(role)) {
        currentScopes.add(role);
        userInfo.scopeNames = currentScopes.toList();
        await UserInfo.db.updateRow(session, userInfo);
      }

      // Create linked profile based on role
      if (role == 'student' && studentId != null) {
        var existingStudent = await Student.db.findFirstRow(
          session,
          where: (t) => t.email.equals(email),
        );
        if (existingStudent == null) {
          int? sectionId;
          if (section != null && section.isNotEmpty) {
            try {
              var existingSection = await Section.db.findFirstRow(
                session,
                where: (t) => t.sectionCode.equals(section),
              );

              if (existingSection != null) {
                sectionId = existingSection.id;
              } else {
                var prog = Program.it;
                var year = 1;
                if (section.toUpperCase().contains('EMC')) {
                  prog = Program.emc;
                }
                final yearMatch = RegExp(r'\d').firstMatch(section);
                if (yearMatch != null) {
                  year = int.parse(yearMatch.group(0)!);
                }

                final newSection = await Section.db.insertRow(
                  session,
                  Section(
                    sectionCode: section,
                    program: prog,
                    yearLevel: year,
                    semester: 1,
                    academicYear:
                        '${DateTime.now().year}-${DateTime.now().year + 1}',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                sectionId = newSection.id;
              }
            } catch (e) {
              session.log('Error syncing section: $e');
            }
          }

          await Student.db.insertRow(
            session,
            Student(
              name: userName,
              email: email,
              studentNumber: studentId,
              course: 'BSIT',
              yearLevel: 1,
              section: section,
              sectionId: sectionId,
              userInfoId: userInfo.id!,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      } else if ((role == 'faculty' || role == 'admin') && facultyId != null) {
        var existingFaculty = await Faculty.db.findFirstRow(
          session,
          where: (t) => t.email.equals(email),
        );
        if (existingFaculty == null) {
          await Faculty.db.insertRow(
            session,
            Faculty(
              name: userName,
              email: email,
              maxLoad: 18,
              employmentStatus: EmploymentStatus.fullTime,
              shiftPreference: FacultyShiftPreference.any,
              facultyId: facultyId,
              userInfoId: userInfo.id!,
              program: Program.it, // Default
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      // Add UserRole entry to ensure authenticationHandler picks it up
      var userIdStr = userInfo.id!.toString();
      var existingRole = await UserRole.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userIdStr),
      );

      if (existingRole == null) {
        await UserRole.db.insertRow(
          session,
          UserRole(
            userId: userIdStr,
            role: role,
          ),
        );
      } else if (existingRole.role != role) {
        // Update existing role if it differs
        existingRole.role = role;
        await UserRole.db.updateRow(session, existingRole);
      }

      session.log(
        'Created user $email with role $role and ID ${studentId ?? facultyId}',
      );
      return true;
    } catch (e) {
      session.log('Error creating user: $e');
      return false;
    }
  }

  /// Fetches a UserInfo by email (case-insensitive).
  Future<UserInfo?> getUserInfoByEmail(
    Session session, {
    required String email,
  }) async {
    final emailLower = email.toLowerCase();
    return await UserInfo.db.findFirstRow(
      session,
      where: (t) => t.email.equals(emailLower),
    );
  }
}
