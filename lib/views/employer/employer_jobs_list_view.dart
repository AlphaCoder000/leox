import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:leox/views/employer/create_job_view.dart';
import 'package:leox/widgets/employer_drawer.dart';
import 'package:leox/widgets/job_card.dart';
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
        icon: const Icon(Icons.add),
        label: const Text("Create Job"),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search jobs by title or department",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),

          Expanded(
            child:
                jobs.isEmpty
                    ? const Center(
                      child: Text(
                        "No jobs found",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: jobs.length,
                      itemBuilder: (_, i) => JobCard(job: jobs[i]),
                    ),
          ),
        ],
      ),
    );
  }
}
