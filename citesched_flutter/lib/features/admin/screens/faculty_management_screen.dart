import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'faculty_details_screen.dart';
import 'package:citesched_flutter/core/providers/conflict_provider.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';
import 'package:citesched_flutter/core/providers/schedule_sync_provider.dart';

import 'package:citesched_flutter/core/providers/admin_providers.dart';

// Helper extension for conflicts (already in core/providers/conflict_provider.dart)

class FacultyManagementScreen extends ConsumerStatefulWidget {
  const FacultyManagementScreen({super.key});

  @override
  ConsumerState<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends ConsumerState<FacultyManagementScreen> {
  String _searchQuery = '';
  Program? _selectedProgram;
  bool _isShowingArchived = false;
  final TextEditingController _searchController = TextEditingController();

  // Color scheme matching admin sidebar
  final Color maroonColor = const Color(0xFF720045);
  final Color innerMenuBg = const Color(0xFF7b004f);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddFacultyModal() {
    debugPrint('Opening Add Faculty Modal...');
    showDialog(
      context: context,
      builder: (context) => _AddFacultyModal(
        maroonColor: maroonColor,
        onSuccess: () {
          debugPrint('Add Faculty Success!');
          notifyScheduleDataChanged(ref);
          ref.invalidate(facultyListProvider);
        },
      ),
    );
  }

  void _showEditFacultyModal(Faculty faculty) {
    debugPrint('Opening Edit Faculty Modal for: ${faculty.name}');
    showDialog(
      context: context,
      builder: (context) => _EditFacultyModal(
        faculty: faculty,
        maroonColor: maroonColor,
        onSuccess: () {
          debugPrint('Edit Faculty Success!');
          notifyScheduleDataChanged(ref);
          ref.invalidate(facultyListProvider);
        },
      ),
    );
  }

  void _archiveFaculty(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Archive Faculty',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to archive ${faculty.name}? They will be hidden from active lists.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
        final archivedFaculty = faculty.copyWith(isActive: false);
        await client.admin.updateFaculty(archivedFaculty);
        ref.invalidate(facultyListProvider);
        ref.invalidate(archivedFacultyListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty archived successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error archiving faculty: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _restoreFaculty(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Restore Faculty',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to restore ${faculty.name}? They will reappear in active lists.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Restore', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final restoredFaculty = faculty.copyWith(isActive: true);
        await client.admin.updateFaculty(restoredFaculty);
        ref.invalidate(facultyListProvider);
        ref.invalidate(archivedFacultyListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty restored successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error restoring faculty: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _permanentDeleteFaculty(Faculty faculty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Permanent Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to PERMANENTLY delete ${faculty.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete Permanently', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await client.admin.deleteFaculty(faculty.id!);
        ref.invalidate(facultyListProvider);
        ref.invalidate(archivedFacultyListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty permanently deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting faculty: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildViewToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Active', false, isDark),
          _buildToggleOption('Archived', true, isDark),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isArchived, bool isDark) {
    final isSelected = _isShowingArchived == isArchived;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isShowingArchived = isArchived;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? maroonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: maroonColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = _isShowingArchived
        ? ref.watch(archivedFacultyListProvider)
        : ref.watch(facultyListProvider);
    final conflictsAsync = ref.watch(allConflictsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const bgColor = Colors.white;

    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Header (Standardized Maroon Gradient Banner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    maroonColor,
                    const Color(0xFF8e005b),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: maroonColor.withValues(alpha: 0.3),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faculty Management',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage instructors, workloads, and schedules',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12 : 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddFacultyModal,
                    icon: const Icon(Icons.person_add_rounded, size: 24),
                    label: Text(
                      isMobile ? 'Add' : 'Add Faculty Member',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: maroonColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 28,
                        vertical: isMobile ? 12 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Search and Filter Row
            isMobile
                ? Column(
                    children: [
                      _buildViewToggle(isDark),
                      const SizedBox(height: 16),
                      _buildSearchBar(isDark),
                      const SizedBox(height: 16),
                      _buildProgramFilter(facultyAsync, isDark),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildSearchBar(isDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildProgramFilter(facultyAsync, isDark),
                      ),
                      const SizedBox(width: 16),
                      _buildViewToggle(isDark),
                    ],
                  ),
            const SizedBox(height: 32),

            // Faculty Table
            Expanded(
              child: facultyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading faculty',
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(facultyListProvider),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (facultyList) {
                  final filteredFaculty = facultyList.where((faculty) {
                    // Search filter
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        faculty.name.toLowerCase().contains(_searchQuery) ||
                        faculty.email.toLowerCase().contains(_searchQuery) ||
                        (faculty.facultyId.toLowerCase().contains(
                          _searchQuery,
                        ));

                    // Program filter
                    final matchesProgram =
                        _selectedProgram == null ||
                        faculty.program == _selectedProgram;

                    return matchesSearch && matchesProgram;
                  }).toList();

                  if (filteredFaculty.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No faculty members yet'
                                : 'No faculty found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Click "Add Faculty" to get started',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  if (isMobile) {
                    return _buildMobileFacultyList(filteredFaculty, isDark);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(color: maroonColor, width: 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: maroonColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_rounded,
                                color: maroonColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Faculty Members',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: maroonColor,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: maroonColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filteredFaculty.length} Total',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Content
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        maroonColor,
                                      ),
                                      headingTextStyle: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                      dataRowMinHeight: 65,
                                      dataRowMaxHeight: 85,
                                      columnSpacing: 32,
                                      horizontalMargin: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('FACULTY ID')),
                                        DataColumn(label: Text('NAME')),
                                        DataColumn(label: Text('EMAIL')),
                                        DataColumn(label: Text('PROGRAM')),
                                        DataColumn(label: Text('STATUS')),
                                        DataColumn(label: Text('CONFLICTS')),
                                        DataColumn(label: Text('SHIFT')),
                                        DataColumn(label: Text('MAX LOAD')),
                                        DataColumn(label: Text('ACTIONS')),
                                      ],
                                      rows: filteredFaculty.asMap().entries.map((
                                        entry,
                                      ) {
                                        final faculty = entry.value;
                                        final index = entry.key;

                                        return DataRow(
                                          onSelectChanged: (selected) {
                                            if (selected == true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FacultyDetailsScreen(
                                                        faculty: faculty,
                                                      ),
                                                ),
                                              );
                                            }
                                          },
                                          color:
                                              WidgetStateProperty.resolveWith<
                                                Color?
                                              >(
                                                (states) {
                                                  if (states.contains(
                                                    WidgetState.hovered,
                                                  )) {
                                                    return maroonColor
                                                        .withOpacity(
                                                          0.05,
                                                        );
                                                  }
                                                  return index.isEven
                                                      ? (isDark
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.02,
                                                                  )
                                                            : Colors.grey
                                                                  .withOpacity(
                                                                    0.02,
                                                                  ))
                                                      : null;
                                                },
                                              ),
                                          cells: [
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: maroonColor
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8,
                                                      ),
                                                ),
                                                child: Text(
                                                  faculty.facultyId,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: maroonColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              conflictsAsync.when(
                                                loading: () => Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: maroonColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          faculty
                                                                  .name
                                                                  .isNotEmpty
                                                              ? faculty.name[0]
                                                                    .toUpperCase()
                                                              : '?',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      faculty.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                error: (_, __) => Text(
                                                  faculty.name,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                data: (conflicts) {
                                                  final hasNameConflict =
                                                      conflicts
                                                          .hasConflictForFaculty(
                                                            faculty.id!,
                                                          );
                                                  return Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: maroonColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            faculty
                                                                    .name
                                                                    .isNotEmpty
                                                                ? faculty
                                                                      .name[0]
                                                                      .toUpperCase()
                                                                : '?',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        faculty.name,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                      if (hasNameConflict) ...[
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Icon(
                                                          Icons.warning_rounded,
                                                          color: Colors.red,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email_outlined,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    faculty.email,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                (faculty.program?.name ?? '�')
                                                    .toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 7,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ).withOpacity(0.7),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _getStatusColor(
                                                        faculty
                                                            .employmentStatus,
                                                      ).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getStatusIcon(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _getStatusText(
                                                        faculty
                                                            .employmentStatus,
                                                      ),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              conflictsAsync.when(
                                                loading: () => const SizedBox(),
                                                error: (_, __) =>
                                                    const SizedBox(),
                                                data: (conflicts) {
                                                  final hasConflict = conflicts
                                                      .hasConflictForFaculty(
                                                        faculty.id!,
                                                      );
                                                  final conflictCount = conflicts
                                                      .where(
                                                        (c) =>
                                                            c.facultyId ==
                                                                faculty.id ||
                                                            c.conflictingScheduleId ==
                                                                faculty.id,
                                                      )
                                                      .length;
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: hasConflict
                                                          ? Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                          : Colors.green
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: hasConflict
                                                            ? Colors.red
                                                                  .withOpacity(
                                                                    0.3,
                                                                  )
                                                            : Colors.green
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (hasConflict) ...[
                                                          const Icon(
                                                            Icons
                                                                .warning_rounded,
                                                            color: Colors.red,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                        ],
                                                        Text(
                                                          hasConflict
                                                              ? '$conflictCount conflicts'
                                                              : 'No conflicts',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    hasConflict
                                                                    ? Colors.red
                                                                    : Colors
                                                                          .grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getShiftColor(
                                                    faculty.shiftPreference,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16,
                                                      ),
                                                  border: Border.all(
                                                    color: _getShiftColor(
                                                      faculty.shiftPreference,
                                                    ).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getShiftIcon(
                                                        faculty.shiftPreference,
                                                      ),
                                                      size: 14,
                                                      color: _getShiftColor(
                                                        faculty.shiftPreference,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _getShiftText(
                                                        faculty.shiftPreference,
                                                      ),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: _getShiftColor(
                                                          faculty
                                                              .shiftPreference,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    faculty.maxLoad != null
                                                        ? '${faculty.maxLoad} Units'
                                                        : '�',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (!_isShowingArchived) ...[
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        onTap: () =>
                                                            _showEditFacultyModal(
                                                              faculty,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: maroonColor
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            Icons.edit_outlined,
                                                            color: maroonColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        onTap: () =>
                                                            _archiveFaculty(
                                                              faculty,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .archive_outlined,
                                                            color:
                                                                Colors.orange,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        onTap: () =>
                                                            _restoreFaculty(
                                                              faculty,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .restore_rounded,
                                                            color: Colors.green,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        onTap: () =>
                                                            _permanentDeleteFaculty(
                                                              faculty,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .delete_forever_rounded,
                                                            color: Colors.red,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmploymentStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case EmploymentStatus.fullTime:
        return Colors.green;
      case EmploymentStatus.partTime:
        return Colors.orange;
    }
  }

  String _getStatusText(EmploymentStatus? status) {
    if (status == null) return '�';
    switch (status) {
      case EmploymentStatus.fullTime:
        return 'Full-Time';
      case EmploymentStatus.partTime:
        return 'Part-Time';
    }
  }

  IconData _getStatusIcon(EmploymentStatus? status) {
    if (status == null) return Icons.help_outline;
    switch (status) {
      case EmploymentStatus.fullTime:
        return Icons.verified;
      case EmploymentStatus.partTime:
        return Icons.schedule;
    }
  }

  Color _getShiftColor(FacultyShiftPreference? preference) {
    if (preference == null) return Colors.grey;
    switch (preference) {
      case FacultyShiftPreference.morning:
        return Colors.orange;
      case FacultyShiftPreference.afternoon:
        return Colors.blue;
      case FacultyShiftPreference.evening:
        return Colors.indigo;
      case FacultyShiftPreference.any:
        return Colors.teal;
      case FacultyShiftPreference.custom:
        return Colors.purple;
    }
  }

  String _getShiftText(FacultyShiftPreference? preference) {
    if (preference == null) return 'Any';
    switch (preference) {
      case FacultyShiftPreference.morning:
        return 'Morning';
      case FacultyShiftPreference.afternoon:
        return 'Afternoon';
      case FacultyShiftPreference.evening:
        return 'Evening';
      case FacultyShiftPreference.any:
        return 'Any';
      case FacultyShiftPreference.custom:
        return 'Custom';
    }
  }

  IconData _getShiftIcon(FacultyShiftPreference? preference) {
    if (preference == null) return Icons.access_time;
    switch (preference) {
      case FacultyShiftPreference.morning:
        return Icons.wb_sunny;
      case FacultyShiftPreference.afternoon:
        return Icons.wb_cloudy;
      case FacultyShiftPreference.evening:
        return Icons.nightlight_round;
      case FacultyShiftPreference.any:
        return Icons.all_inclusive;
      case FacultyShiftPreference.custom:
        return Icons.tune;
    }
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey[800]!
              : const Color.fromARGB(255, 0, 0, 0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: maroonColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              cursorColor: isDark ? Colors.white : Colors.black87,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                hintText: 'Search faculty...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgramFilter(
    AsyncValue<List<Faculty>> facultyAsync,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown<Program?>(
          value: _selectedProgram,
          items: [null, ...Program.values],
          onChanged: (value) {
            setState(() {
              _selectedProgram = value;
            });
          },
          itemLabel: (program) =>
              program == null ? 'ALL' : program.name.toUpperCase(),
          bgBody: isDark ? const Color(0xFF1E293B) : Colors.white,
          textPrimary: isDark ? Colors.white : Colors.black87,
          textMuted: Colors.grey,
          primaryPurple: maroonColor,
        ),
      ],
    );
  }

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color bgBody,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMobileFacultyList(List<Faculty> facultyList, bool isDark) {
    return ListView.builder(
      itemCount: facultyList.length,
      itemBuilder: (context, index) {
        final faculty = facultyList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: maroonColor.withOpacity(0.1),
              child: Text(
                faculty.name[0],
                style: GoogleFonts.poppins(
                  color: maroonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              faculty.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              (faculty.program?.name ?? '�').toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email, 'Email', faculty.email),
                    _buildDetailRow(
                      Icons.badge,
                      'ID',
                      faculty.facultyId,
                    ),
                    _buildDetailRow(
                      Icons.verified,
                      'Status',
                      _getStatusText(faculty.employmentStatus),
                      color: _getStatusColor(faculty.employmentStatus),
                    ),
                    _buildDetailRow(
                      Icons.schedule,
                      'Shift',
                      _getShiftText(faculty.shiftPreference),
                      color: _getShiftColor(faculty.shiftPreference),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!_isShowingArchived) ...[
                          TextButton.icon(
                            onPressed: () => _showEditFacultyModal(faculty),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _archiveFaculty(faculty),
                            icon: const Icon(
                              Icons.archive_outlined,
                              color: Colors.orange,
                            ),
                            label: const Text(
                              'Archive',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ] else ...[
                          TextButton.icon(
                            onPressed: () => _restoreFaculty(faculty),
                            icon: const Icon(
                              Icons.restore_rounded,
                              color: Colors.green,
                            ),
                            label: const Text(
                              'Restore',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _permanentDeleteFaculty(faculty),
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Add Faculty Modal
class _AddFacultyModal extends StatefulWidget {
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _AddFacultyModal({
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  State<_AddFacultyModal> createState() => _AddFacultyModalState();
}

class _AddFacultyModalState extends State<_AddFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _facultyIdController = TextEditingController();
  final _maxLoadController = TextEditingController();
  final _preferredHoursController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  EmploymentStatus? _employmentStatus;
  FacultyShiftPreference? _shiftPreference;
  Program? _program;
  bool _isActive = true;
  bool _isLoading = false;
  String? _customPreferredHours;

  // ─── Faculty Availability (Day Picker) ───────────────────────────────
  final List<_AvailabilityEntry> _availabilities = [];
  DayOfWeek _selectedDay = DayOfWeek.mon;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _facultyIdController.dispose();
    _maxLoadController.dispose();
    _preferredHoursController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('Submitting Add Faculty form...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Add Faculty validation failed');
      return;
    }
    // Validate nullable dropdowns
    if (_employmentStatus == null || _program == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Employment Status and Program'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final facultyId = _facultyIdController.text.trim();

      final createdAccount = await client.setup.createAccount(
        userName: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        role: 'faculty',
        facultyId: facultyId,
      );

      if (!createdAccount) {
        throw Exception('Failed to create faculty account.');
      }

      final facultyList = await client.admin.getAllFaculty(isActive: true);
      Faculty? existing;
      for (final f in facultyList) {
        if (f.email.toLowerCase() == email.toLowerCase() ||
            f.facultyId.toLowerCase() == facultyId.toLowerCase()) {
          existing = f;
          break;
        }
      }

      if (existing == null) {
        throw Exception('Faculty profile not found after account creation.');
      }

      final updated = existing.copyWith(
        name: _nameController.text.trim(),
        email: email,
        facultyId: facultyId,
        maxLoad: int.tryParse(_maxLoadController.text) ?? 0,
        employmentStatus: _employmentStatus!,
        shiftPreference: _shiftPreference,
        preferredHours: _customPreferredHours,
        program: _program!,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      final created = await client.admin.updateFaculty(updated);

      // Save faculty availability if any were added
      if (_availabilities.isNotEmpty && created.id != null) {
        final avails = _availabilities
            .map(
              (e) => FacultyAvailability(
                facultyId: created.id!,
                dayOfWeek: e.day,
                startTime:
                    '${e.start.hour.toString().padLeft(2, '0')}:${e.start.minute.toString().padLeft(2, '0')}',
                endTime:
                    '${e.end.hour.toString().padLeft(2, '0')}:${e.end.minute.toString().padLeft(2, '0')}',
                isPreferred: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();
        await client.admin.setFacultyAvailability(created.id!, avails);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty added successfully'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCustomHoursPicker() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Select Start Time',
    );

    if (startTime == null || !mounted) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 2,
        minute: startTime.minute,
      ),
      helpText: 'Select End Time',
    );

    if (endTime == null || !mounted) return;

    // Basic validation
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be later than start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _customPreferredHours =
          '${startTime.format(context)} - ${endTime.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = widget.maroonColor; // Use maroon as primaryPurple
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgBody = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF1F6);
    final textPrimary = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF333333);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 650,
        constraints: BoxConstraints(
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 750,
        ),
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
            // Header Section with Gradient
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 20 : 24,
              ),
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
              child: Row(
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
                          'Add New Faculty',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a new faculty profile in the system',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Main Body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: _buildForm(
                  context,
                  bgBody,
                  primaryPurple,
                  textPrimary,
                  textMuted,
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: primaryPurple.withOpacity(0.5),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Faculty Member',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    Color bgBody,
    Color primaryPurple,
    Color textPrimary,
    Color textMuted,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name', Icons.person_outline_rounded, textPrimary),
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              'Jerwin A. Carreon',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Email Address', Icons.email_outlined, textPrimary),
          TextFormField(
            controller: _emailController,
            decoration: _buildInputDecoration(
              'jerwin.carreon@jmc.edu.ph',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!value!.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Faculty ID', Icons.badge_rounded, textPrimary),
          TextFormField(
            controller: _facultyIdController,
            decoration: _buildInputDecoration(
              'FAC-001',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Password', Icons.lock_outline_rounded, textPrimary),
          TextFormField(
            controller: _passwordController,
            decoration: _buildInputDecoration(
              'Min 8 characters',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            obscureText: true,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value!.length < 8) return 'Min 8 chars';
              return null;
            },
          ),
          const SizedBox(height: 16),
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
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel(
            'Max Loads (hours)',
            Icons.access_time_rounded,
            textPrimary,
          ),
          TextFormField(
            controller: _maxLoadController,
            decoration: _buildInputDecoration(
              '21',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (int.tryParse(value!) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildLabel(
            'Employment Status',
            Icons.work_outline_rounded,
            textPrimary,
          ),
          _buildNullableDropdown<EmploymentStatus>(
            value: _employmentStatus,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: EmploymentStatus.values,
            onChanged: (value) => setState(() => _employmentStatus = value),
            itemLabel: (status) =>
                status == EmploymentStatus.fullTime ? 'Full-Time' : 'Part-Time',
            hint: 'Select Status',
          ),
          const SizedBox(height: 20),
          _buildLabel('Shift Preference', Icons.schedule_rounded, textPrimary),
          _buildNullableDropdown<FacultyShiftPreference>(
            value: _shiftPreference,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: FacultyShiftPreference.values,
            onChanged: (value) => setState(() => _shiftPreference = value),
            itemLabel: (pref) {
              switch (pref) {
                case FacultyShiftPreference.any:
                  return 'Any Time (Flexible)';
                case FacultyShiftPreference.morning:
                  return 'Morning (7:00 AM to 12:00 PM)';
                case FacultyShiftPreference.afternoon:
                  return 'Afternoon (1:00 PM to 6:00 PM)';
                case FacultyShiftPreference.evening:
                  return 'Evening (6:00 PM to 9:00 PM)';
                case FacultyShiftPreference.custom:
                  return 'Custom';
              }
            },
            hint: 'Select Shift',
          ),

          const SizedBox(height: 24),
          _buildDayPickerSection(primaryPurple, textPrimary, textMuted, bgBody),
          const SizedBox(height: 24),
          _buildLabel('Program Assignment', Icons.school_outlined, textPrimary),
          _buildNullableDropdown<Program>(
            value: _program,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: Program.values,
            onChanged: (value) => setState(() => _program = value),
            itemLabel: (prog) => prog.name.toUpperCase(),
            hint: 'Select Program',
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => setState(() => _isActive = !_isActive),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgBody,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: textMuted,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Is Active',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    activeColor: primaryPurple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    Color bgBody,
    Color primaryPurple,
    Color textMuted,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
      filled: true,
      fillColor: bgBody,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: BorderSide(color: primaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color bgBody,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNullableDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color bgBody,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryPurple,
    String hint = 'Select...',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: textMuted,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDayPickerSection(
    Color primaryPurple,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    const days = [
      DayOfWeek.mon,
      DayOfWeek.tue,
      DayOfWeek.wed,
      DayOfWeek.thu,
      DayOfWeek.fri,
      DayOfWeek.sat,
    ];
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 16, color: primaryPurple),
            const SizedBox(width: 6),
            Text(
              'Preferred Teaching Days & Time',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(days.length, (i) {
            final isSelected = _selectedDay == days[i];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedDay = days[i];
                _shiftPreference = FacultyShiftPreference.custom;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryPurple : Colors.white,
                  border: Border.all(
                    color: isSelected ? primaryPurple : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  dayLabels[i],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final p = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                    helpText: 'Select Start Time',
                  );
                  if (p != null) {
                    setState(() {
                      _startTime = p;
                      _shiftPreference = FacultyShiftPreference.custom;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgBody,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            _startTime.format(context),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '->',
                style: TextStyle(fontSize: 18, color: Colors.black45),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final p = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                    helpText: 'Select End Time',
                  );
                  if (p != null) {
                    setState(() {
                      _endTime = p;
                      _shiftPreference = FacultyShiftPreference.custom;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgBody,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            _endTime.format(context),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final sM = _startTime.hour * 60 + _startTime.minute;
              final eM = _endTime.hour * 60 + _endTime.minute;
              if (eM <= sM) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('End time must be after start time'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              for (final ex in _availabilities) {
                if (ex.day == _selectedDay) {
                  final es = ex.start.hour * 60 + ex.start.minute;
                  final ee = ex.end.hour * 60 + ex.end.minute;
                  if (sM < ee && es < eM) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Overlapping availability for same day'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }
              }
              setState(() {
                _availabilities.add(
                  _AvailabilityEntry(
                    day: _selectedDay,
                    start: _startTime,
                    end: _endTime,
                  ),
                );
                // Auto-set shift preference to Custom when availability is added
                _shiftPreference = FacultyShiftPreference.custom;
              });
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(
              'Add Availability',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: primaryPurple, width: 1.5),
              foregroundColor: primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_availabilities.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryPurple.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added Availability (${_availabilities.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 8),
                ..._availabilities.asMap().entries.map((e) {
                  final idx = DayOfWeek.values.indexOf(e.value.day);
                  const dl = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            idx >= 0 ? dl[idx] : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.value.start.format(context)} - ${e.value.end.format(context)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _availabilities.removeAt(e.key)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Edit Faculty Modal (similar to Add but with pre-filled data)
class _EditFacultyModal extends StatefulWidget {
  final Faculty faculty;
  final Color maroonColor;
  final VoidCallback onSuccess;

  const _EditFacultyModal({
    required this.faculty,
    required this.maroonColor,
    required this.onSuccess,
  });

  @override
  State<_EditFacultyModal> createState() => _EditFacultyModalState();
}

class _EditFacultyModalState extends State<_EditFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _facultyIdController;
  late TextEditingController _maxLoadController;
  late TextEditingController _preferredHoursController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  EmploymentStatus? _employmentStatus;
  FacultyShiftPreference? _shiftPreference;
  Program? _program;
  late bool _isActive;
  bool _isLoading = false;
  bool _isLoadingAvailability = false;
  String? _customPreferredHours;

  // Faculty Availability (Day Picker)
  final List<_AvailabilityEntry> _availabilities = [];
  DayOfWeek _selectedDay = DayOfWeek.mon;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.faculty.name);
    _emailController = TextEditingController(text: widget.faculty.email);
    _facultyIdController = TextEditingController(text: widget.faculty.facultyId);
    _maxLoadController = TextEditingController(
      text: widget.faculty.maxLoad.toString(),
    );
    _preferredHoursController = TextEditingController(
      text: widget.faculty.preferredHours ?? '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _employmentStatus = widget.faculty.employmentStatus;
    _shiftPreference = widget.faculty.shiftPreference ?? FacultyShiftPreference.any;
    _program = widget.faculty.program;
    _isActive = widget.faculty.isActive;
    _customPreferredHours = widget.faculty.preferredHours;
    _loadExistingAvailability();\r\n  }
  TimeOfDay _timeOfDayFromHHmm(String hhmm) {
    final parts = hhmm.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _loadExistingAvailability() async {
    if (widget.faculty.id == null) return;
    setState(() => _isLoadingAvailability = true);
    try {
      final existing = await client.admin.getFacultyAvailability(
        widget.faculty.id!,
      );
      if (!mounted) return;
      setState(() {
        _availabilities
          ..clear()
          ..addAll(
            existing.map(
              (a) => _AvailabilityEntry(
                day: a.dayOfWeek,
                start: _timeOfDayFromHHmm(a.startTime),
                end: _timeOfDayFromHHmm(a.endTime),
              ),
            ),
          );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAvailability = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _facultyIdController.dispose();
    _maxLoadController.dispose();
    _preferredHoursController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('Submitting Edit Faculty form...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Edit Faculty validation failed');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final updatedFaculty = Faculty(
        id: widget.faculty.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        facultyId: _facultyIdController.text.trim(),
        maxLoad: int.parse(_maxLoadController.text),
        employmentStatus: _employmentStatus,
        shiftPreference: _shiftPreference,
        preferredHours: _customPreferredHours,
        userInfoId: widget.faculty.userInfoId,
        program: _program,
        isActive: _isActive,
        createdAt: widget.faculty.createdAt,
        updatedAt: DateTime.now(),
      );

      await client.admin.updateFaculty(updatedFaculty);

      if (widget.faculty.id != null) {
        final avails = _availabilities
            .map(
              (e) => FacultyAvailability(
                facultyId: widget.faculty.id!,
                dayOfWeek: e.day,
                startTime:
                    '${e.start.hour.toString().padLeft(2, '0')}:${e.start.minute.toString().padLeft(2, '0')}',
                endTime:
                    '${e.end.hour.toString().padLeft(2, '0')}:${e.end.minute.toString().padLeft(2, '0')}',
                isPreferred: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList();
        await client.admin.setFacultyAvailability(widget.faculty.id!, avails);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCustomHoursPicker() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Select Start Time',
    );

    if (startTime == null || !mounted) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startTime.hour + 2,
        minute: startTime.minute,
      ),
      helpText: 'Select End Time',
    );

    if (endTime == null || !mounted) return;

    // Basic validation
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be later than start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _customPreferredHours =
          '${startTime.format(context)} - ${endTime.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryPurple = widget.maroonColor;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgBody = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF1F6);
    final textPrimary = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF333333);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 650,
        constraints: BoxConstraints(
          maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.9 : 750,
        ),
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
            // Header Section with Gradient
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 28,
                vertical: isMobile ? 20 : 24,
              ),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
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
                          'Edit Faculty Profile',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update information for ${widget.faculty.name}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Main Body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: _buildForm(
                  context,
                  bgBody,
                  primaryPurple,
                  textPrimary,
                  textMuted,
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(
                  top: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: primaryPurple.withOpacity(0.5),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Save Changes',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    Color bgBody,
    Color primaryPurple,
    Color textPrimary,
    Color textMuted,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name', Icons.person_outline_rounded, textPrimary),
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              'Jerwin A. Carreon',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Email Address', Icons.email_outlined, textPrimary),
          TextFormField(
            controller: _emailController,
            decoration: _buildInputDecoration(
              'jerwin.carreon@jmc.edu.ph',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!value!.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Faculty ID', Icons.badge_rounded, textPrimary),
          TextFormField(
            controller: _facultyIdController,
            decoration: _buildInputDecoration(
              'FAC-001',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Password', Icons.lock_outline_rounded, textPrimary),
          TextFormField(
            controller: _passwordController,
            decoration: _buildInputDecoration(
              'Min 8 characters',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            obscureText: true,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value!.length < 8) return 'Min 8 chars';
              return null;
            },
          ),
          const SizedBox(height: 16),
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
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel(
            'Max Loads (hours)',
            Icons.access_time_rounded,
            textPrimary,
          ),
          TextFormField(
            controller: _maxLoadController,
            decoration: _buildInputDecoration(
              '21',
              bgBody,
              primaryPurple,
              textMuted,
            ),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 15, color: textPrimary),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (int.tryParse(value!) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildLabel(
            'Employment Status',
            Icons.work_outline_rounded,
            textPrimary,
          ),
          _buildDropdown<EmploymentStatus>(
            value: _employmentStatus,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: EmploymentStatus.values,
            onChanged: (value) => setState(() => _employmentStatus = value!),
            itemLabel: (status) =>
                status == EmploymentStatus.fullTime ? 'Full-Time' : 'Part-Time',
          ),

          const SizedBox(height: 20),
          _buildLabel('Shift Preference', Icons.schedule_rounded, textPrimary),
          _buildDropdown<FacultyShiftPreference>(
            value: _shiftPreference,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: FacultyShiftPreference.values,
            onChanged: (value) => setState(() => _shiftPreference = value),
            itemLabel: (pref) {
              switch (pref) {
                case FacultyShiftPreference.any:
                  return 'Any Time (Flexible)';
                case FacultyShiftPreference.morning:
                  return 'Morning (7:00 AM to 12:00 PM)';
                case FacultyShiftPreference.afternoon:
                  return 'Afternoon (1:00 PM to 6:00 PM)';
                case FacultyShiftPreference.evening:
                  return 'Evening (6:00 PM to 9:00 PM)';
                case FacultyShiftPreference.custom:
                  return 'Custom';
              }
            },
          ),

          const SizedBox(height: 24),
          if (_isLoadingAvailability)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildDayPickerSection(
              primaryPurple,
              textPrimary,
              textMuted,
              bgBody,
            ),

          const SizedBox(height: 24),
          _buildLabel('Program Assignment', Icons.school_outlined, textPrimary),
          _buildDropdown<Program>(
            value: _program,
            bgBody: bgBody,
            textPrimary: textPrimary,
            textMuted: textMuted,
            primaryPurple: primaryPurple,
            items: Program.values,
            onChanged: (value) => setState(() => _program = value!),
            itemLabel: (prog) => prog.name.toUpperCase(),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => setState(() => _isActive = !_isActive),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgBody,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: textMuted,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Is Active',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    activeColor: primaryPurple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    Color bgBody,
    Color primaryPurple,
    Color textMuted,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
      filled: true,
      fillColor: bgBody,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: BorderSide(color: primaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color bgBody,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryPurple,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgBody,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textMuted),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Day Picker Section ──────────────────────────────────────────
  Widget _buildDayPickerSection(
    Color primaryPurple,
    Color textPrimary,
    Color textMuted,
    Color bgBody,
  ) {
    const days = [
      DayOfWeek.mon,
      DayOfWeek.tue,
      DayOfWeek.wed,
      DayOfWeek.thu,
      DayOfWeek.fri,
      DayOfWeek.sat,
    ];
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 16, color: primaryPurple),
            const SizedBox(width: 6),
            Text(
              'Preferred Teaching Days & Time',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Day toggle chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(days.length, (i) {
            final day = days[i];
            final isSelected = _selectedDay == day;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedDay = day;
                _shiftPreference = FacultyShiftPreference.custom;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryPurple : Colors.white,
                  border: Border.all(
                    color: isSelected ? primaryPurple : Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  dayLabels[i],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        // Start / End time row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                    helpText: 'Select Start Time',
                  );
                  if (picked != null) {
                    setState(() {
                      _startTime = picked;
                      _shiftPreference = FacultyShiftPreference.custom;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgBody,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            _startTime.format(context),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '->',
                style: TextStyle(fontSize: 18, color: Colors.black45),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                    helpText: 'Select End Time',
                  );
                  if (picked != null) {
                    setState(() {
                      _endTime = picked;
                      _shiftPreference = FacultyShiftPreference.custom;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgBody,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: primaryPurple,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            _endTime.format(context),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
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
        const SizedBox(height: 12),
        // Add button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final startMins = _startTime.hour * 60 + _startTime.minute;
              final endMins = _endTime.hour * 60 + _endTime.minute;
              if (endMins <= startMins) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('End time must be after start time'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Check duplicate day/time overlap
              for (final existing in _availabilities) {
                if (existing.day == _selectedDay) {
                  final eStart =
                      existing.start.hour * 60 + existing.start.minute;
                  final eEnd = existing.end.hour * 60 + existing.end.minute;
                  if (startMins < eEnd && eStart < endMins) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Overlapping availability for same day'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }
              }
              setState(() {
                _availabilities.add(
                  _AvailabilityEntry(
                    day: _selectedDay,
                    start: _startTime,
                    end: _endTime,
                  ),
                );
                // Auto-set shift preference to Custom when availability is added
                _shiftPreference = FacultyShiftPreference.custom;
              });
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(
              'Add Availability',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: primaryPurple, width: 1.5),
              foregroundColor: primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_availabilities.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryPurple.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added Availability (${_availabilities.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 8),
                ..._availabilities.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  const dayLabels2 = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  final dayIdx = DayOfWeek.values.indexOf(e.day);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dayIdx >= 0 ? dayLabels2[dayIdx] : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.start.format(context)} - ${e.end.format(context)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _availabilities.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Simple data class to hold a faculty availability entry in the UI before saving.
class _AvailabilityEntry {
  final DayOfWeek day;
  final TimeOfDay start;
  final TimeOfDay end;

  const _AvailabilityEntry({
    required this.day,
    required this.start,
    required this.end,
  });
}
