import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leox/providers/employer_auth_provider.dart';
import 'package:leox/views/employer/employer_dashboard_view.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'employer_register_view.dart';

class EmployerLoginView extends StatefulWidget {
  const EmployerLoginView({super.key});

  @override
  State<EmployerLoginView> createState() => _EmployerLoginViewState();
}

class _EmployerLoginViewState extends State<EmployerLoginView> {
  bool isEmailSelected = true;
  bool isOtpSent = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String selectedCountryCode = "+91";

  static const primaryBlue = Color.fromRGBO(66, 133, 244, 1);
  static const bgColor = Color.fromRGBO(245, 247, 250, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

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
          icon: const Icon(Icons.home, color: Colors.black),
          label: const Text(
            "Change Role",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
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
                          backgroundColor: primaryBlue.withOpacity(0.12),
                          child: const Icon(
                            Icons.business_center_outlined,
                            color: primaryBlue,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Employer Login",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.2.h),

                    Text(
                      "Sign in to manage jobs and review candidates.",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: Colors.black54,
                      ),
                    ),

                    SizedBox(height: 3.5.h),

                    // 🔹 EMAIL / PHONE TOGGLE
                    Container(
                      padding: EdgeInsets.all(0.6.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _tabButton(
                              "Email",
                              selected: isEmailSelected,
                              onTap:
                                  () => setState(() {
                                    isEmailSelected = true;
                                    isOtpSent = false;
                                  }),
                            ),
                          ),
                          Expanded(
                            child: _tabButton(
                              "Phone",
                              selected: !isEmailSelected,
                              onTap:
                                  () => setState(() {
                                    isEmailSelected = false;
                                    isOtpSent = false;
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // 🔹 FORM
                    if (isEmailSelected) ...[
                      _label("Email"),
                      SizedBox(height: 0.8.h),
                      _inputField(keyboardType: TextInputType.emailAddress),

                      SizedBox(height: 2.5.h),

                      _label("Password"),
                      SizedBox(height: 0.8.h),
                      _inputField(isPassword: true),
                    ] else ...[
                      if (!isOtpSent) ...[
                        _label("Phone Number"),
                        SizedBox(height: 0.8.h),

                        Row(
                          children: [
                            // COUNTRY CODE
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                value: selectedCountryCode,
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
                        _label("Verification Code"),
                        SizedBox(height: 0.8.h),
                        _inputField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),

                        SizedBox(height: 1.5.h),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() => isOtpSent = false);
                            },
                            child: const Text("Back"),
                          ),
                        ),
                      ],
                    ],

                    SizedBox(height: 3.5.h),

                    // 🔹 PRIMARY BUTTON
                    Consumer<EmployerAuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                auth.isLoading
                                    ? null
                                    : () async {
                                      final provider =
                                          context.read<EmployerAuthProvider>();

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
                              backgroundColor: const Color.fromRGBO(
                                66,
                                133,
                                244,
                                1,
                              ),
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
                                    ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 3.h),

                    // 🔹 DIVIDER
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            "OR CONTINUE WITH",
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    SizedBox(height: 2.5.h),

                    // 🔹 GOOGLE
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          //await context.read<EmployerAuthProvider>().signInWithGoogle();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmployerDashboardView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/icons/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          "Sign In with Google",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.6.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EmployerRegisterView(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register as Employer",
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
    String text, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
    );
  }

  Widget _inputField({
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      ),
    );
  }
}
