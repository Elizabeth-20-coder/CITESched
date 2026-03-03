import 'package:citesched_flutter/main.dart'; // Import for client access
import 'package:citesched_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_client/serverpod_client.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  late final GoogleAuthController _googleAuthController;

  bool _isFaculty = true; // Toggle state
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isDarkMode = false; // Add dark mode state
  String? _errorMessage;

  // Design Constants - Light Mode Theme Colors
  static const _facultyColorLight = Color(0xFF4F003B);
  static const _studentColorLight = Color(0xFF004085);

  // Dark Mode Theme Colors
  static const _facultyColorDark = Color(0xFFa21caf);
  static const _studentColorDark = Color(0xFF3b82f6);

  // Light Mode Colors
  static const _bgBodyLight = Color(0xFFEEF1F6);
  static const _bgRightLight = Color(
    0xFFF7F9FC,
  ); // Used for right side background if distinct
  static const _cardBgLight = Colors.white;
  static const _textPrimaryLight = Color.fromARGB(255, 182, 182, 182);
  static const _textMutedLight = Color(0xFF666666);
  static const _inputBorderLight = Color(0xFFDDDDDD);

  // Dark Mode Colors
  static const _bgBodyDark = Color(0xFF0F172A);
  static const _bgRightDark = Color(
    0xFF1E293B,
  ); // Used for right side background if distinct
  static const _cardBgDark = Color(0xFF1E293B);
  static const _textPrimaryDark = Color(0xFFE2E8F0);
  static const _textMutedDark = Color(0xFF94A3B8);
  static const _inputBorderDark = Color(0xFF475569);

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final id = _idController.text.trim();
      final password = _passwordController.text.trim();

      if (id.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter ID and password';
          _isLoading = false;
        });
        return;
      }

      // Use dynamic access to bypass static analysis issues
      final dynamicClient = client as dynamic;
      // Call the custom auth endpoint
      final result = await dynamicClient.customAuth.loginWithId(
        id: id,
        password: password,
        role: _isFaculty ? 'faculty' : 'student',
      );

      if (result.success &&
          result.userInfo != null &&
          result.keyId != null &&
          result.key != null) {
        // Register the session with Serverpod's SessionManager
        // This is CRITICAL for subsequent requests to be authenticated
        print('Login Successful. KeyID: ${result.keyId}, Key: ${result.key}');
        print('UserInfo: ${result.userInfo}');

        // Create a fake UUID from the integer keyId to satisfy AuthSuccess (v3) requirements
        // userIdentifier is not strictly used for session key validation in some configs
        var fakeUuid = UuidValue.fromString(
          "00000000-0000-0000-0000-${result.keyId.toString().padLeft(12, '0')}",
        );

        // Serverpod typically expects "keyId:key" as the token for integer-based IDs
        String formattedToken = '${result.keyId}:${result.key}';

        var authSuccess = AuthSuccess(
          authUserId: fakeUuid,
          token: formattedToken,
          scopeNames: result.userInfo!.scopeNames.toSet(),
          authStrategy: 'session',
        );
        print('Updating signed in user with AuthSuccess: $authSuccess');
        await client.auth.updateSignedInUser(authSuccess);

        // Update the auth provider (though the listener might handle it now)
        final authNotifier = ref.read(authProvider.notifier);
        authNotifier.updateUserInfo(result.userInfo);
        authNotifier.setSelectedRole(_isFaculty ? 'faculty' : 'student');

        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
          // Navigation will happen automatically via RootScreen watching authProvider
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _googleAuthController.signIn();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleAuthenticated() async {
    try {
      final profile = await client.modules.serverpod_auth_core.userProfileInfo
          .get();
      final email = profile.email;
      final displayName = profile.fullName ?? profile.userName;

      final authNotifier = ref.read(authProvider.notifier);
      UserInfo? userInfo;
      if (email != null && email.isNotEmpty) {
        userInfo = await client.setup.getUserInfoByEmail(email: email);
      }
      if (userInfo != null) {
        authNotifier.updateUserInfo(userInfo);
      }

      final roles = _rolesFromScopes(userInfo?.scopeNames ?? const []);
      String? selectedRole;
      if (roles.isEmpty) {
        selectedRole = await _showRoleSelectionDialog(
          const ['faculty', 'student', 'admin'],
        );
        if (selectedRole == null) {
          await client.auth.signOutDevice();
          authNotifier.updateUserInfo(null);
          return;
        }

        final completed = await _completeGoogleProfile(
          selectedRole,
          email: email,
          displayName: displayName,
        );
        if (!completed) {
          throw Exception('Failed to set up account details.');
        }

        if (email == null || email.isEmpty) {
          throw Exception('Missing email from Google profile.');
        }
        final refreshedInfo = await client.setup.getUserInfoByEmail(
          email: email,
        );
        if (refreshedInfo == null) {
          throw Exception('Unable to refresh user info after setup.');
        }
        authNotifier.updateUserInfo(refreshedInfo);
      } else {
        selectedRole = await _showRoleSelectionDialog(roles);
      }
      if (selectedRole == null) {
        await client.auth.signOutDevice();
        authNotifier.updateUserInfo(null);
        return;
      }

      authNotifier.setSelectedRole(selectedRole);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
      await client.auth.signOutDevice();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _completeGoogleProfile(
    String role, {
    String? email,
    String? displayName,
  }) async {
    final details = await _showRoleDetailsDialog(
      role,
      email: email,
      displayName: displayName,
    );
    if (details == null) return false;

    final name = details['name'] as String? ?? displayName ?? '';
    final effectiveEmail = details['email'] as String? ?? email ?? '';
    final studentId = details['studentId'] as String?;
    final facultyId = details['facultyId'] as String?;
    final section = details['section'] as String?;

    if (name.trim().isEmpty || effectiveEmail.trim().isEmpty) {
      return false;
    }

    final tempPassword = 'Google-${DateTime.now().millisecondsSinceEpoch}';

    return await client.setup.createAccount(
      userName: name.trim(),
      email: effectiveEmail.trim(),
      password: tempPassword,
      role: role,
      studentId: studentId?.trim().isEmpty == true ? null : studentId?.trim(),
      facultyId: facultyId?.trim().isEmpty == true ? null : facultyId?.trim(),
      section: section?.trim().isEmpty == true ? null : section?.trim(),
    );
  }

  Future<Map<String, String>?> _showRoleDetailsDialog(
    String role, {
    String? email,
    String? displayName,
  }) {
    final nameController = TextEditingController(text: displayName ?? '');
    final emailController = TextEditingController(text: email ?? '');
    final idController = TextEditingController();
    final sectionController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            role == 'student'
                ? 'Student Details'
                : role == 'faculty'
                    ? 'Faculty Details'
                    : 'Admin Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText:
                        role == 'student' ? 'Student Number' : 'Faculty ID',
                  ),
                ),
                if (role == 'student') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: sectionController,
                    decoration: const InputDecoration(labelText: 'Section'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'email': emailController.text,
                  'studentId': role == 'student' ? idController.text : '',
                  'facultyId': role == 'student' ? '' : idController.text,
                  'section': sectionController.text,
                });
              },
              child: Text('Continue', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  List<String> _rolesFromScopes(Iterable<String> scopes) {
    final allowed = <String>{'admin', 'faculty', 'student'};
    return scopes.where(allowed.contains).toList();
  }

  Future<String?> _showRoleSelectionDialog(List<String> roles) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Role',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles.map((role) {
              final label = role == 'admin'
                  ? 'Administrator'
                  : role == 'faculty'
                      ? 'Faculty'
                      : 'Student';
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, role),
                  child: Text(label, style: GoogleFonts.poppins()),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
    _googleAuthController = GoogleAuthController(
      client: client,
      onAuthenticated: _handleGoogleAuthenticated,
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _googleAuthController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    // --- 1. DYNAMIC THEME COLORS ---

    // Main Backgrounds
    final bgBody = _isDarkMode ? _bgBodyDark : _bgBodyLight;
    final bgRight = _isDarkMode ? _bgRightDark : _bgRightLight;
    final cardBg = _isDarkMode ? _cardBgDark : _cardBgLight;

    // Text Colors
    final textPrimary = _isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final textMuted = _isDarkMode ? Colors.white60 : Colors.grey.shade600;

    // Input Fields
    final inputFillColor = _isDarkMode
        ? const Color(0xFF334155)
        : Colors.grey.shade200;
    final inputBorderColor = _isDarkMode
        ? Colors.transparent
        : Colors.transparent;
    final inputTextColor = _isDarkMode ? Colors.white : Colors.black87;

    // Active Brand Color (Purple/Pink)
    final activeThemeColor = _isDarkMode
        ? (_isFaculty ? _facultyColorDark : _studentColorDark)
        : (_isFaculty ? _facultyColorLight : _studentColorLight);

    // Google Button Specifics
    final googleBtnBg = _isDarkMode ? Colors.transparent : Colors.white;
    final googleBtnBorder = _isDarkMode ? Colors.white54 : Colors.grey.shade300;
    final googleBtnText = _isDarkMode ? Colors.white : Colors.black87;

    // --- 2. INPUT FIELD BUILDER (Fixed: No active green outline) ---
    Widget buildCustomField({
      required TextEditingController controller,
      required String hintText,
      bool isPassword = false,
    }) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(12),
          // We use a static border color (or transparent if you prefer no border)
          border: Border.all(color: inputBorderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            cursorColor: textPrimary, // Cursor matches text color
            style: GoogleFonts.poppins(
              color: inputTextColor, // Typing text color (White/Black)
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: textMuted,
                fontSize: 14,
              ),
              // Disable all default borders to prevent the green line
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgBody,
      body: Row(
        children: [
          // Left Side (Desktop Image)
          if (isDesktop)
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/jmcbackground.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: activeThemeColor),
                  ),
                  Container(color: Colors.black.withOpacity(0.3)),
                  Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CITESched',
                          style: GoogleFonts.poppins(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Secure access to faculty loading and schedules.',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Right Side (Form)
          Expanded(
            flex: 1,
            child: Container(
              color: bgRight,
              child: Stack(
                children: [
                  // Theme Toggle
                  Positioned(
                    top: 25,
                    right: 25,
                    child: InkWell(
                      onTap: () => setState(() => _isDarkMode = !_isDarkMode),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _isDarkMode
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          color: textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Login Form Center
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 50,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/jmclogo.png',
                                  width: 90,
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Icons.school,
                                    size: 60,
                                    color: activeThemeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (_errorMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),

                              // HEADER TEXT (Fixed Color)
                              Text(
                                _isFaculty ? 'Faculty Login' : 'Student Login',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      textPrimary, // Uses White (Dark) or Black (Light)
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Welcome back! Please enter your details.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Role Switcher
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: _isDarkMode
                                      ? Colors.black26
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    _buildRoleBtn(
                                      'Faculty',
                                      true,
                                      cardBg,
                                      activeThemeColor,
                                      textMuted,
                                    ),
                                    _buildRoleBtn(
                                      'Student',
                                      false,
                                      cardBg,
                                      activeThemeColor,
                                      textMuted,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Inputs
                              _buildLabel(
                                _isFaculty ? 'Username' : 'Student ID',
                                textPrimary,
                              ),
                              const SizedBox(height: 8),
                              buildCustomField(
                                controller: _idController,
                                hintText: 'Enter ID number',
                              ),

                              const SizedBox(height: 16),

                              _buildLabel('Password', textPrimary),
                              const SizedBox(height: 8),
                              buildCustomField(
                                controller: _passwordController,
                                hintText: '••••••••',
                                isPassword: true,
                              ),

                              const SizedBox(height: 16),

                              // Checkbox Row
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: !_obscurePassword,
                                      onChanged: (val) => setState(
                                        () => _obscurePassword = !val!,
                                      ),
                                      activeColor: activeThemeColor,
                                      checkColor: Colors.white,
                                      // Border color matches textMuted so it's visible in both modes
                                      side: BorderSide(
                                        color: textMuted,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Show Password',
                                    style: GoogleFonts.poppins(
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Login Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: activeThemeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'SIGN IN',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 40),
                              Text(
                                'OR SIGN IN WITH',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Google Button (uses platform-safe widget)
                              GoogleSignInWidget(
                                controller: _googleAuthController,
                                theme: _isDarkMode
                                    ? GSIButtonTheme.filledBlack
                                    : GSIButtonTheme.outline,
                                size: GSIButtonSize.large,
                                text: GSIButtonText.continueWith,
                                shape: GSIButtonShape.pill,
                                logoAlignment: GSIButtonLogoAlignment.center,
                                minimumWidth: 320,
                                buttonWrapper: ({
                                  required GoogleSignInStyle style,
                                  required Widget child,
                                  required VoidCallback? onPressed,
                                }) {
                                  return Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: googleBtnBg,
                                      border: Border.all(
                                        color: googleBtnBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await client.auth.initializeGoogleSignIn(
        clientId:
            '787281029476-efu9h96a0libvk8o0ubhsluh7u09fnen.apps.googleusercontent.com',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google Sign-In init failed: $e';
        });
      }
    }
  }

  Widget _buildRoleBtn(
    String text,
    bool targetIsFaculty,
    Color cardBg,
    Color activeTheme,
    Color textMuted,
  ) {
    bool isActive = _isFaculty == targetIsFaculty;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFaculty = targetIsFaculty;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        51,
                        51,
                        51,
                      ).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isActive ? activeTheme : textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500, // fw-medium
        color: color,
        fontSize: 16,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required Color bgBody,
    required Color cardBg,
    required Color inputBorder,
    required Color activeTheme,
    required Color textPrimary,
    bool isPassword = false,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: hasFocus ? cardBg : bgBody,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? activeTheme : inputBorder,
                width: 1.5,
              ),
              boxShadow: hasFocus
                  ? [
                      // Remove focus shadow if not in design, but bootstrap has subtle one.
                      // CSS says: box-shadow: none; border-color: var(--active-theme);
                      // so we stick to border color change.
                    ]
                  : [],
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword && _obscurePassword,
              style: GoogleFonts.poppins(color: textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                  color: textPrimary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          );
        },
      ),
    );
  }
}
