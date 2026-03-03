import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart'
    as auth_legacy;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  final identityProviders = <IdentityProviderBuilder>[
    // Configure the email identity provider for email/password authentication.
    EmailIdpConfigFromPasswords(
      sendRegistrationVerificationCode: _sendRegistrationCode,
      sendPasswordResetVerificationCode: _sendPasswordResetCode,
      onAfterAccountCreated: _onAfterAccountCreated,
    ),
  ];
  // Enable Google IdP only if a client secret is configured in passwords.yaml.
  if (pod.getPassword('googleClientSecret') != null) {
    identityProviders.add(GoogleIdpConfigFromPasswords());
  }

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use ServerSideSessions for authentication keys towards the server.
      ServerSideSessionsConfigFromPasswords(),
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: identityProviders,
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Custom authentication handler to manage scopes based on UserRole.
  // This overrides the default handler set by initializeAuthServices so that
  // each authenticated request carries the user's role as a Scope.
  pod.authenticationHandler = (Session session, String key) async {
    try {
      // 1. Try modern AuthServices (Session + JWT token managers)
      var authInfo = await AuthServices.instance.authenticationHandler(
        session,
        key,
      );

      // 2. If modern auth failed, try legacy AuthKey authentication
      //    (used by serverpod_auth_server's Emails.authenticate)
      if (authInfo == null) {
        print(
          'AUTH DEBUG: Modern auth returned null, trying legacy AuthKey...',
        );
        authInfo = await auth_legacy.authenticationHandler(session, key);
      }

      if (authInfo == null) {
        print('AUTH DEBUG: All authentication methods failed.');
        return null;
      }

      print('AUTH DEBUG: Authenticated User ID: ${authInfo.userIdentifier}');
      print(
        'AUTH DEBUG: Base Scopes: ${authInfo.scopes.map((s) => s.name).join(", ")}',
      );

      // Look up the user's role from our UserRole table.
      var userIdStr = authInfo.userIdentifier.toString();
      var userRole = await UserRole.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userIdStr),
      );

      if (userRole != null) {
        print('AUTH DEBUG: UserRole found: ${userRole.role}');
        // Return a new AuthenticationInfo with the role scope added.
        return AuthenticationInfo(
          authInfo.userIdentifier,
          {...authInfo.scopes, Scope(userRole.role)},
          authId: authInfo.authId,
        );
      } else {
        print('AUTH DEBUG: No UserRole found for userId: $userIdStr');
      }

      return authInfo;
    } catch (e, stack) {
      print('AUTH DEBUG ERROR: $e');
      print(stack);
      return null;
    }
  };

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}

/// Called after a new email account is created.
/// Assigns the default 'student' role to every new user.
Future<void> _onAfterAccountCreated(
  Session session, {
  required String email,
  required UuidValue authUserId,
  required UuidValue emailAccountId,
  required Transaction? transaction,
}) async {
  // 1. Assign the default 'student' role in our UserRole table
  await UserRole.db.insertRow(
    session,
    UserRole(
      userId: authUserId.toString(),
      role: 'student',
    ),
    transaction: transaction,
  );

  // 2. Sync the role to UserInfo.scopeNames so the client picks it up
  try {
    var userInfo = await auth_legacy.UserInfo.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
      transaction: transaction,
    );
    if (userInfo != null) {
      if (userInfo.scopeNames.contains('student')) return;
      var scopes = userInfo.scopeNames.toSet();
      scopes.add('student');
      userInfo.scopeNames = scopes.toList();
      await auth_legacy.UserInfo.db.updateRow(
        session,
        userInfo,
        transaction: transaction,
      );
    }
  } catch (e) {
    session.log('Error syncing scope to UserInfo: $e');
  }

  session.log('[Auth] Default role "student" assigned to user $authUserId');
}
