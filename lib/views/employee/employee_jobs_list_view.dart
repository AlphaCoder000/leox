import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/subscription_gate.dart';

import '../../providers/employee_providers/employee_jobs_provider.dart';
import '../../widgets/employee_drawer.dart';
import '../../widgets/employee_job_card.dart';
import 'employee_job_details_view.dart';

class EmployeeJobsListView extends StatefulWidget {
  const EmployeeJobsListView({super.key});

  @override
  State<EmployeeJobsListView> createState() => _EmployeeJobsListViewState();
}

class _EmployeeJobsListViewState extends State<EmployeeJobsListView> {
  String query = "";

  @override
  void initState() {
    super.initState();
    // Load jobs when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeJobsProvider>().loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeJobsProvider>();
    final jobs = provider.searchJobs(query);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const EmployeeDrawer(selectedItem: EmployeeDrawerItem.jobs),
      appBar: AppBar(title: const Text("Jobs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
      body: SubscriptionGate(
        featureKey: 'view_jobs',
        child: Padding(
          padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Job Listings",
              style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.6.h),
            Text(
              "Browse and apply for jobs.",
              style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.normal,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),

            SizedBox(height: 1.h),

            // SEARCH
            TextField(
              onChanged: (v) => setState(() => query = v),
              style: TextStyle(fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: "Search jobs by title or department...",
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark 
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),

            SizedBox(height: 1.h),

            // JOB LIST
            Expanded(
              child:
                  jobs.isEmpty
                      ? Center(
                        child: Text(
                          "No jobs found",
                          style: TextStyle(fontSize: 1.3.h), // Updated to use 1.3.h
                        ),
                      )
                      : ListView.separated(
                        itemCount: jobs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return EmployeeJobCard(
                            job: job,
                            index: index,
                            onView: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EmployeeJobDetailsView(job: job),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
