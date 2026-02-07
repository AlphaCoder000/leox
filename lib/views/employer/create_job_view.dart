import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CreateJobView extends StatefulWidget {
  const CreateJobView({super.key});

  @override
  State<CreateJobView> createState() => _CreateJobViewState();
}

class _CreateJobViewState extends State<CreateJobView> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final deptCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final reqCtrl = TextEditingController();

  String category = "Mechanical Engineering";

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.read<EmployerJobsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Create New Job")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, "Job Details"),

              _field(
                label: "Job Title",
                controller: titleCtrl,
                validator: "Job title is required",
              ),

              _field(
                label: "Department",
                controller: deptCtrl,
                validator: "Department is required",
              ),

              DropdownButtonFormField<String>(
                value: category,
                decoration: _inputDecoration("Job Category *"),
                items: const [
                  DropdownMenuItem(
                    value: "Mechanical Engineering",
                    child: Text("Mechanical Engineering"),
                  ),
                  DropdownMenuItem(value: "Software", child: Text("Software")),
                  DropdownMenuItem(value: "Civil", child: Text("Civil")),
                ],
                onChanged: (v) => setState(() => category = v!),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? "Select a job category" : null,
              ),

              SizedBox(height: 2.h),

              _field(
                label: "Job Description",
                controller: descCtrl,
                maxLines: 4,
                validator: "Job description is required",
              ),

              _field(
                label: "Requirements (one per line)",
                controller: reqCtrl,
                maxLines: 4,
                validator: "At least one requirement is required",
                helperText: "Enter each requirement on a new line",
              ),

              SizedBox(height: 4.h),

              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text("Post Job"),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.4),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      jobsProvider.addJob(
                        JobModel(
                          title: titleCtrl.text.trim(),
                          department: deptCtrl.text.trim(),
                          category: category,
                          description: descCtrl.text.trim(),
                          requirements: reqCtrl.text.trim().split('\n'),
                          postedOn: DateTime.now(),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              const Text("Job posted successfully!"),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String validator,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.5.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter ${label.toLowerCase()}",
          helperText: helperText,
          alignLabelWithHint: maxLines > 1,
        ),
        validator: (v) => v == null || v.trim().isEmpty ? validator : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? helperText}) {
    // Rely on global theme, just adding label
    return InputDecoration(labelText: label, helperText: helperText);
  }
}
