import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import 'mc_provider_login_view.dart';
import '../provider/mc_provider_dashboard_view.dart';
import 'package:leox/widgets/custom_popup.dart';

class McProviderRegisterView extends StatefulWidget {
  const McProviderRegisterView({super.key});

  @override
  State<McProviderRegisterView> createState() => _McProviderRegisterViewState();
}

class _McProviderRegisterViewState extends State<McProviderRegisterView> {
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<McProviderAuthController>();
      final error = await authController.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _companyController.text.trim(),
        _phoneController.text.trim(),
        _locationController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        await CustomPopup.show(
          context,
          type: CustomPopupType.success,
          title: 'Registration Successful!',
          message: 'Welcome! Your service provider account has been created successfully.',
          buttonLabel: 'Go to Dashboard',
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const McProviderDashboardView()),
          );
        }
      } else {
        CustomPopup.show(
          context,
          type: CustomPopupType.error,
          title: 'Registration Failed',
          message: error,
        );
      }
    }
  }

  void _registerWithGoogle() async {
    final authController = context.read<McProviderAuthController>();
    final error = await authController.signUpWithGoogle();

    if (!mounted) return;

    if (error == null) {
      await CustomPopup.show(
        context,
        type: CustomPopupType.success,
        title: 'Registration Successful!',
        message: 'Welcome! Your service provider account has been created successfully.',
        buttonLabel: 'Go to Dashboard',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const McProviderDashboardView()),
        );
      }
    } else if (error != "Sign-In cancelled by user") {
      CustomPopup.show(
        context,
        type: CustomPopupType.error,
        title: 'Google Sign-Up Failed',
        message: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<McProviderAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Registration"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, const Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Card(
              color: theme.cardTheme.color ?? (isDark ? Colors.black87 : Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_outlined, size: 42.sp, color: const Color(0xFF0EA5E9)),
                      SizedBox(height: 2.h),
                      Text(
                        "Become a Provider",
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 3.h),
                      
                      _buildTextField(_companyController, "Company/Provider Name", Icons.business, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_emailController, "Email Address", Icons.email_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_phoneController, "Contact Number", Icons.phone_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_locationController, "Location/City", Icons.location_on_outlined, false),
                      SizedBox(height: 2.h),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Required";
                          }
                          if (v != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authController.isLoading ? null : _register,
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text("Register", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: authController.isLoading ? null : _registerWithGoogle,
                          icon: authController.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0EA5E9)),
                                )
                              : Image.asset(
                                  'assets/icons/google_logo.png',
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF0EA5E9)),
                                ),
                          label: Text(
                            authController.isLoading ? "Registering..." : "Sign Up with Google",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            side: BorderSide(color: const Color(0xFF0EA5E9).withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const McProviderLoginView())),
                        child: Text("Already a provider? Login", style: TextStyle(color: const Color(0xFF0EA5E9), fontSize: 18.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Required field" : null,
    );
  }
}
