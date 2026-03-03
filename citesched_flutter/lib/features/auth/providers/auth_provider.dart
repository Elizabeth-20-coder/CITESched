import 'package:citesched_flutter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

final authProvider = NotifierProvider<AuthNotifier, UserInfo?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserInfo?> {
  String? _selectedRole;

  @override
  UserInfo? build() {
    // Initialize auth listener
    _init();
    return null; // Initial state
  }

  Future<void> _init() async {
    // Add listener to auth state changes
    client.auth.authInfoListenable.addListener(_onAuthStateChanged);

    // Check initial state
    if (client.auth.isAuthenticated) {
      try {
        final profile = await client.modules.serverpod_auth_core.userProfileInfo
            .get();
        final email = profile.email;
        if (email != null && email.isNotEmpty) {
          final userInfo = await client.setup.getUserInfoByEmail(email: email);
          if (userInfo != null) {
            state = userInfo;
          }
        }
      } catch (e) {
        print('Failed to fetch user info: $e');
      }
    }
  }

  void _onAuthStateChanged() {
    if (!client.auth.isAuthenticated) {
      state = null;
    }
    // If authenticated, we rely on manual update or init to fetch info
    // to avoid async issues in listener
  }

  // Method to manually update user info (e.g., after custom login)
  void updateUserInfo(UserInfo? userInfo) {
    state = userInfo;
  }

  void setSelectedRole(String? role) {
    _selectedRole = role;
  }

  String? get selectedRole => _selectedRole;

  Future<void> signOut() async {
    await client.auth.signOutDevice();
    _selectedRole = null;
    state = null;
  }

  bool get isSignedIn => state != null;

  // Helper to check roles (can be expanded later)
  bool get isAdmin => state?.scopeNames.contains('admin') ?? false;
  bool get isFaculty => state?.scopeNames.contains('faculty') ?? false;
  bool get isStudent => state?.scopeNames.contains('student') ?? false;

  // We don't need override dispose in Notifier,
  // currently we can't easily remove listener on dispose in Notifier
  // without using ref.onDispose, but referencing methods is tricky.
  // For a singleton auth provider, it effectively lives as long as the app.
}
