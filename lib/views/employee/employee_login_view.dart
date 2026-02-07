import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leox/providers/employee/employee_auth_provider.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'employee_register_view.dart';

class EmployeeLoginView extends StatefulWidget {
  const EmployeeLoginView({super.key});

  @override
  State<EmployeeLoginView> createState() => _EmployeeLoginViewState();
}

class _EmployeeLoginViewState extends State<EmployeeLoginView> {
  bool isEmailSelected = true;
  bool isOtpSent = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String selectedCountryCode = "+91";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 🔹 TOP BAR (Change Role)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 42.w,
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RoleOptionView()),
            );
          },
          icon: Icon(Icons.home, color: theme.iconTheme.color),
          label: Text(
            "Change Role",
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: theme.cardTheme.color,
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 HEADER
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: colorScheme.primary.withOpacity(
                            0.12,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Employee Login",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.2.h),

                    Text(
                      "Sign in to apply for jobs and track applications.",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                      ),
                    ),

                    SizedBox(height: 3.5.h),

                    // 🔹 EMAIL / PHONE TOGGLE
                    Container(
                      padding: EdgeInsets.all(0.6.w),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _tabButton(
                              context,
                              "Email",
                              selected: isEmailSelected,
                              onTap: () {
                                setState(() {
                                  isEmailSelected = true;
                                  isOtpSent = false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _tabButton(
                              context,
                              "Phone",
                              selected: !isEmailSelected,
                              onTap: () {
                                setState(() {
                                  isEmailSelected = false;
                                  isOtpSent = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // 🔹 FORM
                    if (isEmailSelected) ...[
                      _label(context, "Email"),
                      SizedBox(height: 0.8.h),
                      _inputField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 2.5.h),

                      _label(context, "Password"),
                      SizedBox(height: 0.8.h),
                      _inputField(
                        controller: passwordController,
                        isPassword: true,
                      ),
                    ] else ...[
                      if (!isOtpSent) ...[
                        _label(context, "Phone Number"),
                        SizedBox(height: 0.8.h),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(12),
                                color: theme.inputDecorationTheme.fillColor,
                              ),
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
                                dropdownColor: theme.cardTheme.color,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: "+91",
                                    child: Text("+91"),
                                  ),
                                  DropdownMenuItem(
                                    value: "+1",
                                    child: Text("+1"),
                                  ),
                                  DropdownMenuItem(
                                    value: "+44",
                                    child: Text("+44"),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(
                                      () => selectedCountryCode = v!,
                                    ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _inputField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _label(context, "Verification Code"),
                        SizedBox(height: 0.8.h),
                        _inputField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => isOtpSent = false),
                            child: const Text("Back"),
                          ),
                        ),
                      ],
                    ],

                    SizedBox(height: 3.5.h),

                    // 🔹 PRIMARY BUTTON
                    Consumer<EmployeeAuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                auth.isLoading
                                    ? null
                                    : () async {
                                      final provider =
                                          context.read<EmployeeAuthProvider>();

                                      if (!isEmailSelected && !isOtpSent) {
                                        await provider.sendOtp(
                                          "$selectedCountryCode${phoneController.text}",
                                        );
                                        setState(() => isOtpSent = true);
                                      } else if (!isEmailSelected &&
                                          isOtpSent) {
                                        await provider.verifyOtp(
                                          otpController.text,
                                        );
                                      } else {
                                        await provider.loginWithEmail(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 1.8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                auth.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      isEmailSelected
                                          ? "Sign In with Email"
                                          : isOtpSent
                                          ? "Verify & Sign In"
                                          : "Send Verification Code",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // 🔹 GOOGLE
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmployeeDashboardView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/icons/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          "Sign In with Google",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // 🔹 FOOTER
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark ? Colors.grey[400] : Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EmployeeRegisterView(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register as Employee",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _tabButton(
    BuildContext context,
    String text, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: selected ? theme.cardTheme.color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
