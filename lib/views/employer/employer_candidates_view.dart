import 'package:flutter/material.dart';
import 'package:leox/constants/employer_drawer_item.dart';
import 'package:leox/providers/employer_candidates_provider.dart';
import 'package:leox/widgets/employer_drawer.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployerCandidatesView extends StatefulWidget {
  const EmployerCandidatesView({super.key});

  @override
  State<EmployerCandidatesView> createState() => _EmployerCandidatesViewState();
}

class _EmployerCandidatesViewState extends State<EmployerCandidatesView> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployerCandidatesProvider>();
    final theme = Theme.of(context);

    final filtered =
        provider.candidates.where((c) {
          return c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.email.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return Scaffold(
      drawer: const EmployerDrawer(selectedItem: EmployerDrawerItem.candidates),
      appBar: AppBar(title: const Text("Candidates")),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Candidates",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  "A list of all candidates in your pipeline.",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // SEARCH
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by name or email...",
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),

          SizedBox(height: 2.h),

          // LIST
          Expanded(
            child:
                filtered.isEmpty
                    ? Center(
                      child: Text(
                        "No candidates found.",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return Card(
                          margin: EdgeInsets.only(bottom: 2.h),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.6.h),
                                Text(
                                  c.email,
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  "Applied for: ${c.appliedJobTitle}",
                                  style: TextStyle(fontSize: 12.5.sp),
                                ),
                                SizedBox(height: 0.6.h),
                                Text(
                                  "Status: ${c.status}",
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
