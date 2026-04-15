import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/views/employee/employee_login_view.dart';
import 'package:leox/views/general/role_option_view.dart';
import 'package:leox/utils/email_validator_helper.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EmployeeRegisterView extends StatefulWidget {
  const EmployeeRegisterView({super.key});

  @override
  State<EmployeeRegisterView> createState() => _EmployeeRegisterViewState();
}

class _EmployeeRegisterViewState extends State<EmployeeRegisterView> {
  bool isEmailSelected = true;
  bool isOtpSent = false; // 🔹 NEW

  String selectedCountryCode = "+91";
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Listen to success messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToSuccessMessages();
    });
  }

  void _listenToSuccessMessages() {
    context.read<EmployeeAuthProvider>().addListener(_onSuccessMessage);
  }

  void _onSuccessMessage() {
    final auth = context.read<EmployeeAuthProvider>();
    if (auth.successMessage != null && auth.successMessage!.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      auth.clearSuccessMessage();
    }
  }

  // void _clearError() {
  //   context.read<EmployeeAuthProvider>().clearError();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 🔹 APP BAR
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

      body: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 HEADER
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.business_center_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Employee Registration",
                      style: TextStyle(
                        fontSize: 23.sp, fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  "Create an account to search for job opportunities.",
                  style: TextStyle(
                    fontSize: 17.sp, fontWeight: FontWeight.normal,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),

                const SizedBox(height: 32),

                // 🔹 EMAIL / PHONE TOGGLE
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor),
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

                const SizedBox(height: 24),

                // 🔹 FORM
                if (isEmailSelected) ...[
                  _label(context, "Full Name"),
                  const SizedBox(height: 8),
                  _inputField(keyboardType: TextInputType.name, controller: nameController),

                  const SizedBox(height: 20),

                  _label(context, "Email"),
                  const SizedBox(height: 8),
                  _inputField(keyboardType: TextInputType.emailAddress, controller: emailController),

                  const SizedBox(height: 20),

                  _label(context, "Password"),
                  const SizedBox(height: 8),
                  _inputField(
                      isPassword: true, 
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() { _obscurePassword = !_obscurePassword; });
                      }),

                  const SizedBox(height: 20),

                  _label(context, "Confirm Password"),
                  const SizedBox(height: 8),
                  _inputField(
                      isPassword: true, 
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; });
                      }),
                ] else ...[
                  if (!isOtpSent) ...[
                    _label(context, "Phone Number"),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // COUNTRY CODE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(12),
                            color: theme.inputDecorationTheme.fillColor,
                          ),
                          child: DropdownButton<String>(
                            value: selectedCountryCode,
                            dropdownColor: theme.cardTheme.color,
                            style: TextStyle(color: colorScheme.onSurface),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: "+91", child: Text("+91")),
                              DropdownMenuItem(value: "+1", child: Text("+1")),
                              DropdownMenuItem(value: "+44", child: Text("+44")),
                              DropdownMenuItem(value: "+61", child: Text("+61")),
                            ],
                            onChanged:
                                (v) => setState(
                                  () => selectedCountryCode = v!,
                                ),
                          ),
                        ),

                        const SizedBox(width: 12),

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
                    _label(context, "Verification Code"),
                    const SizedBox(height: 8),
                    _inputField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),

                    const SizedBox(height: 12),

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

                const SizedBox(height: 32),

                // 🔹 PRIMARY BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Consumer<EmployeeAuthProvider>(
                    builder: (context, auth, child) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : () async {
                          if (!isEmailSelected && !isOtpSent) {
                            setState(() => isOtpSent = true);
                            
                          } else if (!isEmailSelected && isOtpSent) {
                            
                          } else {
                            // Firebase email registration
                            await _registerWithEmail();
                            
                            // Success? main.dart will handle navigation.
                            // We just need to clear the stack if we are on top.
                            if (auth.isLoggedIn && context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: auth.isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEmailSelected
                                  ? "Sign Up with Email"
                                  : isOtpSent
                                  ? "Verify & Create Account"
                                  : "Send Verification Code",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // Fixed from 16.0 to 16.sp
                                color: Colors.white,
                              ),
                            ),
                      );
                    }
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 DIVIDER
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "OR CONTINUE WITH",
                        style: TextStyle(
                          fontSize: 15.sp, // Updated from 12.0 to 13.sp
                          color: isDark ? Colors.grey[500] : Colors.black54,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 GOOGLE
                Consumer<EmployeeAuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : () async {
                          final provider = context.read<EmployeeAuthProvider>();
                          await provider.signUpWithGoogle();
                          
                          if (provider.isLoggedIn && context.mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        icon: auth.isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(
                              'assets/icons/google_logo.png',
                              height: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                        label: Text(auth.isLoading ? "Signing up..." : "Sign Up with Google"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  }
                ),

                const SizedBox(height: 24),

                // 🔹 FOOTER
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 17.sp,// Updated from 14.0 to 15.sp
                          color: isDark ? Colors.grey[400] : Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmployeeLoginView(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign in as Employee",
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
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: selected ? theme.cardTheme.color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17.sp, fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ======== EMAIL REGISTRATION ========

  Future<void> _registerWithEmail() async {
    // Validate form
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    
    final emailError = EmailValidatorHelper.validateEmployeeEmail(emailController.text.trim());
    if (emailError != null) {
      _showError(emailError);
      return;
    }

    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // Call registration method
    await context.read<EmployeeAuthProvider>().registerWithFirebaseEmail(
      email: emailController.text.trim(),
      password: passwordController.text,
      name: nameController.text.trim(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp, fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _inputField({
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[100],
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    context.read<EmployeeAuthProvider>().removeListener(_onSuccessMessage);
    super.dispose();
  }
}
