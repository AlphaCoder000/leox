import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/views/employer/create_job_view.dart';
import 'package:leox/widgets/employer_drawer.dart';
import 'package:leox/widgets/employer_job_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployerJobsListView extends StatefulWidget {
  const EmployerJobsListView({super.key});

  @override
  State<EmployerJobsListView> createState() => _EmployerJobsListViewState();
}

class _EmployerJobsListViewState extends State<EmployerJobsListView> {
  String query = "";

  @override
  void initState() {
    super.initState();
    // Load jobs when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerJobsProvider>().loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployerJobsProvider>();
    final jobs =
        provider.jobs
            .where(
              (job) =>
                  job.title.toLowerCase().contains(query.toLowerCase()) ||
                  job.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Jobs", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20))),
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.jobs),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateJobView()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Create Job"),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search jobs by title or category...",
                hintStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade300),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => query = ""),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),

          if (provider.isLoading)
            const LinearProgressIndicator(),

          if (provider.errorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child:
                jobs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "No jobs found",
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      itemCount: jobs.length,
                      itemBuilder:
                          (_, i) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: JobCard(job: jobs[i]),
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}
