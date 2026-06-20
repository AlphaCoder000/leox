import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/views/employer/create_job_view.dart';

class JobDetailsSheet extends StatelessWidget {
  final JobModel job;
  final Color themeColor;

  const JobDetailsSheet({super.key, required this.job, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 🔹 DRAG HANDLE
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.6.h,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // 🔹 SCROLLABLE CONTENT
              Expanded(
                child: ListView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ================= HEADER SECTION =================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  // Status Badge
                                  _statusBadge(job.status),
                                  SizedBox(width: 2.5.w),
                                  // Applications Count Badge
                                  _appCountBadge(theme, job.applicationCount),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          onSelected: (value) {
                            Navigator.pop(context); // Close the sheet
                            if (value == 'delete') {
                              _showDeleteDialog(context);
                            } else if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateJobView(jobToEdit: job),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text("Edit")),
                            PopupMenuItem(value: 'delete', child: Text("Delete")),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 2.5.h),

                    // ================= QUICK STATS GRID =================
                    _buildStatsGrid(context, theme, isDark),

                    SizedBox(height: 2.h),

                    // ================= JOB DESCRIPTION =================
                    if (job.description.isNotEmpty) ...[
                      _sectionCard(
                        context,
                        title: "Job Description",
                        icon: Icons.description_rounded,
                        child: Text(
                          job.description,
                          style: TextStyle(
                            fontSize: 17.sp,
                            height: 1.5,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // ================= REQUIRED SKILLS =================
                    if (job.skills.isNotEmpty) ...[
                      _sectionCard(
                        context,
                        title: "Required Skills",
                        icon: Icons.psychology_rounded,
                        child: Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: job.skills.map((skill) => _skillChip(skill)).toList(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // ================= REQUIREMENTS =================
                    if (job.requirements.isNotEmpty) ...[
                      _sectionCard(
                        context,
                        title: "Requirements",
                        icon: Icons.playlist_add_check_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: job.requirements.map((req) => _bulletPoint(theme, req)).toList(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // ================= BENEFITS & PERKS =================
                    if (job.benefits.isNotEmpty) ...[
                      _sectionCard(
                        context,
                        title: "Benefits & Perks",
                        icon: Icons.card_giftcard_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: job.benefits.map((benefit) => _benefitPoint(theme, benefit)).toList(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // ================= DEADLINE =================
                    if (job.deadline != null) ...[
                      _sectionCard(
                        context,
                        title: "Application Deadline",
                        icon: Icons.event_busy_rounded,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.5.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18.sp,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${job.deadline!.day} ${_getMonthName(job.deadline!.month)}, ${job.deadline!.year}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  _getDaysRemainingText(job.deadline!),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // ================= ADDITIONAL INFO =================
                    if (job.additionalInfo.isNotEmpty) ...[
                      _sectionCard(
                        context,
                        title: "Additional Information",
                        icon: Icons.info_outline_rounded,
                        child: Column(
                          children: job.additionalInfo.entries.map((entry) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _capitalize(entry.key),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI WIDGET BUILDERS =================

  Widget _statusBadge(String status) {
    final isOpen = status.toLowerCase() == 'open' || status.toLowerCase() == 'active';
    final badgeColor = isOpen ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.5.w),
          Text(
            isOpen ? "Active" : "Closed",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appCountBadge(ThemeData theme, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 12.sp, color: themeColor),
          SizedBox(width: 1.5.w),
          Text(
            "$count Application${count == 1 ? '' : 's'}",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ThemeData theme, bool isDark) {
    // Only display filled stats
    final List<Widget> stats = [];

    if (job.companyName.isNotEmpty) {
      stats.add(_statCard(context, Icons.business_rounded, "Company", job.companyName));
    }
    if (job.location.isNotEmpty) {
      stats.add(_statCard(context, Icons.location_on_rounded, "Location", job.location));
    }
    if (job.salaryRange.isNotEmpty) {
      stats.add(_statCard(context, Icons.payments_rounded, "Salary", job.salaryRange));
    }
    if (job.department.isNotEmpty) {
      stats.add(_statCard(context, Icons.apartment_rounded, "Department", job.department));
    }
    if (job.category.isNotEmpty) {
      stats.add(_statCard(context, Icons.category_rounded, "Category", job.category));
    }
    if (job.jobType.isNotEmpty) {
      stats.add(_statCard(context, Icons.work_outline_rounded, "Job Type", job.jobType));
    }
    if (job.experienceLevel.isNotEmpty) {
      stats.add(_statCard(context, Icons.psychology_rounded, "Experience", job.experienceLevel));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 3.w,
      runSpacing: 1.5.h,
      children: stats.map((stat) => SizedBox(
        width: 44.w,
        child: stat,
      )).toList(),
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: isDark ? 0.15 : 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16.sp, color: themeColor),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17.sp, color: themeColor),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Divider(
            height: 3.h,
            thickness: 0.8,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          child,
        ],
      ),
    );
  }

  Widget _skillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: themeColor,
        ),
      ),
    );
  }

  Widget _bulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 11.sp,
              color: themeColor,
            ),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17.sp,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitPoint(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              size: 11.sp,
              color: Colors.pink.shade400,
            ),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17.sp,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPER FUNCTIONS =================

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return "";
  }

  String _getDaysRemainingText(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return "Expired";
    } else if (difference == 0) {
      return "Closes today!";
    } else if (difference == 1) {
      return "1 day remaining";
    } else {
      return "$difference days remaining";
    }
  }

  String _capitalize(String key) {
    if (key.isEmpty) return "";
    return "${key[0].toUpperCase()}${key.substring(1).replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').toLowerCase()}";
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Job"),
        content: const Text("Are you sure you want to delete this job posting?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<EmployerJobsProvider>().deleteJob(job);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
