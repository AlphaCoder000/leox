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
  Widget build(BuildContext context) {
    final provider = context.watch<EmployerJobsProvider>();
    final jobs =
        provider.jobs
            .where(
              (job) =>
                  job.title.toLowerCase().contains(query.toLowerCase()) ||
                  job.department.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Jobs")),
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
          // 🔹 PREMIUM SEARCH BAR
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search jobs by title or department...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    query.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => query = ""),
                        )
                        : null,
              ),
              onChanged: (v) => setState(() => query = v),
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
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
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
