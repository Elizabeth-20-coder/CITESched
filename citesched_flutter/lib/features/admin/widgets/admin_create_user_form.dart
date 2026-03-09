import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCreateUserForm extends StatefulWidget {
  final VoidCallback onSuccess;

  /// Optional: pre-select a role when opening the dialog.
  final String? initialRole;

  const AdminCreateUserForm({
    super.key,
    required this.onSuccess,
    this.initialRole,
  });

  @override
  State<AdminCreateUserForm> createState() => _AdminCreateUserFormState();
}

class _AdminCreateUserFormState extends State<AdminCreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  static const List<String> _allowedCourses = ['BSIT', 'BSEMC'];

  // Form fields
  final _studentNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _courseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _sectionController = TextEditingController();

  late String _selectedRole;
  String? _selectedCourse;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRole?.toLowerCase();
    _selectedRole = (initial == 'admin' || initial == 'student')
        ? initial!
        : 'student';
    _selectedCourse = _allowedCourses.first;
    _courseController.text = _selectedCourse!;
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _courseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  String _normalizeSectionCode(String input) {
    final match = RegExp(r'^\s*(\d+)\s*([A-Za-z][A-Za-z0-9]*)\s*$').firstMatch(
      input,
    );
    if (match == null) return input.trim().toUpperCase();
    final year = match.group(1)!;
    final suffix = match.group(2)!.toUpperCase();
    return '$year$suffix';
  }

  int? _extractYearLevelFromSection(String input) {
    final match = RegExp(r'^\s*(\d+)\s*[A-Za-z][A-Za-z0-9]*\s*$').firstMatch(
      input,
    );
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

    try {
      final isStudent = _selectedRole == 'student';
      if (isStudent) {
        final selected = (_selectedCourse ?? '').trim().toUpperCase();
        if (!_allowedCourses.contains(selected)) {
          setState(() {
            _errorMessage = 'Please select a valid course.';
          });
          return;
        }
        _selectedCourse = selected;
        _courseController.text = selected;
        final normalizedSection = _normalizeSectionCode(_sectionController.text);
        if (_extractYearLevelFromSection(normalizedSection) == null) {
          setState(() {
            _errorMessage = 'Section must be like 3A, 3B, 2A, or 2B.';
          });
          return;
        }
        _sectionController.text = normalizedSection;
      }
      final success = await client.setup.createAccount(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        studentId: isStudent ? _studentNumberController.text.trim() : null,
        section: isStudent && _sectionController.text.trim().isNotEmpty
            ? _normalizeSectionCode(_sectionController.text)
            : null,
      );

      if (success) {
        if (isStudent) {
          await _syncStudentProfile();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'User created successfully!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2e7d32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          widget.onSuccess();
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to create user. Email might be taken or invalid data.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncStudentProfile() async {
    final email = _emailController.text.trim().toLowerCase();
    final studentNumber = _studentNumberController.text.trim();
    final students = await client.admin.getAllStudents(isActive: true);
    Student? student;
    for (final s in students) {
      if (s.email.toLowerCase() == email ||
          s.studentNumber.toLowerCase() == studentNumber.toLowerCase()) {
        student = s;
        break;
      }
    }
    if (student == null) return;

    final updated = student.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      studentNumber: studentNumber,
      course: (_selectedCourse ?? _courseController.text).trim().toUpperCase(),
      yearLevel:
          _extractYearLevelFromSection(_sectionController.text) ??
          student.yearLevel,
      section: _sectionController.text.trim().isEmpty
          ? null
          : _normalizeSectionCode(_sectionController.text),
      updatedAt: DateTime.now(),
    );

    await client.admin.updateStudent(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = isDark
        ? const Color(0xFFa21caf)
        : const Color(0xFF720045);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgBody = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF1F6);
    final textPrimary = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF333333);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 820),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    const Color(0xFFb5179e),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New System User',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a new account for the CITESched system',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red[700],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Role
                      _buildLabel(
                        'Role',
                        Icons.verified_user_rounded,
                        textPrimary,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: _buildInputDecoration(
                          'Select role',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'student',
                            child: Text('Student'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_selectedRole == 'student') ...[
                        // Student Number
                        _buildLabel(
                          'Student Number',
                          Icons.badge_rounded,
                          textPrimary,
                        ),
                        TextFormField(
                          controller: _studentNumberController,
                          decoration: _buildInputDecoration(
                            '107690',
                            bgBody,
                            primaryPurple,
                            textMuted,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: textPrimary,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Full Name
                      _buildLabel(
                        'Full Name',
                        Icons.person_outline_rounded,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration(
                          'Nash Andrew',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(
                        'JMC Account or Any Email',
                        Icons.email_outlined,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          'nash.cabillon@jmc.edu.ph',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      if (_selectedRole == 'student') ...[
                      // Course
                      _buildLabel(
                        'Course',
                        Icons.school_outlined,
                        textPrimary,
                      ),
                      DropdownButtonFormField<String>(
                        value: _allowedCourses.contains(_selectedCourse)
                            ? _selectedCourse
                            : null,
                        decoration: _buildInputDecoration(
                          'Select program',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        items: _allowedCourses
                            .map(
                              (program) => DropdownMenuItem<String>(
                                value: program,
                                child: Text(
                                  program,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourse = value;
                            _courseController.text = value ?? '';
                          });
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Year & Section
                      _buildLabel(
                        'Year & Section',
                        Icons.group_rounded,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _sectionController,
                        decoration: _buildInputDecoration(
                          'e.g. 3A, 3B, 2A, 2B',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final normalized = _normalizeSectionCode(value);
                          if (_extractYearLevelFromSection(normalized) == null) {
                            return 'Use format like 3A, 3B, 2A, 2B';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ],

                      // Initial Password
                      _buildLabel(
                        'Initial Password',
                        Icons.lock_outline_rounded,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration(
                          'Min 8 characters',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        obscureText: true,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 8) return 'Min 8 chars';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Retype Password
                      _buildLabel(
                        'Retype Password',
                        Icons.lock_outline_rounded,
                        textPrimary,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: _buildInputDecoration(
                          'Retype password',
                          bgBody,
                          primaryPurple,
                          textMuted,
                        ),
                        obscureText: true,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: textPrimary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: textMuted,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: primaryPurple
                                    .withOpacity(0.5),
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
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create User Account',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textPrimary.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    Color bgBody,
    Color primaryPurple,
    Color textMuted,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: textMuted.withOpacity(0.6),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: bgBody,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

