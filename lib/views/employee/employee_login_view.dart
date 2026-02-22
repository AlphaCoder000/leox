import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leox/providers/employee_providers/employee_auth_provider.dart';
import 'package:leox/views/employee/employee_register_view.dart';
import 'package:leox/views/employee/employee_dashboard_view.dart';
import 'package:leox/views/role_option_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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

  late EmployeeAuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    // Initialize provider access safely
    _authProvider = context.read<EmployeeAuthProvider>();
    
    // Ensure clean state on login screen entry
    if (_authProvider.isLoggedIn) {
       _authProvider.logout().then((_) {
         if (mounted) {
           _authProvider.addListener(_onAuthStateChanged);
         }
       });
    } else {
       // Listen to authentication state changes immediately if clean
       _authProvider.addListener(_onAuthStateChanged);
    }
  }

  void _onAuthStateChanged() {
    if (_authProvider.isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmployeeDashboardView()),
      );
    }
  }

  void _clearError() {
    _authProvider.clearError();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.business_center_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Employee Login",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Sign in to apply for jobs.",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

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
                          onTap: () => setState(() {
                            isEmailSelected = true;
                            isOtpSent = false;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _tabButton(
                          context,
                          "Phone",
                          selected: !isEmailSelected,
                          onTap: () => setState(() {
                            isEmailSelected = false;
                            isOtpSent = false;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (isEmailSelected) ...[
                  _label(context, "Email"),
                  const SizedBox(height: 8),
                  _inputField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _label(context, "Password"),
                  const SizedBox(height: 8),
                  _inputField(
                      controller: passwordController,
                      isPassword: true),
                ] else ...[
                  if (!isOtpSent) ...[
                    _label(context, "Phone Number"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: "+91", child: Text("+91")),
                              DropdownMenuItem(value: "+1", child: Text("+1")),
                              DropdownMenuItem(value: "+44", child: Text("+44")),
                            ],
                            onChanged: (v) => setState(() => selectedCountryCode = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 8),
                    _inputField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => isOtpSent = false),
                        child: const Text("Back"),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 32),

                Consumer<EmployeeAuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final provider = context.read<EmployeeAuthProvider>();

                                if (isEmailSelected) {
                                  await provider.loginWithEmail(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                                } else {
                                  // Phone Login Logic
                                  if (!isOtpSent) {
                                    if (phoneController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter phone number')),
                                      );
                                      return;
                                    }
                                    final phone = "$selectedCountryCode${phoneController.text.trim()}";
                                    await provider.sendOtp(phone); 
                                    if (provider.errorMessage == null) {
                                      setState(() => isOtpSent = true);
                                    }
                                  } else {
                                    await provider.verifyOtp(otpController.text);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEmailSelected
                                    ? "Sign In with Email"
                                    : isOtpSent
                                        ? "Verify & Sign In"
                                        : "Send Verification Code",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<EmployeeAuthProvider>().signInWithGoogle();
                    },
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.g_mobiledata, size: 24),
                    ),
                    label: Text(
                      "Sign In with Google",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 14.0,
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
    );
  }

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
          color: selected
              ? theme.cardTheme.color
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.w500,
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
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color:
            Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType =
        TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[100],
      ),
      onChanged: (value) {
        _clearError();
        onChanged?.call();
      },
    );
  }
}
