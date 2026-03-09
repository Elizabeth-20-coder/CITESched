import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/core/utils/responsive_helper.dart';
import 'package:citesched_flutter/features/admin/widgets/conflict_list_modal.dart';
import 'package:citesched_flutter/features/admin/widgets/faculty_load_chart.dart';
import 'package:citesched_flutter/features/admin/widgets/report_modal.dart';
import 'package:citesched_flutter/features/admin/widgets/stat_card.dart';
import 'package:citesched_flutter/features/admin/widgets/user_list_modal.dart';
import 'package:citesched_flutter/features/auth/providers/auth_provider.dart';
import 'package:citesched_flutter/core/widgets/theme_mode_toggle.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return await client.admin.getDashboardStats();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    // Colors — Professional white theme
    const primaryPurple = Color(0xFF720045);
    const cardBg = Colors.white;

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final debugInfo = await client.debug.getSessionInfo();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Session Info'),
                        content: SingleChildScrollView(
                          child: Text(debugInfo.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debug failed: $e')),
                    );
                  }
                },
                child: const Text('Debug Session'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stats) {
          final totalSchedules = stats.totalSchedules;
          final totalUsers = stats.totalFaculty + stats.totalStudents;
          final totalConflicts = stats.totalConflicts;
          final recentConflicts = stats.recentConflicts;
          final facultyLoadData = stats.facultyLoad;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Standardized Maroon Gradient Banner)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryPurple, const Color(0xFF8e005b)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          ThemeModeToggle(compact: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.dashboard_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 28),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CITESched — Admin Dashboard',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 24 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Welcome back, ${userInfo?.userName ?? "Administrator"}',
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 14 : 18,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const ReportModal(),
                              );
                            },
                            icon: const Icon(Icons.analytics_rounded, size: 24),
                            label: Text(
                              'View Detailed Reports',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const UserListModal(),
                                );
                              },
                              icon: const Icon(Icons.people_rounded, size: 24),
                              label: Text(
                                'Manage Users',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Statistics Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = isDesktop;

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Scheduled Classes',
                              value: totalSchedules.toString(),
                              icon: Icons.calendar_today_rounded,
                              borderColor: primaryPurple,
                              iconColor: primaryPurple,
                              valueColor: primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Active Users',
                              value: totalUsers.toString(),
                              icon: Icons.people_rounded,
                              borderColor: const Color(0xFF9333ea),
                              iconColor: const Color(0xFF9333ea),
                              valueColor: const Color(0xFF9333ea),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const UserListModal(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Total Subjects',
                              value: stats.totalSubjects.toString(),
                              icon: Icons.book_rounded,
                              borderColor: const Color(0xFFc026d3),
                              iconColor: const Color(0xFFc026d3),
                              valueColor: const Color(0xFFc026d3),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Total Rooms',
                              value: stats.totalRooms.toString(),
                              icon: Icons.meeting_room_rounded,
                              borderColor: const Color(0xFFdb2777),
                              iconColor: const Color(0xFFdb2777),
                              valueColor: const Color(0xFFdb2777),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Conflicts',
                              value: totalConflicts.toString(),
                              icon: Icons.warning_amber_rounded,
                              borderColor: const Color(0xFFb5179e),
                              iconColor: const Color(0xFFb5179e),
                              valueColor: const Color(0xFFb5179e),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConflictListModal(
                                    conflicts: recentConflicts,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          StatCard(
                            label: 'Scheduled Classes',
                            value: totalSchedules.toString(),
                            icon: Icons.calendar_today_rounded,
                            borderColor: primaryPurple,
                            iconColor: primaryPurple,
                            valueColor: primaryPurple,
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            label: 'Active Users',
                            value: totalUsers.toString(),
                            icon: Icons.people_rounded,
                            borderColor: const Color(0xFF9333ea),
                            iconColor: const Color(0xFF9333ea),
                            valueColor: const Color(0xFF9333ea),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const UserListModal(),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            label: 'Total Subjects',
                            value: stats.totalSubjects.toString(),
                            icon: Icons.book_rounded,
                            borderColor: const Color(0xFFc026d3),
                            iconColor: const Color(0xFFc026d3),
                            valueColor: const Color(0xFFc026d3),
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            label: 'Total Rooms',
                            value: stats.totalRooms.toString(),
                            icon: Icons.meeting_room_rounded,
                            borderColor: const Color(0xFFdb2777),
                            iconColor: const Color(0xFFdb2777),
                            valueColor: const Color(0xFFdb2777),
                          ),
                          const SizedBox(height: 16),
                          StatCard(
                            label: 'Unresolved Conflicts',
                            value: totalConflicts.toString(),
                            icon: Icons.warning_amber_rounded,
                            borderColor: const Color(0xFFb5179e),
                            iconColor: const Color(0xFFb5179e),
                            valueColor: const Color(0xFFb5179e),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConflictListModal(
                                  conflicts: recentConflicts,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Chart and Conflict Panel
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = isDesktop;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildChartCard(
                              context,
                              cardBg,
                              primaryPurple,
                              facultyLoadData,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildConflictCard(
                              context,
                              cardBg,
                              primaryPurple,
                              recentConflicts,
                              primaryPurple,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildChartCard(
                            context,
                            cardBg,
                            primaryPurple,
                            facultyLoadData,
                          ),
                          const SizedBox(height: 24),
                          _buildConflictCard(
                            context,
                            cardBg,
                            primaryPurple,
                            recentConflicts,
                            primaryPurple,
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Distribution Summaries
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = isDesktop;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDistributionPanel(
                              context,
                              'Section Distribution',
                              stats.sectionDistribution,
                              cardBg,
                              primaryPurple,
                              Icons.groups_rounded,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDistributionPanel(
                              context,
                              'Year Level Distribution',
                              stats.yearLevelDistribution,
                              cardBg,
                              const Color(0xFF9333ea),
                              Icons.layers_rounded,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildDistributionPanel(
                            context,
                            'Section Distribution',
                            stats.sectionDistribution,
                            cardBg,
                            primaryPurple,
                            Icons.groups_rounded,
                          ),
                          const SizedBox(height: 24),
                          _buildDistributionPanel(
                            context,
                            'Year Level Distribution',
                            stats.yearLevelDistribution,
                            cardBg,
                            const Color(0xFF9333ea),
                            Icons.layers_rounded,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    Color cardBg,
    Color headerBg,
    List<FacultyLoadData> data,
  ) {
    // Determine inner menu bg (from css: var(--inner-menu-bg))
    // Typically this is a specific color in the theme, but for now assuming headerBg/Maroon
    // based on "card-header { background: var(--inner-menu-bg); ... }"
    // If user layout uses Maroon for sidebar, likely inner-menu-bg is also maroon or slightly different.

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
        ),
      ),
      clipBehavior: Clip.hardEdge, // Needed for header rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ), // 1.2rem 1.5rem
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Faculty Teaching Load (Units)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () {
                    // refresh logic
                  },
                ),
              ],
            ),
          ),
          // Chart
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              height: 350,
              child: FacultyLoadChart(data: data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictCard(
    BuildContext context,
    Color cardBg,
    Color headerBg,
    List<ScheduleConflict> conflicts,
    Color primaryColor,
  ) {
    final conflictCount = conflicts.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.black.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule Integrity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  height: 350,
                  child: conflictCount > 0
                      ? ListView.builder(
                          itemCount: conflictCount,
                          itemBuilder: (context, index) {
                            final conflict = conflicts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFb5179e,
                                ).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xFFb5179e),
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conflict Detected', // Or conflict.type
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFb5179e),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    conflict.message,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: textMuted.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size:
                                    80, // font-size: 3.5rem ~= 56px, increased slightly
                                color: const Color(0xFF2e7d32),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All Clear!',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color.fromARGB(255, 168, 31, 31)
                                      : const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No scheduling conflicts found in the system.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConflictListModal(
                          conflicts: conflicts,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    child: Text(
                      'Resolve All Conflicts',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionPanel(
    BuildContext context,
    String title,
    List<DistributionData> data,
    Color cardBg,
    Color headerBg,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF666666);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: data.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No data available',
                        style: GoogleFonts.poppins(color: textMuted),
                      ),
                    ),
                  )
                : Column(
                    children: data.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.label,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor:
                                        (item.count /
                                                data
                                                    .map((e) => e.count)
                                                    .reduce(
                                                      (a, b) => a > b ? a : b,
                                                    ))
                                            .clamp(0.0, 1.0),
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: headerBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${item.count}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: headerBg,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
