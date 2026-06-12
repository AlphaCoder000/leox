/// Candidates View
///
/// Shows all job applications and candidates for employer with a premium UI
library;

import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/job_application_provider.dart';
import '../../models/candidate_model.dart';
import '../../utils/error_handler_ui.dart';
import '../../widgets/employer_drawer.dart';
import '../common/application_details_view.dart';

class CandidatesView extends StatefulWidget {
  const CandidatesView({super.key});

  @override
  State<CandidatesView> createState() => _CandidatesViewState();
}

class _CandidatesViewState extends State<CandidatesView>
    with TickerProviderStateMixin {
  late TabController _statusTabController;
  String? _selectedJobTitle;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _updatingCandidateId;

  @override
  void initState() {
    super.initState();
    _statusTabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobApplicationProvider>().loadEmployerApplications();
    });
  }

  @override
  void dispose() {
    _statusTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //final isDark = theme.brightness == Brightness.dark;
    final applicationProvider = context.watch<JobApplicationProvider>();

    // Get unique job titles for filtering
    final jobTitles =
        applicationProvider.candidates.map((c) => c.jobTitle).toSet().toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.candidates),
      body: CustomScrollView(
        slivers: [
          // 🔹 APP BAR
          SliverAppBar(
            expandedHeight: 7.h,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Candidates',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.secondary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 SEARCH & FILTER SECTION
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged:
                                (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search candidates...',
                              hintStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 1.5.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<String?>(
                          icon: Icon(
                            Icons.filter_list,
                            color: colorScheme.primary,
                          ),
                          onSelected:
                              (value) =>
                                  setState(() => _selectedJobTitle = value),
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: null,
                                  child: Text('All Jobs'),
                                ),
                                ...jobTitles.map(
                                  (title) => PopupMenuItem(
                                    value: title,
                                    child: Text(title),
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),
                  if (_selectedJobTitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Chip(
                          label: Text('Job: $_selectedJobTitle'),
                          onDeleted:
                              () => setState(() => _selectedJobTitle = null),
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          deleteIconColor: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 🔹 TAB BAR (Pinned)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _statusTabController,
                isScrollable: true,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    text:
                        'All (${applicationProvider.getCandidateCountByStatus('all')})',
                  ),
                  Tab(
                    text:
                        'Pending (${applicationProvider.getCandidateCountByStatus('pending')})',
                  ),
                  Tab(
                    text:
                        'Reviewed (${applicationProvider.getCandidateCountByStatus('reviewed')})',
                  ),
                  Tab(
                    text:
                        'Shortlisted (${applicationProvider.getCandidateCountByStatus('shortlisted')})',
                  ),
                  Tab(
                    text:
                        'Rejected (${applicationProvider.getCandidateCountByStatus('rejected')})',
                  ),
                  Tab(
                    text:
                        'Hired (${applicationProvider.getCandidateCountByStatus('hired')})',
                  ),
                ],
              ),
              theme.scaffoldBackgroundColor,
            ),
          ),

          // 🔹 LIST VIEW
          SliverFillRemaining(
            child: TabBarView(
              controller: _statusTabController,
              children: [
                _buildCandidatesList('all'),
                _buildCandidatesList('pending'),
                _buildCandidatesList('reviewed'),
                _buildCandidatesList('shortlisted'),
                _buildCandidatesList('rejected'),
                _buildCandidatesList('hired'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList(String status) {
    final applicationProvider = context.watch<JobApplicationProvider>();
    var candidates = applicationProvider.getCandidatesByStatus(status);

    // Apply Filters
    if (_selectedJobTitle != null) {
      candidates =
          candidates.where((c) => c.jobTitle == _selectedJobTitle).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      candidates =
          candidates
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    c.jobTitle.toLowerCase().contains(query) ||
                    c.email.toLowerCase().contains(query),
              )
              .toList();
    }

    if (applicationProvider.isLoading &&
        candidates.isEmpty &&
        _searchQuery.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (candidates.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<JobApplicationProvider>().loadEmployerApplications();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          return _buildCandidateCard(candidates[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_outlined,
              size: 20.w,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'No candidates match your search'
                : _selectedJobTitle != null
                ? 'No candidates for this job'
                : status == 'all'
                ? 'No applications yet'
                : 'No $status applications',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => JobApplicationDetailsView(
                        application: candidate,
                        isEmployer: true,
                      ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  color: _getStatusColor(candidate.status).withValues(alpha: 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Applied ${_formatDate(candidate.appliedAt)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildStatusBadge(candidate.status),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Candidate Info Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 5.w,
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              backgroundImage:
                                  candidate.avatarUrl.isNotEmpty
                                      ? NetworkImage(candidate.avatarUrl)
                                      : null,
                              child:
                                  candidate.avatarUrl.isEmpty
                                      ? Icon(
                                        Icons.person,
                                        size: 9.w,
                                        color: colorScheme.primary,
                                      )
                                      : null,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    if (candidate.headline.isNotEmpty)
                                      Text(
                                        candidate.headline,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 12,
                                      color: colorScheme.primary,
                                    ),
                                    SizedBox(width: 1.w),
                                    Expanded(
                                      child: Text(
                                        candidate.email,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Job Title Section
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.work_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        candidate.jobTitle,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${candidate.jobType} • ${candidate.jobLocation}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Skills Section
                      if (candidate.skills.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children:
                              candidate.skills
                                  .take(4)
                                  .map(
                                    (skill) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        skill,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],

                      SizedBox(height: 1.h),

                      // Actions
                      Row(
                        children: [
                          _buildActionButton(
                            onTap: () => _viewResume(candidate),
                            icon: Icons.description_outlined,
                            label: 'CV',
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 3.w),
                          _buildActionButton(
                            onTap: () => _contactCandidate(candidate),
                            icon: Icons.alternate_email,
                            label: 'Contact',
                            color: Colors.green,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildStatusUpdateDropdown(candidate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateDropdown(CandidateModel candidate) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_updatingCandidateId == candidate.id) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: PopupMenuButton<String>(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        onSelected: (status) => _updateApplicationStatus(candidate.id, status),
        itemBuilder:
            (context) => [
              _buildPopupItem(
                'reviewed',
                Icons.visibility_outlined,
                'Mark Reviewed',
              ),
              _buildPopupItem('shortlisted', Icons.star_outline, 'Shortlist'),
              _buildPopupItem('rejected', Icons.close, 'Reject'),
              _buildPopupItem('hired', Icons.work, 'Hire'),
            ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 3.w),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _getStatusDisplay(status).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'reviewed':
        return Colors.blue[600]!;
      case 'shortlisted':
        return Colors.teal[600]!;
      case 'rejected':
        return Colors.red[600]!;
      case 'hired':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'New';
      case 'reviewed':
        return 'Reviewing';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'hired':
        return 'Hired';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _viewResume(CandidateModel candidate) async {
    if (candidate.resumeUrl.isNotEmpty) {
      final url = Uri.parse(candidate.resumeUrl);
      try {
        final success = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!success && mounted) {
          ErrorHandlerUI.showErrorSnackbar(context, 'Could not open resume');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandlerUI.showErrorSnackbar(context, 'Error opening resume: $e');
        }
      }
    } else {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'No resume available');
      }
    }
  }

  Future<void> _contactCandidate(CandidateModel candidate) async {
    final url = Uri.parse('mailto:${candidate.email}');
    try {
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!success && mounted) {
        ErrorHandlerUI.showErrorSnackbar(context, 'Could not open email app');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerUI.showErrorSnackbar(
          context,
          'Error opening email app: $e',
        );
      }
    }
  }

  Future<void> _updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    setState(() {
      _updatingCandidateId = applicationId;
    });
    final success = await context
        .read<JobApplicationProvider>()
        .updateApplicationStatus(applicationId: applicationId, status: status);

    if (mounted) {
      setState(() {
        _updatingCandidateId = null;
      });
      if (success) {
        ErrorHandlerUI.showSuccessSnackbar(context, 'Status updated to $status');
      }
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
