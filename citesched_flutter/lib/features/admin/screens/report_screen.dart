import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citesched_flutter/core/providers/admin_providers.dart';
import 'package:citesched_flutter/features/admin/utils/pdf_generator.dart';

// REAR-TIME REPORT PROVIDERS
final facultyLoadReportProvider = FutureProvider<List<FacultyLoadReport>>((
  ref,
) async {
  ref.watch(schedulesProvider);
  return await client.admin.getFacultyLoadReport();
});

final roomUtilizationReportProvider =
    FutureProvider<List<RoomUtilizationReport>>((ref) async {
      ref.watch(schedulesProvider);
      return await client.admin.getRoomUtilizationReport();
    });

final conflictSummaryReportProvider = FutureProvider<List<ScheduleConflict>>((
  ref,
) async {
  ref.watch(schedulesProvider);
  return await client.admin.getAllConflicts();
});

final scheduleOverviewReportProvider = FutureProvider<ScheduleOverviewReport>((
  ref,
) async {
  ref.watch(schedulesProvider);
  return await client.admin.getScheduleOverviewReport();
});

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final maroonColor = const Color(0xFF720045);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
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
                colors: [maroonColor, const Color(0xFF8e005b)],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
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
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytical Reports',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 22 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comprehensive system metrics and utilization analysis',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12 : 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
                if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AY 2025-2026',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Tab Selector
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: isMobile,
              labelColor: maroonColor,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: maroonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: maroonColor.withValues(alpha: 0.2),
                ),
              ),
              indicatorColor: maroonColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
              tabs: const [
                Tab(text: 'Faculty Load'),
                Tab(text: 'Room Usage'),
                Tab(text: 'Conflicts'),
                Tab(text: 'Schedule Stats'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _FacultyLoadTab(),
                  _RoomUtilizationTab(),
                  _ConflictSummaryTab(),
                  _ScheduleOverviewTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _FacultyLoadTab extends ConsumerWidget {
  const _FacultyLoadTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(facultyLoadReportProvider);
    final schedulesAsync = ref.watch(schedulesProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        const maroonColor = Color(0xFF720045);
        final headerBg = isDark
            ? maroonColor.withOpacity(0.22)
            : maroonColor.withOpacity(0.08);
        final rowBgA = isDark ? const Color(0xFF0F172A) : Colors.white;
        final rowBgB =
            isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
        final dividerColor = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06);

        return Card(
          color: cardBg,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined, color: const Color(0xFF720045)),
                    const SizedBox(width: 12),
                    Text(
                      'Faculty Teaching Load Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Export All',
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'pdf',
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text('Export All as PDF'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'docx',
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_rounded,
                                color: Colors.blue,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text('Export All as Word (.docx)'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'pdf') {
                          await PdfGenerator.printAllSummaryAsPdf(data);
                        } else {
                          final path =
                              await PdfGenerator.exportAllSummaryAsDocx(data);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  path != null
                                      ? 'Saved to: $path'
                                      : 'Export not supported on this platform.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: Text(
                          'Export All',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF720045),
                          side: const BorderSide(color: Color(0xFF720045)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 28,
                                horizontalMargin: 16,
                                headingRowHeight: 44,
                                dataRowMinHeight: 52,
                                dataRowMaxHeight: 60,
                                showBottomBorder: true,
                                dividerThickness: 0.6,
                                headingRowColor:
                                    MaterialStateProperty.all(headerBg),
                                headingTextStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.grey[700],
                                  letterSpacing: 0.8,
                                ),
                                dataTextStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black87,
                                ),
                                border: TableBorder(
                                  horizontalInside:
                                      BorderSide(color: dividerColor),
                                  bottom: BorderSide(color: dividerColor),
                                  top: BorderSide(color: dividerColor),
                                ),
                                rows: data.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                Color statusColor;
                                if (item.loadStatus == 'Overloaded')
                                  statusColor = Colors.red;
                                else if (item.loadStatus == 'Underloaded')
                                  statusColor = Colors.orange;
                                else
                                  statusColor = Colors.green;

                                return DataRow(
                                  color: MaterialStateProperty.all(
                                    index.isEven ? rowBgA : rowBgB,
                                  ),
                                  cells: [
                                    DataCell(
                                      Text(
                                        item.facultyName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (item.program ?? '-').toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${item.totalUnits.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: maroonColor,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${item.totalHours.toStringAsFixed(1)} hrs',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${item.totalSubjects}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: statusColor.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          item.loadStatus.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Tooltip(
                                            message: 'Export as PDF',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.picture_as_pdf_rounded,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                final schedules =
                                                    schedulesAsync.value ?? [];
                                                PdfGenerator.printFacultySummaryAsPdf(
                                                  item,
                                                  schedules,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Tooltip(
                                            message: 'Export as Word (.docx)',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.description_rounded,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                final schedules =
                                                    schedulesAsync.value ?? [];
                                                final path =
                                                    await PdfGenerator.exportFacultySummaryAsDocx(
                                                      item,
                                                      schedules,
                                                    );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        path != null
                                                            ? 'Saved to: $path'
                                                            : 'Export not supported on this platform.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                                columns: const [
                                  DataColumn(label: Text('FACULTY')),
                                  DataColumn(label: Text('PROGRAM')),
                                  DataColumn(
                                    label: Text('TOTAL UNITS'),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text('TOTAL HOURS'),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text('SUBJECTS'),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text('STATUS')),
                                  DataColumn(label: Text('EXPORT')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Local PDF dialogs removed in favor of PdfGenerator
}

class _RoomUtilizationTab extends ConsumerWidget {
  const _RoomUtilizationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(roomUtilizationReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width < 650 ? 1 : (width < 1000 ? 2 : 3);
            final childAspectRatio = width < 650 ? 1.6 : 1.4;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final color = item.utilizationPercentage > 80
                    ? Colors.red
                    : (item.utilizationPercentage > 50
                          ? Colors.orange
                          : Colors.green);

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: color.withOpacity(0.2), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.roomName,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.meeting_room_rounded, color: color),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Utilization',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                              Text(
                                '${item.utilizationPercentage.toStringAsFixed(1)}%',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: item.utilizationPercentage / 100,
                              backgroundColor: color.withOpacity(0.1),
                              color: color,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${item.totalBookings} timeslots assigned',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ConflictSummaryTab extends ConsumerWidget {
  const _ConflictSummaryTab();

  static const _typeConfig = <String, _ReportConflictConfig>{
    'room_conflict': _ReportConflictConfig(
      label: 'ROOM CONFLICT',
      icon: Icons.meeting_room_rounded,
      color: Colors.red,
    ),
    'faculty_conflict': _ReportConflictConfig(
      label: 'FACULTY CONFLICT',
      icon: Icons.person_off_rounded,
      color: Colors.deepOrange,
    ),
    'section_conflict': _ReportConflictConfig(
      label: 'SECTION CONFLICT',
      icon: Icons.groups_rounded,
      color: Colors.purple,
    ),
    'program_mismatch': _ReportConflictConfig(
      label: 'PROGRAM MISMATCH',
      icon: Icons.compare_arrows_rounded,
      color: Colors.amber,
    ),
    'capacity_exceeded': _ReportConflictConfig(
      label: 'CAPACITY EXCEEDED',
      icon: Icons.group_add_rounded,
      color: Colors.orange,
    ),
    'max_load_exceeded': _ReportConflictConfig(
      label: 'MAX LOAD EXCEEDED',
      icon: Icons.warning_amber_rounded,
      color: Colors.brown,
    ),
    'room_inactive': _ReportConflictConfig(
      label: 'ROOM INACTIVE',
      icon: Icons.block_rounded,
      color: Colors.grey,
    ),
    'faculty_unavailable': _ReportConflictConfig(
      label: 'FACULTY UNAVAILABLE',
      icon: Icons.event_busy_rounded,
      color: Colors.indigo,
    ),
    'generation_failed': _ReportConflictConfig(
      label: 'GENERATION FAILED',
      icon: Icons.error_outline_rounded,
      color: Colors.red,
    ),
  };

  _ReportConflictConfig _cfg(String type) =>
      _typeConfig[type] ??
      const _ReportConflictConfig(
        label: 'UNKNOWN',
        icon: Icons.help_outline_rounded,
        color: Colors.grey,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(conflictSummaryReportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (conflicts) {
        return Card(
          color: cardBg,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: conflicts.isEmpty
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        conflicts.isEmpty
                            ? Icons.verified_rounded
                            : Icons.warning_rounded,
                        color: conflicts.isEmpty ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conflict Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          conflicts.isEmpty
                              ? 'No conflicts detected — system is clean'
                              : '${conflicts.length} conflict${conflicts.length == 1 ? '' : 's'} require attention',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: conflicts.isEmpty
                                ? Colors.green
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    ),
                    if (conflicts.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          _buildCountBadge(conflicts, 'CRITICAL', [
                            'room_conflict',
                            'faculty_conflict',
                            'section_conflict',
                          ], Colors.red),
                          _buildCountBadge(conflicts, 'WARNING', [
                            'max_load_exceeded',
                            'room_inactive',
                            'faculty_unavailable',
                            'program_mismatch',
                            'capacity_exceeded',
                          ], Colors.orange),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // ── Conflict List or Empty State ─────────────────────
                if (conflicts.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 64,
                              color: Colors.green.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'All Clear!',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No scheduling conflicts found. The timetable is valid.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: conflicts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final conflict = conflicts[index];
                        final cfg = _cfg(conflict.type);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? cfg.color.withOpacity(0.08)
                                : cfg.color.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cfg.color.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Warning Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cfg.color.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cfg.icon,
                                  color: cfg.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cfg.color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cfg.label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: cfg.color,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Message
                                    Text(
                                      conflict.message,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (conflict.details != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        conflict.details!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Severity indicator
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: cfg.color.withOpacity(0.7),
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
      },
    );
  }

  Widget _buildCountBadge(
    List<ScheduleConflict> conflicts,
    String label,
    List<String> types,
    Color color,
  ) {
    final count = conflicts.where((c) => types.contains(c.type)).length;
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Config for conflict type icons and colours inside the Reports screen.
class _ReportConflictConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _ReportConflictConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _ScheduleOverviewTab extends ConsumerWidget {
  const _ScheduleOverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(scheduleOverviewReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) {
        final isMobile = ResponsiveHelper.isMobile(context);
        return Column(
          children: [
            if (isMobile) ...[
              _buildStatTile(
                context,
                'Total Schedules',
                data.totalSchedules.toString(),
                Icons.event_note_rounded,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatTile(
                context,
                'Active Programs',
                data.schedulesByProgram.length.toString(),
                Icons.account_tree_rounded,
                Colors.purple,
              ),
            ] else ...[
              Row(
                children: [
                  _buildStatTile(
                    context,
                    'Total Schedules',
                    data.totalSchedules.toString(),
                    Icons.event_note_rounded,
                    Colors.blue,
                  ),
                  const SizedBox(width: 24),
                  _buildStatTile(
                    context,
                    'Active Programs',
                    data.schedulesByProgram.length.toString(),
                    Icons.account_tree_rounded,
                    Colors.purple,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (isMobile) ...[
              _buildProgramBreakdown(context, data.schedulesByProgram),
              const SizedBox(height: 16),
              _buildTermBreakdown(context, data.schedulesByTerm),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProgramBreakdown(
                      context,
                      data.schedulesByProgram,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTermBreakdown(context, data.schedulesByTerm),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: _buildSectionSubjectsBreakdown(context, ref),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionSubjectsBreakdown(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);
    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading schedules: $e')),
      data: (schedules) {
        // Group schedules by section
        final Map<String, List<Schedule>> schedulesBySection = {};
        for (var schedule in schedules) {
          schedulesBySection
              .putIfAbsent(schedule.section, () => [])
              .add(
                schedule,
              );
        }

        // Sort sections alphabetically
        final sectionNames = schedulesBySection.keys.toList()..sort();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subjects per Section',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: sectionNames.length,
                  itemBuilder: (context, index) {
                    final section = sectionNames[index];
                    final sectionSchedules = schedulesBySection[section]!;

                    return ExpansionTile(
                      title: Text(
                        'Section: $section',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF720045),
                        ),
                      ),
                      subtitle: Text(
                        '${sectionSchedules.length} Subject${sectionSchedules.length == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 40,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 50,
                            columns: const [
                              DataColumn(label: Text('Code')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Faculty')),
                              DataColumn(label: Text('Room')),
                              DataColumn(label: Text('Schedule')),
                            ],
                            rows: sectionSchedules.map((s) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(s.subject?.code ?? 'N/A')),
                                  DataCell(Text(s.subject?.name ?? 'Unknown')),
                                  DataCell(Text(s.faculty?.name ?? 'TBA')),
                                  DataCell(Text(s.room?.name ?? 'TBA')),
                                  DataCell(
                                    Text(
                                      s.timeslot != null
                                          ? '${s.timeslot!.day.name.substring(0, 3)} ${s.timeslot!.startTime}-${s.timeslot!.endTime}'
                                          : 'TBA',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramBreakdown(BuildContext context, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...data.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${e.value} Classes',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.7, // Placeholder ratio
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          color: const Color(0xFF720045),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTermBreakdown(BuildContext context, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment by Term',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...data.entries
              .map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF720045),
                    child: Icon(Icons.flash_on, color: Colors.white, size: 16),
                  ),
                  title: Text(
                    'Term ${e.key}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${e.value} Subjects',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF720045),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
