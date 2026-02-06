import 'package:flutter/material.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:sizer/sizer.dart';
import '../providers/welcome_provider.dart';
import '../models/resource_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelcomeController.bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(context),
            _heroSection(context),
            _featuresSection(),
            _resourcesSection(),
            _footer(),
          ],
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        6.w, // left
        5.h, // 🔽 increased top padding (was 2.5.h)
        6.w, // right
        2.5.h, // bottom
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "LeoRecruit",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: WelcomeController.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 HERO
  Widget _heroSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Your Next Opportunity",
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: WelcomeController.textDark,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            "Browse jobs and discover roles that match your skills and ambitions.",
            style: TextStyle(
              fontSize: 13.sp,
              color: WelcomeController.textLight,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: WelcomeController.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleOptionView()),
                  );
                },

                child: Text(
                  "Get Started Free",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color.fromRGBO(0, 0, 0, 0.8),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              /*
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: WelcomeController.primaryColor,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                ),
                onPressed: () => WelcomeController.goToLogin(context),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: WelcomeController.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              */
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 FEATURES
  Widget _featuresSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 SMALL PILL
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: WelcomeController.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Key Features",
              style: TextStyle(
                color: WelcomeController.primaryColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // 🔹 MAIN HEADING
          Text(
            "Everything you need to streamline hiring.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: WelcomeController.textDark,
            ),
          ),

          SizedBox(height: 1.5.h),

          // 🔹 SUB HEADING
          Text(
            "From AI-powered resume screening to a centralized candidate database, "
            "LeoRecruit provides the tools to build your dream team.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: WelcomeController.textLight,
              height: 1.5,
            ),
          ),

          SizedBox(height: 4.h),

          // 🔹 FEATURE CARDS (YOUR EXISTING GRID)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: WelcomeController.features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final feature = WelcomeController.features[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: WelcomeController.primaryColor.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature.icon,
                            color: WelcomeController.primaryColor,
                            size: 20.sp,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        Text(
                          feature.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                            color: WelcomeController.textDark,
                          ),
                        ),

                        SizedBox(height: 1.h),

                        Text(
                          feature.description,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: WelcomeController.textLight,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🔹 RESOURCES (CLICKABLE)
  Widget _resourcesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TOP LABEL (small pill)
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: WelcomeController.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Resources",
                style: TextStyle(
                  color: WelcomeController.primaryColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // 🔹 MAIN HEADING
          Center(
            child: Text(
              "Insights & Resources",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: WelcomeController.textDark,
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // 🔹 SUB HEADING
          Center(
            child: Text(
              "Explore our collection of articles on hiring, career growth, and industry trends.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: WelcomeController.textLight,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // 🔹 FULL WIDTH CARDS
          ...WelcomeController.resources.map((res) {
            return Container(
              width: double.infinity, // 🔥 occupies full cross-section
              margin: EdgeInsets.only(bottom: 3.h),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openResourceDialog(res),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.category,
                          style: TextStyle(
                            color: WelcomeController.primaryColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 1.h),

                        Text(
                          res.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: WelcomeController.textDark,
                          ),
                        ),

                        SizedBox(height: 1.5.h),

                        Text(
                          res.shortDescription,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: WelcomeController.textLight,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 2.5.h),

                        Row(
                          children: [
                            Text(
                              "Read More",
                              style: TextStyle(
                                color: WelcomeController.primaryColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Icon(
                              Icons.arrow_forward,
                              size: 14.sp,
                              color: WelcomeController.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // 🔹 SPACE AFTER SECTION (matches screenshot)
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // 🔹 FOOTER
  Widget _footer() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          const Divider(),
          SizedBox(height: 1.h),
          Text("© 2024 LeoRecruit", style: TextStyle(fontSize: 9.sp)),
        ],
      ),
    );
  }

  // 🔥 RESOURCE POPUP (LIKE YOUR SCREENSHOT)
  void _openResourceDialog(ResourceModel res) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 90.w,
            height: 70.h,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          res.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Text(
                    res.category,
                    style: TextStyle(
                      color: WelcomeController.primaryColor,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  const Divider(),

                  // Scrollable content
                  Expanded(
                    child: ListView.builder(
                      itemCount: res.points.length,
                      itemBuilder: (context, index) {
                        final point = res.points[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. ${point.title}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: WelcomeController.textDark,
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              Text(
                                point.description,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: WelcomeController.textLight,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
