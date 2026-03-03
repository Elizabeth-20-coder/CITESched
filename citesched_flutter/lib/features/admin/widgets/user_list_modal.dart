import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/features/admin/widgets/admin_create_user_form.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/core/providers/admin_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListModal extends ConsumerStatefulWidget {
  const UserListModal({super.key});

  @override
  ConsumerState<UserListModal> createState() => _UserListModalState();
}

class _UserListModalState extends ConsumerState<UserListModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Faculty> _faculty = [];
  List<Student> _students = [];
  List<UserRole> _userRoles = [];
  bool _isLoading = true;

  void _archiveFaculty(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Archive Faculty',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to archive "${faculty.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Archive', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final toArchive = faculty.copyWith(isActive: false);
        await client.admin.updateFaculty(toArchive);
        _fetchData();
        // Invalidate section providers for immediate reflection in Faculty Loading
        ref.invalidate(sectionListProvider);
        ref.invalidate(studentSectionsProvider);
        ref.invalidate(facultyListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty archived successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError('Error archiving faculty: $e');
      }
    }
  }

  // Filter states
  bool _isShowingArchivedFaculty = false;
  bool _isShowingArchivedStudents = false;
  String _facultyFilter = 'all';
  String _studentSortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final faculty = await client.admin.getAllFaculty(
        isActive: !_isShowingArchivedFaculty,
      );
      final students = await client.admin.getAllStudents(
        isActive: !_isShowingArchivedStudents,
      );
      final roles = await client.admin.getAllUserRoles();
      if (mounted) {
        setState(() {
          _faculty = faculty;
          _students = students;
          _userRoles = roles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')),
        );
      }
    }
  }

  List<Faculty> get _filteredFaculty {
    if (_facultyFilter == 'all') return _faculty;

    return _faculty.where((f) {
      final roleEntry = _userRoles.firstWhere(
        (r) => r.userId == f.userInfoId.toString(),
        orElse: () => UserRole(userId: '', role: 'faculty'),
      );
      return roleEntry.role == _facultyFilter;
    }).toList();
  }

  List<Student> get _sortedStudents {
    final sorted = List<Student>.from(_students);
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _studentSortOrder == 'asc' ? comparison : -comparison;
    });
    return sorted;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Student CRUD ────────────────────────────────────────────────────────

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (_) => AdminCreateUserForm(
        onSuccess: () {
          _fetchData();
          ref.invalidate(sectionListProvider);
          ref.invalidate(studentSectionsProvider);
          ref.invalidate(facultyListProvider);
          ref.invalidate(studentsProvider);
        },
        initialRole: 'student',
      ),
    );
  }

  void _showEditStudentDialog(Student student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditStudentDialog(
        student: student,
        onSuccess: () {
          _fetchData();
          ref.invalidate(sectionListProvider);
          ref.invalidate(studentSectionsProvider);
          ref.invalidate(studentsProvider);
        },
      ),
    );
  }

  void _archiveStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Archive Student',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to archive "${student.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Archive', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final toArchive = student.copyWith(isActive: false);
        await client.admin.updateStudent(toArchive);
        _fetchData();
        ref.invalidate(sectionListProvider);
        ref.invalidate(studentSectionsProvider);
        ref.invalidate(studentsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student archived successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError('Error archiving student: $e');
      }
    }
  }

  void _restoreStudent(Student student) async {
    try {
      final restored = student.copyWith(isActive: true);
      await client.admin.updateStudent(restored);
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error restoring student: $e');
    }
  }

  void _deleteStudentPermanently(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Permanently',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to PERMANENTLY delete "${student.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
        await client.admin.deleteStudent(student.id!);
        _fetchData();
        if (mounted) {
          // Refresh section- and student-dependent views (e.g., Faculty Loading dropdowns)
          ref.invalidate(sectionListProvider);
          ref.invalidate(studentSectionsProvider);
          ref.invalidate(studentsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student deleted permanently'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError('Error deleting student: $e');
      }
    }
  }

  void _restoreFaculty(Faculty faculty) async {
    try {
      final restored = faculty.copyWith(isActive: true);
      await client.admin.updateFaculty(restored);
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error restoring faculty: $e');
    }
  }

  void _deleteFacultyPermanently(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Permanently',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to PERMANENTLY delete "${faculty.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
        await client.admin.deleteFaculty(faculty.id!);
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty deleted permanently'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError('Error deleting faculty: $e');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 40,
      ),
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 900,
        height: isMobile ? screenHeight * 0.9 : 700,
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
          children: [
            // Header (Standardized Maroon Gradient Banner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPurple,
                    const Color(0xFF8e005b),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Management',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage system users and permissions',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12 : 16,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _showAddStudentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryPurple,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 20,
                            vertical: isMobile ? 10 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add_rounded, size: 20),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Add Student',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: cardBg,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: bgBody,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: textMuted,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: [
                    Tab(text: isMobile ? 'Staff' : 'Faculty & Admin'),
                    Tab(text: 'Students'),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: primaryPurple,
                        strokeWidth: 3,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFacultyList(
                          primaryPurple,
                          textPrimary,
                          textMuted,
                          bgBody,
                        ),
                        _buildStudentList(
                          primaryPurple,
                          textPrimary,
                          textMuted,
                          bgBody,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Faculty Tab (read-only) ─────────────────────────────────────────────

  Widget _buildFacultyList(
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 28,
            vertical: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Role:',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildFilterChip('All', 'all', primaryColor, textPrimary),
                    _buildFilterChip(
                      'Faculty',
                      'faculty',
                      primaryColor,
                      textPrimary,
                    ),
                    _buildFilterChip(
                      'Admin',
                      'admin',
                      primaryColor,
                      textPrimary,
                    ),
                  ],
                ),
              ),
              _buildArchiveToggle(
                _isShowingArchivedFaculty,
                (v) => setState(() {
                  _isShowingArchivedFaculty = v;
                  _fetchData();
                }),
                primaryColor,
                textMuted,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredFaculty.isEmpty
              ? _buildEmptyState(
                  'No faculty members found',
                  Icons.people_outline_rounded,
                  textMuted,
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  itemCount: _filteredFaculty.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final f = _filteredFaculty[index];
                    return _buildFacultyCard(
                      f,
                      primaryColor,
                      textPrimary,
                      textMuted,
                      bgBody,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── Students Tab (with CRUD) ────────────────────────────────────────────

  Widget _buildStudentList(
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        // Sort + Count bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 28,
            vertical: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_by_alpha_rounded,
                          color: textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sort:',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildSortChip('A → Z', 'asc', primaryColor, textPrimary),
                    _buildSortChip('Z → A', 'desc', primaryColor, textPrimary),
                  ],
                ),
              ),
              _buildArchiveToggle(
                _isShowingArchivedStudents,
                (v) => setState(() {
                  _isShowingArchivedStudents = v;
                  _fetchData();
                }),
                primaryColor,
                textMuted,
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Text(
                  '${_sortedStudents.length} students',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _sortedStudents.isEmpty
              ? _buildEmptyState(
                  'No students found',
                  Icons.school_outlined,
                  textMuted,
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  itemCount: _sortedStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = _sortedStudents[index];
                    return _buildStudentCard(
                      s,
                      primaryColor,
                      textPrimary,
                      textMuted,
                      bgBody,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── Cards ───────────────────────────────────────────────────────────────

  Widget _buildFacultyCard(
    Faculty f,
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, const Color(0xFFb5179e)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      f.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRoleBadge(f),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              (f.program?.name ?? '—').toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          if (!_isShowingArchivedFaculty) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _archiveFaculty(f),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ] else ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _restoreFaculty(f),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_backup_restore_rounded,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _deleteFacultyPermanently(f),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(Faculty f) {
    final roleEntry = _userRoles.firstWhere(
      (r) => r.userId == f.userInfoId.toString(),
      orElse: () => UserRole(userId: '', role: 'faculty'),
    );
    final isAdmin = roleEntry.role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.red.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAdmin
              ? Colors.red.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'FACULTY',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.red : Colors.blue,
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    Student s,
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    const green = Color(0xFF2e7d32);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [green, Color(0xFF4caf50)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${s.studentNumber} • ${s.email}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'STUDENT',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if (s.section != null && s.section!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Section: ${s.section}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Course badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: green.withOpacity(0.3)),
            ),
            child: Text(
              s.course,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Edit/Restore Actions
          if (!_isShowingArchivedStudents) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showEditStudentDialog(s),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _archiveStudent(s),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ] else ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _restoreStudent(s),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_backup_restore_rounded,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _deleteStudentPermanently(s),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildArchiveToggle(
    bool value,
    ValueChanged<bool> onChanged,
    Color primaryColor,
    Color textMuted,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value ? 'Archived' : 'Active',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value ? Colors.orange : textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
          activeTrackColor: Colors.orange.withOpacity(0.2),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade200,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    Color primaryColor,
    Color textPrimary,
  ) {
    final isSelected = _facultyFilter == value;
    return InkWell(
      onTap: () => setState(() => _facultyFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : textPrimary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    Color primaryColor,
    Color textPrimary,
  ) {
    final isSelected = _studentSortOrder == value;
    return InkWell(
      onTap: () => setState(() => _studentSortOrder = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : textPrimary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color textMuted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 16, color: textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Edit Student Dialog ───────────────────────────────────────────────────────

class _EditStudentDialog extends StatefulWidget {
  final Student student;
  final VoidCallback onSuccess;

  const _EditStudentDialog({
    required this.student,
    required this.onSuccess,
  });

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _courseCtrl;
  late final TextEditingController _sectionCtrl;
  late final TextEditingController _numberCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.student.name);
    _emailCtrl = TextEditingController(text: widget.student.email);
    _courseCtrl = TextEditingController(text: widget.student.course);
    _sectionCtrl = TextEditingController(text: widget.student.section ?? '');
    _numberCtrl = TextEditingController(text: widget.student.studentNumber);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _courseCtrl.dispose();
    _sectionCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updated = widget.student.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        course: _courseCtrl.text.trim(),
        section: _sectionCtrl.text.trim().isEmpty
            ? null
            : _sectionCtrl.text.trim(),
        studentNumber: _numberCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );
      await client.admin.updateStudent(updated);
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student updated successfully'),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maroon = isDark ? const Color(0xFFa21caf) : const Color(0xFF720045);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgBody = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF1F6);
    final textPrimary = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF333333);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);

    InputDecoration field(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: textMuted.withOpacity(0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: maroon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: bgBody,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: maroon, width: 2),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [maroon, const Color(0xFFb5179e)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Edit Student',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: field(
                          'Full Name',
                          Icons.person_outline_rounded,
                        ),
                        style: GoogleFonts.poppins(color: textPrimary),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _numberCtrl,
                        decoration: field(
                          'Student Number',
                          Icons.badge_rounded,
                        ),
                        style: GoogleFonts.poppins(color: textPrimary),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: field('Email', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(color: textPrimary),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _courseCtrl,
                        decoration: field('Course', Icons.school_rounded),
                        style: GoogleFonts.poppins(color: textPrimary),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _sectionCtrl,
                        decoration: field(
                          'Section (optional)',
                          Icons.group_rounded,
                        ),
                        style: GoogleFonts.poppins(color: textPrimary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: textMuted,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
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
                                backgroundColor: maroon,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.save_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Save Changes',
                                          style: GoogleFonts.poppins(
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
}
