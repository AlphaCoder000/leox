import 'package:flutter/material.dart';
import 'package:leox/models/job_model.dart';
import 'package:leox/providers/employer_jobs_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CreateJobView extends StatefulWidget {
  final JobModel? jobToEdit;

  const CreateJobView({super.key, this.jobToEdit});

  @override
  State<CreateJobView> createState() => _CreateJobViewState();
}

class _CreateJobViewState extends State<CreateJobView> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final reqCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();
  final otherCategoryCtrl = TextEditingController();
  String _selectedCurrency = "₹";

  String category = "Mechanical Engineering";
  String jobType = "Full-time";
  String experience = "Mid-Level";
  String status = "Open";

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      final j = widget.jobToEdit!;
      titleCtrl.text = j.title;
      companyCtrl.text = j.companyName;
      locationCtrl.text = j.location;
      descCtrl.text = j.description;
      reqCtrl.text = j.requirements.join('\n');
      
      // Parse salaryRange for matching currency symbol prefix
      String storedSalary = j.salaryRange;
      String foundCurrency = "₹";
      for (final symbol in ['A\$', 'AED', 'SAR', 'KWD', 'Rp', '\$', '£', '€', '₹', '¥']) {
        if (storedSalary.startsWith(symbol)) {
          foundCurrency = symbol;
          storedSalary = storedSalary.substring(symbol.length).trim();
          break;
        }
      }
      _selectedCurrency = foundCurrency;
      salaryCtrl.text = storedSalary;

      category = j.category;
      if (![
        "Data Science", "Machine Learning", "Software Development", "Mobile App Development", 
        "UI/UX Design", "Cybersecurity", "Product Management", "Marketing", "Finance", 
        "Human Resources", "Business Analysis", "Content Writing", "Architecture", 
        "Civil Engineering", "Mechanical Engineering", "Other"
      ].contains(category)) {
        otherCategoryCtrl.text = category;
        category = "Other";
      }
      jobType = j.jobType;
      experience = j.experienceLevel;
      status = j.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.read<EmployerJobsProvider>();
    final isEditing = widget.jobToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Job" : "Create New Job")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(context, "Job Details"),

              _field(
                label: "Job Title *",
                controller: titleCtrl,
                validator: "Job title is required",
              ),

              _field(
                label: "Company Name *",
                controller: companyCtrl,
                validator: "Company name is required",
              ),

              _field(
                label: "Location *",
                controller: locationCtrl,
                validator: "Location is required",
              ),

              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: "Job Category *",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Data Science", child: Text("Data Science")),
                  DropdownMenuItem(value: "Machine Learning", child: Text("Machine Learning")),
                  DropdownMenuItem(value: "Software Development", child: Text("Software Development")),
                  DropdownMenuItem(value: "Mobile App Development", child: Text("Mobile App Development")),
                  DropdownMenuItem(value: "UI/UX Design", child: Text("UI/UX Design")),
                  DropdownMenuItem(value: "Cybersecurity", child: Text("Cybersecurity")),
                  DropdownMenuItem(value: "Product Management", child: Text("Product Management")),
                  DropdownMenuItem(value: "Marketing", child: Text("Marketing")),
                  DropdownMenuItem(value: "Finance", child: Text("Finance")),
                  DropdownMenuItem(value: "Human Resources", child: Text("Human Resources")),
                  DropdownMenuItem(value: "Business Analysis", child: Text("Business Analysis")),
                  DropdownMenuItem(value: "Content Writing", child: Text("Content Writing")),
                  DropdownMenuItem(value: "Architecture", child: Text("Architecture")),
                  DropdownMenuItem(value: "Civil Engineering", child: Text("Civil Engineering")),
                  DropdownMenuItem(value: "Mechanical Engineering", child: Text("Mechanical Engineering")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (v) => setState(() => category = v!),
                validator: (v) => v == null || v.isEmpty ? "Select a category" : null,
              ),

              if (category == "Other") ...[
                const SizedBox(height: 16),
                _field(
                  label: "Specify Job Category *",
                  controller: otherCategoryCtrl,
                  validator: "Please specify the job category",
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: jobType,
                      decoration: const InputDecoration(labelText: "Job Type"),
                      items: const [
                        DropdownMenuItem(value: "Full-time", child: Text("Full-time")),
                        DropdownMenuItem(value: "Part-time", child: Text("Part-time")),
                        DropdownMenuItem(value: "Contract", child: Text("Contract")),
                        DropdownMenuItem(value: "Internship", child: Text("Internship")),
                      ],
                      onChanged: (v) => setState(() => jobType = v!),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: experience,
                      decoration: const InputDecoration(labelText: "Experience"),
                      items: const [
                        DropdownMenuItem(value: "Entry", child: Text("Entry")),
                        DropdownMenuItem(value: "Mid-Level", child: Text("Mid-Level")),
                        DropdownMenuItem(value: "Senior", child: Text("Senior")),
                        DropdownMenuItem(value: "Executive", child: Text("Executive")),
                      ],
                      onChanged: (v) => setState(() => experience = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: "Status"),
                items: const [
                  DropdownMenuItem(value: "Open", child: Text("Open")),
                  DropdownMenuItem(value: "Closed", child: Text("Closed")),
                  DropdownMenuItem(value: "On Hold", child: Text("On Hold")),
                ],
                onChanged: (v) => setState(() => status = v!),
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25.w,
                    height: 7.2.h,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: ['₹', '\$', '£', '€', 'A\$', '¥', 'Rp', 'AED', 'SAR', 'KWD'].map((symbol) {
                          return DropdownMenuItem<String>(
                            value: symbol,
                            child: Text(symbol),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCurrency = val!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _field(
                      label: "Salary Range (e.g. 50k-80k) *",
                      controller: salaryCtrl,
                      validator: "Salary range is required",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _field(
                label: "Job Description *",
                controller: descCtrl,
                maxLines: 4,
                validator: "Job description is required",
              ),

              _field(
                label: "Requirements (one per line) *",
                controller: reqCtrl,
                maxLines: 4,
                validator: "At least one requirement is required",
                helperText: "Enter each requirement on a new line",
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(isEditing ? "Save Changes" : "Post Job"),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final newJob = JobModel(
                          id: widget.jobToEdit?.id ?? '', // Keeps the same ID if editing
                          title: titleCtrl.text.trim(),
                          companyName: companyCtrl.text.trim(),
                          location: locationCtrl.text.trim(),
                          department: widget.jobToEdit?.department ?? '',
                          category: category == "Other" ? otherCategoryCtrl.text.trim() : category,
                          jobType: jobType,
                          experienceLevel: experience,
                          salaryRange: "$_selectedCurrency ${salaryCtrl.text.trim()}",
                          description: descCtrl.text.trim(),
                          requirements: reqCtrl.text.trim().split('\n'),
                          postedOn: widget.jobToEdit?.postedOn ?? DateTime.now(),
                          status: status,
                        );

                        if (isEditing) {
                          await jobsProvider.updateJob(widget.jobToEdit!, newJob);
                        } else {
                          await jobsProvider.addJob(newJob);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(isEditing ? "Job updated successfully!" : "Job posted successfully!"),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );

                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text("Failed to ${isEditing ? 'update' : 'post'} job: ${e.toString()}"),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter ${label.toLowerCase()}",
          helperText: helperText,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? validator : null,
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    companyCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    reqCtrl.dispose();
    salaryCtrl.dispose();
    otherCategoryCtrl.dispose();
    super.dispose();
  }
}
